#!/usr/bin/env bash
set -ue

git remote add upstream git@github.com:CiscoCloud/vaquero-docs.git || true
git fetch upstream
git branch -D gh-pages || true      # ignore errors

DIR="generate"
if ! expr $(git status --porcelain | egrep '^(M| M|\?\?)' | wc -l) = 0; then
    DRY_RUN="--dry-run"
fi

git checkout -b gh-pages upstream/gh-pages

rsync -av ${DRY_RUN:-} --delete-after --exclude ".git" "${DIR}/" .
