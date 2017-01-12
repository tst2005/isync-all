#!/bin/sh

cd -- "$(dirname "$0")" || exit 1

if [ $# -eq 0 ] || [ ! -f "$1" ]; then
	echo "Usage: $0 config.d/file.conf"
	exit 1
fi
. "$1"

mkdir -p -- "$localdir"

isynclessverbose() {
	grep -E -v '^(Channel |Opening |Resolving |Connecting |Connection is now encrypted|Logging |Selecting |Loading |Synchronizing)'
}
isyncgetstats() {
	grep '^master: ' | sed -e 's/^master: \([0-9]\+\) messages, \([0-9]\+\) recent$/\1 emails/g';
	#grep '^slave: ' | sed -e 's/^slave: \([0-9]\+\) messages, \([0-9]\+\) recent$/\2 unread \/ \1/g';
}

mysync() {
	isync -f -p "$port" -s "imaps:$host" -u "$user" -P "$pass" "$@";
}
mysubsync() {
	local subdir="$1";shift;
	local lvl="$1";shift;
	printf '[%s] %s\n' "$lvl" "$subdir"
	mysync -F "$subdir" "$@";
}

SUBDIRSUFFIX='.DIR'
#MAILDIRSUFFIX=''

ifind() {
	local dir="$1";shift;
	local lvl=$(( ${lvl:--1} + 1 ))

	local bckdir="${bckdir:-}"
	local into=''
	if [ -z "$pdir" ]; then
		if [ -z "$dir" ]; then
			#into="$localdir/${bckdir:-ROOTDIR}"
			into=''
		else
			into="$localdir/${bckdir:-}"
		fi
	else
		into="$localdir/${bckdir:-$dir}"
	fi

	#printf '# [%s] %'"$(($lvl*2))"'s %s (%s)\n' "$lvl" "-" "$dir" "$into"
	printf '# [%s] %-80s (%-80s) ' "$lvl" "${pdir:+$pdir/}${dir}" "$into + $dir"

	if [ -n "$into" ]; then

		[ -d "$into" ] || mkdir -p -- "$into"
		local stats
		if [ -z "$pdir" ]; then
			# master: 252 messages, 0 recent
			# slave: 252 messages, 174 recent
			stats="$(mysync -1 -L -M "$into" "$dir" | isyncgetstats)"
		else
			stats="$(mysync -1 -L -M "$into/" -F "$pdir/" "$dir" | isyncgetstats)"
		fi
		printf '(%s)' "$stats"
	fi
	printf '\n'

	mysync -a -1 -q -F "${pdir:+$pdir/}${dir:+$dir/}" -l \
	| sort \
	| (
		local pdir="${pdir:+$pdir/}$dir"
		local bckdir="${bckdir:+$bckdir/}${dir:+$dir$SUBDIRSUFFIX}"
		while read -r subdir; do
			ifind "$subdir"
		done
	)
}

ifind ""

