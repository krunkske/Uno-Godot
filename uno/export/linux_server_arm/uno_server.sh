#!/bin/sh
echo -ne '\033c\033]0;Uno\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/uno_server.arm64" "$@"
