#!/bin/bash
#git config remote.origin.url "https://e319a829365cb5295dbeb5ad25bbc66d6365cdd3@github.com/CiscoCloud/vaquero-docs.git"
#git config --global user.name meganokeefe
#git config --global user.email megan037@gmail.com
#git config --list


git config user.email "megan037@gmail.com"
git config user.name "meganokeefe"
rm -rf vaquero-docs #remove if it exists
git clone https://github.com/CiscoCloud/vaquero-docs.git
cd vaquero-docs
curl https://api.github.com/repos/CiscoCloud/vaquero-docs/tags > tags.json

rm docs/current/*.html #ensure that the conversions output new files
RECENT="$(git describe --abbrev=0 --tags)"
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
git commit -m "Pushed $NEW_TAG to site"
git push origin master
