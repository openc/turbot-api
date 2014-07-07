#!/bin/bash

UNPUSHED=$(git log origin/master..HEAD)
if [ "x$UNPUSHED" == "x" ]; then
    gem build turbot_api.gemspec
    gem push $(ls *gem|tail -1)
fi

function clean {
 rm *gem
}
trap clean EXIT
