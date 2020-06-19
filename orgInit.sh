#!/bin/bash
# Exit on error!
set -euxo pipefail
#create scratch org
sfdx force:org:create -f config/project-scratch-def.json -s -a FSCDEMO 

#pckg installs
sfdx force:mdapi:deploy -d packages -w 20 

#sfdx force:package:install --package 04t1E000000cmtN -w 20

sfdx force:package:install --package 04t1E000001Iql5 -w 20

sfdx force:mdapi:deploy --deploydir mdapi-source/app-config

sfdx force:mdapi:deploy --deploydir mdapi-source/data-config

sfdx force:mdapi:deploy --deploydir mdapi-source/org-config

sfdx force:source:push 

sfdx force:user:permset:assign -n FinancialServicesCloudStandard

sfdx force:apex:execute -f config/create-demo-data-setup.apex
sfdx force:apex:execute -f config/create-demo-data.apex


sfdx force:org:open

