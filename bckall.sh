#!/bin/sh

cd -- "$(dirname "$0")" || exit 1

err=0
for cfg in config.d/*.conf; do
	echo ""
	echo "#### $cfg"
	./bck.sh "$cfg"
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
