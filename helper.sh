#!/bin/sh

remrule() {
	FILE="build/output.cocci"
	if [ -n "$2" ]; then
		FILE=$2
	fi
	perl -0777 -pi -e \
		"s/@ r$1 @.*@ script:python depends on r$1 @.*?@ /@ /s" \
		$FILE
	perl -pi -e "s/^(rules = \[)\b$1\b(\])/\1\2/" $FILE
	perl -pi -e "s/^(rules = .*)\b$1\b, (.*)/\1\2/" $FILE
	perl -pi -e "s/^(rules = .*), \b$1\b(.*)/\1\2/" $FILE
}

case "$1" in

	"remrule")
		remrule "$2" "$3"
		;;

esac
