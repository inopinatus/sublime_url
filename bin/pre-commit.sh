#!/bin/bash
#
# Lint src for compilation and whitespace.
#

failed=0
fail () {
	printf '* %s: %s\n' "$1" "$2"
	failed=1
}

check_staged () {
	local txt="$1"
	local lang="${2:-}"
	local tmp_dir tmp_txt tmp_out tmp_err
	local -a osacompile_args=()

	tmp_dir=$(mktemp -d) || {
		fail "$txt" "cannot create temp directory"
		return
	}
	tmp_txt="$tmp_dir/source"
	tmp_out="$tmp_dir/out.scpt"
	tmp_err="$tmp_dir/osacompile.err"

	if ! git show ":${txt}" > "$tmp_txt"; then
		fail "$txt" "cannot read staged source"
	else
		# indentation must use tabs
		if grep -q '^[[:space:]]* ' "$tmp_txt"; then
			fail "$txt" "has non-tab indentation"
		fi

		# no trailing whitespace
		if grep -q '[[:space:]]$' "$tmp_txt"; then
			fail "$txt" "has trailing whitespace"
		fi

		# must compile
		if [ -n "$lang" ]; then
			osacompile_args=(-l "$lang")
		fi
		if ! osacompile "${osacompile_args[@]}" -o "$tmp_out" "$tmp_txt" 2> "$tmp_err"; then
			fail "$txt" "fails to compile: $(tr '\n' ' ' < "$tmp_err")"
		fi
	fi

	rm -rf "$tmp_dir"
}

printf '==> Running pre-commit checks\n'

check_staged src/url-handler.jxa.js JavaScript
check_staged src/main.applescript
exit "$failed"
