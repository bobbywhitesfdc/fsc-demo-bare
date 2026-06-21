#!/bin/bash
# Exit on error!
set -euxo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}
#create scratch org
# let it auto-assign the username ( username="$(prop 'user.admin' )" )
# devhub.alias is optional: if set in project.properties, pass --target-dev-hub; otherwise omit and use the CLI default
DEVHUB="$(prop 'devhub.alias' || true)"
DEVHUB_FLAG=""
if [ -n "${DEVHUB}" ]; then
    DEVHUB_FLAG="--target-dev-hub ${DEVHUB}"
fi
sf org create scratch -f config/project-scratch-def.json -a "$(prop 'default.env.alias' )" --username="$(prop 'user.admin' )" ${DEVHUB_FLAG} --set-default --duration-days 28

sf org assign permsetlicense -n FinServ_FinancialServicesCloudStandardPsl
sf org assign permsetlicense -n FSCInsurancePsl

# Limited customization required for data loading
sf project deploy start -w 20
sf org assign permset -n FSC_Data_Load


