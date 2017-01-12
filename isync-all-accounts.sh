#!/bin/sh

cd -- "$(dirname "$0")" || exit 1

configdir="${1:-config.d}"

if [ ! -d "$configdir" ]; then
	echo >&2 "Usage: $0 <configdir>"
	exit 1
fi

err=0
for cfg in "$configdir"/*.conf; do
	echo ""
	echo "#### $cfg"
	./isync-account.sh "$cfg"
	ret=$?
	if [ $ret -ne 0 ]; then
		echo "# Status: ERROR ($ret)"
		err=1
	else
		echo "# Status: SUCCESS"
	fi
	echo "###################################"
done 2>&1 |tee bckall.log

exit $err
