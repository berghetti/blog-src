#!/bin/bash

#
# fetch changes made online (i.e stackedit.io)
git pull

# generate static files in public folder
pushd blog
hugo
popd

#push public folder to cloud (i.e github)
pushd blog/public
git add .
git commit -m "update blog"
git push
popd
