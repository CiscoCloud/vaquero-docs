#!/bin/bash
git config remote.origin.url "https://6db5d6b384651628616ecc2c022c99c04b963cbe@github.com/CiscoCloud/vaquero-docs.git"
git config --global user.name gem-test
git config --global user.email gemini.atlas@gmail.com
git config --list
git checkout debian
curl https://api.github.com/repos/CiscoCloud/vaquero-docs/tags > tags.json
RECENT="$(git describe --abbrev=0 --tags)"
rm -rf vaquero-docs
if [ ! -d $RECENT ]; then
  FILES=docs/current/*.md
  for f in $FILES
  do
    echo Converting $f...
    pandoc $f -o $f.html
  done
  mkdir docs/$RECENT #create version dir
  cp docs/current/*html docs/$RECENT/
  cp docs/current/*png docs/$RECENT/
  cp docs/current/*jpg docs/$RECENT/
fi

git status
git push origin --tags -f
git add .
git commit -m "Pushed $NEW_TAG to site"
git push origin master

rm docs/current/*.html
