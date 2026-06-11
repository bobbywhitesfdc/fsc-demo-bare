#!/bin/bash
# Exit on error!
set -euo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}

# Create directory structure
mkdir -p bulk_results/working

# Function to run bulk upsert, capture job ID, and analyze with sf bulk analyze
run_bulk_upsert() {
    local file=$1
    local object=$2
    local extid=$3
    local name=$4

    echo "Loading $name..."

    local output=$(sf data upsert bulk -o "$(prop 'default.env.alias')" -f "$file" -s "$object" -i "$extid" -w 20 --json 2>/dev/null)
    echo "$output" > "bulk_results/working/${name}_load.json"

    local job_id=$(echo "$output" | jq -r '.result.jobInfo.id // empty' 2>/dev/null)

    if [ -z "$job_id" ]; then
        job_id=$(echo "$output" | grep -oE '750[a-zA-Z0-9]{15}' | head -1)
    fi

    if [ -z "$job_id" ]; then
        echo "  WARNING: Could not extract job ID for $name"
        return 1
    fi

    sf bulk analyze "$job_id" --target-org "$(prop 'default.env.alias')" --json 2>/dev/null \
        > "bulk_results/working/${name}_analysis.json"

    local records_processed=$(jq -r '.result.jobInfo.numberRecordsProcessed // 0' "bulk_results/working/${name}_analysis.json")
    local records_failed=$(jq -r '.result.jobInfo.numberRecordsFailed // 0' "bulk_results/working/${name}_analysis.json")

    if [ "$records_failed" -gt 0 ]; then
        echo "  ⚠️  $records_failed failures"
    else
        echo "  ✓  Success"
    fi

    echo "$name,$records_processed,$records_failed" >> bulk_results/load_summary.csv
}

# Main execution
echo "========================================"
echo "Bulk Data Load"
echo "Target org: $(prop 'default.env.alias')"
echo "Started at: $(date)"
echo "========================================"
echo ""

# Initialize summary CSV
echo "Object,Records Processed,Records Failed" > bulk_results/load_summary.csv

run_bulk_upsert "data/persons.csv" "Account" "MM_Member_Id__c" "persons"
run_bulk_upsert "data/businesses.csv" "Account" "MM_Member_Id__c" "businesses"
run_bulk_upsert "data/partners.csv" "Account" "Agency_BP_Id__c" "partners"
run_bulk_upsert "data/contacts.csv" "Contact" "Producer_BP_Id__c" "contacts"
run_bulk_upsert "data/producers.csv" "Producer" "Producer_External_Id__c" "producers"
run_bulk_upsert "data/policy.csv" "InsurancePolicy" "Agreement_Key__c" "policy"
run_bulk_upsert "data/ipp.csv" "InsurancePolicyParticipant" "Policy_Participant_External_Id__c" "ipp"
run_bulk_upsert "data/ipp_stubbed.csv" "InsurancePolicyParticipant" "Policy_Participant_External_Id__c" "ipp_stubbed"
run_bulk_upsert "data/ProducerPolicyAssignment.csv" "ProducerPolicyAssignment" "PPA_External_Id__c" "ppa"
#run_bulk_upsert "data/households.csv" "Account" "MM_Member_Id__c" "households"
#run_bulk_upsert "data/acr.csv" "AccountContactRelation" "ACR_Ext_Id__c" "acr"
#run_bulk_upsert "data/aar.csv" "AccountRelationship" "AA_External_Id__c" "aar"

echo ""
echo "========================================"
echo "Load Complete"
echo "Completed at: $(date)"
echo "========================================"
echo ""

# Show summary
echo "Summary:"
column -t -s',' bulk_results/load_summary.csv
echo ""

# Check for failures
any_failures=false
for analysis in bulk_results/working/*_analysis.json; do
    [ -f "$analysis" ] || continue
    failed=$(jq -r '.result.jobInfo.numberRecordsFailed // 0' "$analysis")
    if [ "$failed" -gt 0 ]; then
        any_failures=true
        name=$(basename "$analysis" _analysis.json)
        echo "  $name — top errors:"
        jq -r '.result.summary.level1[] | "    \(.count)x \(.signature)"' "$analysis"
    fi
done

if [ "$any_failures" = false ]; then
    echo "✓  All records loaded successfully!"
fi

echo ""
echo "Results:"
echo "  - bulk_results/load_summary.csv  : Summary of all loads"
echo "  - bulk_results/working/          : Full analysis JSON per object"