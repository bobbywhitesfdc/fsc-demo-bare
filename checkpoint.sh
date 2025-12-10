#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}



#--ignore-conflicts
sf project retrieve start --ignore-conflicts  -o "$(prop 'default.env.alias' )"
git add -A .
CURRENTDATE=`date +"%Y-%m-%d %T"`
echo "checkpoint $CURRENTDATE"
git commit -m "checkpoint $CURRENTDATE"