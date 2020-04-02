#!/bin/bash

HUGO_FILENAME="hugo_${HUGO_RELEASE}_Linux-64bit"
HUGO_TARFILE="${HUGO_FILENAME}.tar.gz"

wget https://github.com/gohugoio/hugo/releases/download/v$HUGO_RELEASE/$HUGO_TARFILE
tar xfz $HUGO_TARFILE
mv $HUGO_FILENAME/$HUGO_FILENAME ./hugo
rm -rf $HUGO_FILENAME
