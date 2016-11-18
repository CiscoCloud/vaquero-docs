#!/bin/bash
set -ue

TMP=$(mktemp -d -p "/drone")
git clone -b gh-pages $(git config remote.origin.url) "${TMP}"

TARGET="${TMP}/docs/current"
if [[ -n ${DRONE_TAG:-} ]]; then
    TARGET="${TMP}/docs/${DRONE_TAG}"
elif [[ $DRONE_BRANCH != master ]]; then
    TARGET="${TMP}/docs/branches/${DRONE_BRANCH/\//--}"
fi

mkdir -vp "${TARGET}"
for src in docs/current/*.md; do
    dst="${TARGET}/$(basename "${src}" .md).html"
    echo Converting ${src} to ${dst}...
    pandoc "${src}" -o "${dst}"
done

cp docs/current/*.png ${TARGET}
cp * ${TMP} | true
