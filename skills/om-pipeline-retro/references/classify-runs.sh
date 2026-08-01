#!/usr/bin/env sh
# Deterministic run classifier, opened by the classify step. Pure stdin -> stdout:
# it reads tracker data, writes a classification, and contacts nothing.
#
# Input: one JSON array of pull requests on stdin, carrying the fields the skill
# requests through the list-prs and get-pr tracker operations:
#
#   number, state, createdAt, mergedAt, additions, changedFiles,
#   labels:   [{"name": ...}, ...]
#   reviews:  [{"state": ...}, ...]
#   comments: [{"body": ..., "createdAt": ...}, ...]
#
# Every field except `number` is optional and degrades to a neutral value.
#
# Classification rules, so an agent that cannot execute this file can apply the
# same rules inline and reach the same verdict:
#
#   1. A run is a cluster of agent-marker comments naming one skill. Two comments
#      naming the same skill belong to the same run when they are less than
#      --gap-minutes apart; a wider gap starts a new run. Without comment
#      timestamps each marker comment counts as its own run, which is an upper
#      bound, and `timestampCoverage` in the output says so.
#   2. A pull request took a SECOND PASS when any of these hold: two or more
#      review runs, any resume run, any drive-to-merge-ready run, two or more QA
#      runs, or the request was closed without merging.
#   3. A second pass is HARD RECOVERY when the record states a reason: recovery
#      language in any comment, a formal changes-requested review, a declared
#      non-clean Outcome line, or closure without merging.
#   4. It is LOOP CHECKPOINTS when the only second-pass evidence comes from the
#      loop-mode skills, which post checkpoints by design.
#   5. Anything else that took a second pass is UNEXPLAINED: the record shows the
#      cost and not the cause.
#   6. Wall-clock cost is opened-to-merged. A cause's excess hours is the sum, over
#      the requests carrying it, of time beyond the median clean request. Causes
#      rank by excess hours, ties by request count.
#
# Usage:  cat tracker-data.json | sh references/classify-runs.sh [--gap-minutes 60]
# Exit:   0 classified · 2 unusable input · 3 jq missing

set -u

GAP_MINUTES=60
while [ $# -gt 0 ]; do
  case "$1" in
    --gap-minutes)
      [ $# -ge 2 ] || { echo "classify-runs: --gap-minutes needs a value" >&2; exit 2; }
      GAP_MINUTES="$2"; shift 2 ;;
    --gap-minutes=*) GAP_MINUTES="${1#*=}"; shift ;;
    -h|--help) sed -n '2,40p' "$0"; exit 0 ;;
    *) echo "classify-runs: unknown argument '$1'" >&2; exit 2 ;;
  esac
done
case "$GAP_MINUTES" in
  ''|*[!0-9]*) echo "classify-runs: --gap-minutes must be a whole number of minutes" >&2; exit 2 ;;
esac

command -v jq >/dev/null 2>&1 || {
  echo "classify-runs: jq is required (the tracker descriptor already depends on it)" >&2
  exit 3
}

jq --argjson gap "$((GAP_MINUTES * 60))" '

def markers:
  [ match("🤖\\s*`?(om-[a-z0-9-]+)`?"; "g") | .captures[0].string ] | unique;

def stamp: if . == null or . == "" then null else (try fromdateiso8601 catch null) end;

def events:
  [ (.comments // [])[]
    | select(type == "object")
    | { t: ((.createdAt // null) | stamp), body: (.body // "") }
    | . as $c
    | ($c.body | markers)[]
    | { skill: ., t: $c.t }
  ];

def cluster($gap):
  sort_by(.t // 0)
  | reduce .[] as $e ({ n: 0, last: null };
      if .last == null or $e.t == null or ($e.t - .last) >= $gap
      then { n: (.n + 1), last: $e.t }
      else { n: .n, last: $e.t }
      end)
  | .n;

def runs($gap):
  events
  | group_by(.skill)
  | map({ key: .[0].skill, value: (cluster($gap)) })
  | from_entries;

def recovery_language:
  test("merge conflict|CONFLICTING|conflicts resolved|interrupted|stalled|timed out|crashed|context (limit|exhaust)|rate limit|failed run|re-?run after|blocked by"; "i");

def declared_outcomes:
  [ match("(^|\n)Outcome:[ \t]*(clean|recovered|blocked)([ \t]*[-—][ \t]*[^\n]+)?"; "g")
    | .string | sub("^\n"; "") ];

def causes($changes_requested):
  . as $text
  | [ (if ($text | test("merge conflict|CONFLICTING|conflicts resolved|rebase"; "i"))
       then "base moved under the change" else empty end),
      (if ($text | test("self-approval|approve your own|self-review rules"; "i"))
       then "review could not be recorded" else empty end),
      (if ($text | test("interrupted|stalled|timed out|crashed|context (limit|exhaust)|rate limit"; "i"))
       then "run did not finish" else empty end),
      (if $changes_requested or ($text | test("changes[- ]requested|request changes"; "i"))
       then "change requested by a reviewer" else empty end) ];

def median:
  if length == 0 then null
  else sort as $s | ($s | length) as $n
    | if ($n % 2) == 1 then $s[($n / 2 | floor)]
      else (($s[($n / 2 | floor) - 1] + $s[($n / 2 | floor)]) / 2) end
  end;
def p90: if length == 0 then null else (sort | .[((length * 0.9) | floor) | if . >= 0 then . else 0 end]) end;
def round1: if . == null then null else (. * 10 | round) / 10 end;

def classify($gap):
  . as $pr
  | (runs($gap)) as $runs
  | ([ ((.comments // [])[] | select(type == "object") | .body // "") ] | join("\n")) as $text
  | ([ ((.reviews // [])[] | select(type == "object") | .state // "") ] | any(. == "CHANGES_REQUESTED")) as $changes_requested
  | ($text | declared_outcomes) as $declared
  | [ (if (($runs["om-auto-review-pr"] // 0) >= 2) then "second review round" else empty end),
      (if ((($runs["om-auto-continue-pr"] // 0) + ($runs["om-auto-continue-pr-loop"] // 0)) > 0) then "resumed" else empty end),
      (if (($runs["om-auto-fix-pr"] // 0) > 0) then "driven to merge-ready" else empty end),
      (if (($runs["om-auto-qa-pr"] // 0) >= 2) then "second QA round" else empty end),
      (if ($pr.state == "CLOSED") then "closed unmerged" else empty end) ] as $signals
  | (($pr.createdAt // null) | stamp) as $opened
  | (($pr.mergedAt // null) | stamp) as $merged
  | {
      number: $pr.number,
      class: (
        if ($signals | length) == 0 then "clean"
        elif ($text | recovery_language) or $changes_requested or $pr.state == "CLOSED"
             or ($declared | any(test("Outcome:[ \t]*(recovered|blocked)"))) then "hard recovery"
        elif (($runs["om-auto-create-pr-loop"] // 0) + ($runs["om-auto-continue-pr-loop"] // 0)) > 0 then "loop checkpoints"
        else "unexplained" end),
      signals: $signals,
      causes: ($text | causes($changes_requested)),
      declaredOutcomes: $declared,
      hoursToMerge: (if $opened != null and $merged != null then (($merged - $opened) / 3600 | round1) else null end),
      additions: ($pr.additions // null),
      changedFiles: ($pr.changedFiles // null),
      labels: [ ((.labels // [])[] | select(type == "object") | .name // empty) ]
    };

def bucket($rows; $label; $low; $high):
  ($rows | map(select(.additions != null and .additions >= $low and .additions < $high))) as $in
  | ($in | map(select(.class == "hard recovery")) | length) as $hard
  | { addedLines: $label, prs: ($in | length), hardRecovery: $hard,
      hardRecoveryPct: (if ($in | length) == 0 then null else (($hard * 100) / ($in | length) | round) end) };

def summarize($rows; $timestamped; $total_marker_comments):
  ($rows | map(select(.class == "clean") | .hoursToMerge) | map(select(. != null))) as $clean_hours
  | (($clean_hours | median) // 0) as $baseline
  | ($rows | map(select(.class != "clean"))) as $second
  | ([ $second[] | . as $r | (if (.causes | length) == 0 then ["not stated"] else .causes end)[]
       | { cause: ., number: $r.number, excess: (if $r.hoursToMerge == null then 0 else ([($r.hoursToMerge - $baseline), 0] | max) end) } ]
     | group_by(.cause)
     | map({ cause: .[0].cause, prs: map(.number), prCount: length,
             excessHours: (map(.excess) | add | round1) })
     | sort_by([- .excessHours, - .prCount])) as $ranked
  | {
      prsWithRunMarkers: ($rows | length),
      byClass: ( reduce ["clean", "hard recovery", "loop checkpoints", "unexplained"][] as $k ({};
          . + { ($k): ( ($rows | map(select(.class == $k))) as $m
                        | ($m | map(.hoursToMerge) | map(select(. != null))) as $h
                        | { count: ($m | length), prs: ($m | map(.number)),
                            medianHoursToMerge: ($h | median | round1),
                            p90HoursToMerge: ($h | p90 | round1) } ) })),
      rankedCauses: $ranked,
      bySize: [ bucket($rows; "0-200"; 0; 200), bucket($rows; "200-600"; 200; 600), bucket($rows; "600+"; 600; 1e12) ],
      declaredOutcomeCoverage: {
        prs: ($rows | map(select((.declaredOutcomes | length) > 0)) | length),
        pct: (if ($rows | length) == 0 then 0 else (($rows | map(select((.declaredOutcomes | length) > 0)) | length) * 100 / ($rows | length) | round) end),
        unexplainedSecondPasses: ($rows | map(select(.class == "unexplained")) | length)
      },
      timestampCoverage: { markerComments: $total_marker_comments, withTimestamp: $timestamped,
        note: (if $total_marker_comments > 0 and $timestamped < $total_marker_comments
               then "some marker comments carry no timestamp, so run counts are an upper bound"
               else "every marker comment carried a timestamp" end) },
      cleanMedianHoursToMerge: (if ($clean_hours | length) == 0 then null else ($baseline | round1) end)
    };

if type != "array" then
  { error: "expected a JSON array of pull requests" }
else
  ( map(select(type == "object")) ) as $prs
  | ( [ $prs[] | (.comments // [])[] | select(type == "object")
        | select(((.body // "") | markers | length) > 0) ] ) as $marker_comments
  | ( $marker_comments | length ) as $total_marker_comments
  | ( $marker_comments | map(select((.createdAt // null) != null)) | length ) as $timestamped
  | ( [ $prs[] | select((events | length) > 0) | classify($gap) ] ) as $rows
  | if ($rows | length) == 0
    then { prsWithRunMarkers: 0, note: "no pull request carried an agent run marker" }
    else { summary: summarize($rows; $timestamped; $total_marker_comments), pullRequests: $rows }
    end
end
' || {
  status=$?
  echo "classify-runs: stdin is not usable JSON (jq exit $status)" >&2
  exit 2
}
