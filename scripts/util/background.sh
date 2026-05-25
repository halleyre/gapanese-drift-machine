#! /bin/env echo source-me

TIMESTAMP=`date +%Y%m%d-%H%M%S`
LOGDIR="$ROOT/logs/misc"
KILL_SCRIPT="$TMPSCRIPTS/heyproj-bg-misc-$TIMESTAMP"

background() {
  LOG="$LOGDIR/$TIMESTAMP.log"

  mkdir -p "$LOGDIR"
  $@ > "$LOG" 2>&1 &
  PID=$!
  cat "$ROOT/scripts/util/background-hook.sh" \
  	| sed "s:{{PID}}:$PID:"             \
  	| sed "s:{{LOG}}:$LOG:"             \
  	> "$KILL_SCRIPT"
  chmod +x "$KILL_SCRIPT"
}
