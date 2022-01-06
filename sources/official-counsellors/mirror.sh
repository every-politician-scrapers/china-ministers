#!/bin/bash

cd $(dirname $0)

CURLOPTS='-L -c /tmp/cookies -A eps/1.2'
curl $CURLOPTS -o official.html $(jq -r .source.url meta.json)

cd -
