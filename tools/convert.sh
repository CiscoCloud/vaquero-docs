#!/bin/bash
set -ue

if ! which pandoc > /dev/null; then
  echo "You are missing pandoc command, please install it for your OS"
  exit
fi

DIR=generate
rm -rf ${DIR}
mkdir -p ${DIR}
git clone -b gh-pages $(git config remote.origin.url) "${DIR}"

TARGET="${DIR}/docs/current"
if [[ -n ${DRONE_TAG:-} ]]; then
    TARGET="${DIR}/docs/${DRONE_TAG}"
elif [[ "${DRONE_BRANCH:=master}" != master ]]; then
    TARGET="${DIR}/docs/branches/${DRONE_BRANCH/\//--}"
fi

mkdir -vp "${TARGET}"
for src in docs/current/*.md; do
    dst="${TARGET}/$(basename "${src}" .md).html"
    echo Converting ${src} to ${dst}...
    pandoc "${src}" -o "${dst}"
done

cp docs/current/*.png ${TARGET}
if [[ "${DRONE_BRANCH:-master}" == master ]]; then
    cp * ${DIR} | true
fi
