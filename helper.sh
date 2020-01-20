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

fix_c_bugs() {
	FILE="build/output.c"
	if [ -n "$1" ]; then
		FILE=$1
	fi
	perl -0777 -pi -e \
		"s/__typeof__(.*?) cocci_id(\/\*.*\*\/)?\[.*?\][A-Z_]*(.*?);//s" \
		$FILE
}

case "$1" in

	"remrule")
		remrule "$2" "$3"
		;;

	"fix_c_bugs")
		fix_c_bugs "$2"
		;;

esac
