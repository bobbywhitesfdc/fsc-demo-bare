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

# MANUAL INTERVENTION REQUIRED AFTER THIS STEP
sf org open

echo "You must complete manual steps before continuing"
cat < ./manual_steps.txt
read -p "Press Enter to continue..."


# Limited customization required for data loading
sf project deploy start -w 20
sf org assign permset -n FSC_Data_Load


