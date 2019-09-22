#!/bin/bash
#
# pre-commit for inopinatus/sublime_url
#
# Check that the staged contents of src/ matches the staged decompilation of
# SublimeUrl.app/Contents/Resources/Scripts/ and that correct whitespace has
# been used.
#

SCPTDIR=SublimeUrl.app/Contents/Resources/Scripts
TXTDIR=src
DECOMP=/usr/bin/osadecompile
GIT=git
CMP="cmp -s"
GREP=grep

declare -a errors actions
error () {
	errors+=("$1: $2")
}
action () {
	actions+=("$1")
}
list () {
	for item in "${!1}"; do
		echo -e "* $item"
	done
}

check_staged () {
	scpt="${SCPTDIR}/$1"
	txt="${TXTDIR}/$2"

	tmp_bin=$(mktemp -t staged-binary)
	tmp_txt=$(mktemp -t staged-text)

	$GIT show ":${scpt}" > "$tmp_bin"
	$GIT show ":${txt}"  > "$tmp_txt"

	# All indent must be tabs, and all tabs must be indent.
	if $DECOMP "$tmp_bin" | grep -v '^$' | grep -qv '^\t*\S'; then
		error "$scpt" "has non-tab indentation"
		action "ensure all indent within ${scpt} uses tabs"
	fi

	# Lines may not terminate with whitespace.
	if $DECOMP "$tmp_bin" | grep -q '\s$'; then
		error "$scpt" "has trailing whitespace"
		action "clear trailing whitespace within ${scpt}"
	fi

	# text must match decompiled binary
	if ! $DECOMP "$tmp_bin" | $CMP "$tmp_txt"; then
		error "$txt" "does not match decompiled ${scpt}"
		action "re-run decompile.sh"
		action "commit ${scpt} and ${txt} together"
	fi

	rm "$tmp_bin" "$tmp_txt"
}


echo "==> Running pre-commit checks"

check_staged jsHandler.scpt jsHandler.scpt.js
check_staged main.scpt main.scpt.script

if [ -n "$errors" ]; then
	echo -e "\n==> pre-commit errors:"
	list errors[@]
fi

if [ -n "$actions" ]; then
	echo -e "\n==> action required:"
	list actions[@]
fi

if [ -n "$errors" -o -n "$actions" ]; then
	exit 1
fi
