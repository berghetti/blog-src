#!/bin/bash

#
# fetch changes made online (i.e stackedit.io)
echo "Update from guthub"
git pull > /dev/null

# generate static files in public folder
echo "Creating files in public folder"
pushd blog > /dev/null
hugo --minify
popd

#push public folder to cloud (i.e github)
echo "Pushing blog in guthub"
pushd blog/public
git add .
git commit -m "update blog"
git push > /dev/null
popd
