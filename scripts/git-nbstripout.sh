#!/usr/bin/env bash

REPO_ROOT="$(git rev-parse --show-toplevel)"
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)

if [ -f "$REPO_ROOT/.venv/Scripts/nbstripout.exe" ]; then
    NBSTRIPOUT="$REPO_ROOT/.venv/Scripts/nbstripout.exe"
elif [ -f "$REPO_ROOT/.venv/bin/nbstripout" ]; then
    NBSTRIPOUT="$REPO_ROOT/.venv/bin/nbstripout"
else
    NBSTRIPOUT="nbstripout"
fi

if [ "$CURRENT_BRANCH" = "main" ]; then
    "$NBSTRIPOUT" "$@"
else
    "$NBSTRIPOUT" --keep-count "$@"
fi