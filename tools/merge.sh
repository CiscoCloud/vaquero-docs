#!/usr/bin/env bash
set -x
set -ue

git branch -D gh-pages
git fetch origin gh-pages:gh-pages

DIR="/drone/$(ls /drone | grep -v src)"
if ! expr $(git status --porcelain | egrep '^(M| M|\?\?)' | wc -l) = 0; then
    DRY_RUN="--dry-run"
fi

git checkout -q gh-pages

rsync -av ${DRY_RUN:-} --delete-delay --exclude ".git" "${DIR}/" .

