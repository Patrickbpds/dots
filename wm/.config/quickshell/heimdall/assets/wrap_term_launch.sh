#!/usr/bin/env sh

cat ~/.local/state/heimdall/sequences.txt 2>/dev/null

exec "$@"
