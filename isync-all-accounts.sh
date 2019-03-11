#!/bin/sh

cd -- "$(dirname "$0")" || exit 1

configdir="${1:-config.d}"

if [ ! -d "$configdir" ]; then
	echo >&2 "Usage: $0 <configdir>"
	exit 1
fi

logfile=bckall.log
>"$logfile"
err=0
for cfg in "$configdir"/*.conf; do
	echo "" >>"$logfile"
	echo "#### $cfg" >>"$logfile"
	./isync-account.sh "$cfg" >>"$logfile" 2>&1
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "# Status: ERROR ($ret)" >>"$logfile"
		err=1
	else
		echo "# Status: SUCCESS" >>"$logfile"
	fi
	echo "###################################" >>"$logfile"
done
if [ $err -ne 0 ]; then
	cat -- "$logfile"
fi

exit $err
