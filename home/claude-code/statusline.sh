#!/bin/bash
input=$(cat)

mapfile -t vals < <(echo "$input" | jq -r '
  (.model.display_name // "unknown"),
  (.workspace.current_dir // ""),
  ((.context_window.used_percentage // 0) | floor | tostring),
  (.cost.total_cost_usd // 0 | tostring),
  ((.rate_limits.five_hour.used_percentage // 0) | floor | tostring),
  (.rate_limits.five_hour.resets_at // 0 | tostring),
  ((.rate_limits.seven_day.used_percentage // 0) | floor | tostring),
  (.rate_limits.seven_day.resets_at // 0 | tostring)
')
MODEL="${vals[0]}"
FULL_CWD="${vals[1]}"
PCT="${vals[2]}"
COST="${vals[3]}"
FIVE_H_PCT="${vals[4]}"
FIVE_H_RESET="${vals[5]}"
SEVEN_D_PCT="${vals[6]}"
SEVEN_D_RESET="${vals[7]}"

CWD="${FULL_CWD/#$HOME/\~}"

make_bar() {
  local pct=${1:-0} width=10 i filled bar=""
  filled=$(( (pct * width + 50) / 100 ))
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt "$width" ] && filled=$width
  for (( i=0; i<filled; i++ )); do bar="${bar}█"; done
  for (( i=filled; i<width; i++ )); do bar="${bar}░"; done
  echo "$bar"
}

fmt_countdown() {
  local reset=${1:-0} diff d h m
  [ "$reset" = "0" ] && return
  diff=$(( reset - $(date +%s) ))
  [ "$diff" -le 0 ] && echo "now" && return
  d=$(( diff / 86400 ))
  h=$(( (diff % 86400) / 3600 ))
  m=$(( (diff % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%02dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%02dm' "$h" "$m"
  else                      printf '%dm' "$m"
  fi
}

LINE2="$CWD"
if git rev-parse --git-dir > /dev/null 2>&1; then
  REPO=$(git rev-parse --show-toplevel 2>/dev/null)
  REPO="${REPO##*/}"
  BRANCH=$(git branch --show-current 2>/dev/null)
  LINE2="$CWD | ⬢ $REPO ⎇ $BRANCH"
fi

CTX_BAR=$(make_bar "$PCT")
FIVE_BAR=$(make_bar "$FIVE_H_PCT")
SEVEN_BAR=$(make_bar "$SEVEN_D_PCT")

FIVE_CD=$(fmt_countdown "$FIVE_H_RESET")
SEVEN_CD=$(fmt_countdown "$SEVEN_D_RESET")
[ -n "$FIVE_CD" ] && FIVE_CD=" $FIVE_CD"
[ -n "$SEVEN_CD" ] && SEVEN_CD=" $SEVEN_CD"

printf -v COST_FMT '$%.2f' "$COST" 2>/dev/null || COST_FMT="\$$COST"

echo "$LINE2 | ◆ $MODEL | ⬡ $CTX_BAR ${PCT}% | ↺ 5h $FIVE_BAR$FIVE_CD | ↺ 7d $SEVEN_BAR$SEVEN_CD | $COST_FMT"
