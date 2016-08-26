#!/bin/bash
set -u


TARGET="docs/current"
if [[ $DRONE_BRANCH != master ]]; then
    TARGET="docs/branches/${DRONE_BRANCH/\//--}"
elif [[ -n ${DRONE_TAG:-} ]]; then
    TARGET="docs/${DRONE_TAG}"
fi

mkdir -vp "${TARGET}"
FILES=docs/current/*.md
for src in docs/current/*.md; do
    dst="${TARGET}/$(basename "${src}" .md).html"
    echo Converting ${src} to ${dst}...
    pandoc "${src}" -o "${dst}"
done
git add "${TARGET}"

curl https://api.github.com/repos/CiscoCloud/vaquero-docs/tags > tags.json
git remote set-url origin https://github.com/CiscoCloud/vaquero-docs.git
git add "tags.json"
git status
