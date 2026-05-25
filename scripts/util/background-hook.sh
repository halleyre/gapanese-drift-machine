#!/usr/bin/env bash

PID={{PID}}
LOG={{LOG}}

while (($#)); do
	case "$1" in
		-l | --logs) OPEN_LOG=true ;;
		-k | --kill) KILL=true ;;
	esac
	shift
done

[[ -n $OPEN_LOG ]] && less $LOG || tail $LOG

if [[ -n $KILL ]] then
	kill $PID || echo "$PID not found"
	rm -- ${BASH_SOURCE[0]}
fi
