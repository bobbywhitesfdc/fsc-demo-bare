#!/bin/bash
# Exit on error!
set -euxo pipefail
#create scratch org
sfdx force:org:create -f config/project-scratch-def.json -s -a FSCDEMO 

#package installs of the main FSC package
# Working around deprecation issues by allowing hand editing
# See ./packages/installedPackage/FinServ.installedPackage
sfdx force:mdapi:deploy -d packages -w 20 

sfdx force:package:install --package 04t1E000001Iql5 -w 20
sfdx force:user:permset:assign -n FinancialServicesCloudStandard

sfdx force:org:open

