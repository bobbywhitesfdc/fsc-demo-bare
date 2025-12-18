#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}
#create scratch org
# let it auto-assign the username ( username="$(prop 'user.admin' )" )
sf org create scratch -f config/project-scratch-def.json -a "$(prop 'default.env.alias' )" --username="$(prop 'user.admin' )" --set-default --duration-days 28

sf org assign permsetlicense -n FinServ_FinancialServicesCloudStandardPsl
sf org assign permsetlicense -n FSCInsurancePsl
sf org assign permset -n FSC_Data_Load

# Limited customization required for data loading
#sf project deploy start -w 20

#sfdx force:apex:execute -f scripts/apex/fixroles.apex

sf org open
