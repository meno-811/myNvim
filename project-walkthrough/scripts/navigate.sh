#!/usr/bin/env bash
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
lua_script="$script_dir/navigate.lua"

if [[ -z ${NVIM:-} ]]; then
  printf 'project-walkthrough: NVIM is not set; use path:line references instead\n' >&2
  exit 2
fi

if [[ ${1:-} == "--clear" ]]; then
  nvim --server "$NVIM" --remote-expr "luaeval(\"(dofile([[$lua_script]])).clear()\")"
  exit
fi

if (( $# < 1 || $# > 3 )); then
  printf 'usage: %s FILE [START_LINE [END_LINE]]\n' "$0" >&2
  exit 2
fi

file=$1
start_line=${2:-1}
end_line=${3:-$start_line}

if [[ ! $start_line =~ ^[1-9][0-9]*$ || ! $end_line =~ ^[1-9][0-9]*$ ]]; then
  printf 'project-walkthrough: line numbers must be positive integers\n' >&2
  exit 2
fi

if [[ ! -f $file ]]; then
  printf 'project-walkthrough: file not found: %s\n' "$file" >&2
  exit 2
fi

file=$(realpath -- "$file")
request=$(mktemp /tmp/project-walkthrough.XXXXXX)
trap 'rm -f "$request"' EXIT
printf '%s\n%s\n%s\n' "$file" "$start_line" "$end_line" > "$request"

nvim --server "$NVIM" --remote-expr "luaeval(\"(dofile([[$lua_script]])).navigate([[$request]])\")"
