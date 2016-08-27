#!/bin/bash
set -ue

TMP=$(mktemp -d -p "/drone")
git clone -b gh-pages $(git config remote.origin.url) "${TMP}"

TARGET="${TMP}/docs/current"
if [[ $DRONE_BRANCH != master ]]; then
    TARGET="${TMP}/docs/branches/${DRONE_BRANCH/\//--}"
elif [[ -n ${DRONE_TAG:-} ]]; then
    TARGET="${TMP}/docs/${DRONE_TAG}"
fi

mkdir -vp "${TARGET}"
for src in docs/current/*.md; do
    dst="${TARGET}/$(basename "${src}" .md).html"
    echo Converting ${src} to ${dst}...
    pandoc "${src}" -o "${dst}"
done

