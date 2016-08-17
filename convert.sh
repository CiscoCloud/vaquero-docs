#!/bin/bash
rm docs/current/*.html #ensure that the conversions output new files
RECENT="$(git describe --abbrev=0 --tags)"
git checkout gh-pages
curl https://api.github.com/repos/CiscoCloud/vaquero-docs/tags > tags.json
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
git add .
git commit -m "Pushed $RECENT to site"
git push origin master
