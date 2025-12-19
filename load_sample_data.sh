#!/bin/bash
# Exit on error!
set -euo pipefail

function prop {
    grep "${1}" project.properties|cut -d'=' -f2
}

# Create directory structure
mkdir -p bulk_results/failures
mkdir -p bulk_results/working

# Get org info and access token
get_org_info() {
    sf org display --json > bulk_results/working/org_info.json 2>/dev/null
    ORG_INSTANCE=$(jq -r '.result.instanceUrl' bulk_results/working/org_info.json)
    ACCESS_TOKEN=$(jq -r '.result.accessToken' bulk_results/working/org_info.json)
    API_VERSION="v62.0"
}

# Function to run bulk upsert, capture job ID, and download results
run_bulk_upsert() {
    local file=$1
    local object=$2
    local extid=$3
    local name=$4
    
    echo "Loading $name..."
    
    # Run the bulk upsert and capture output as JSON (suppress warnings)
    local output=$(sf data upsert bulk -f "$file" -s "$object" -i "$extid" -w 20 --json 2>/dev/null)
    echo "$output" > "bulk_results/working/${name}_load.json"
    
    # Extract job ID from JSON response
    local job_id=$(echo "$output" | jq -r '.result.jobInfo.id // empty' 2>/dev/null)
    
    # Fallback to regex if JSON parsing fails
    if [ -z "$job_id" ]; then
        job_id=$(echo "$output" | grep -oE '750[a-zA-Z0-9]{15}' | head -1)
    fi
    
    if [ -z "$job_id" ]; then
        echo "  ⚠️  WARNING: Could not extract job ID for $name"
        return 1
    fi
    
    # Wait for job to complete
    sleep 3
    
    # Download failed results using Bulk API REST endpoint
    curl -s "${ORG_INSTANCE}/services/data/${API_VERSION}/jobs/ingest/${job_id}/failedResults/" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Accept: text/csv" \
        -o "bulk_results/working/${name}_failed.csv" 2>/dev/null
    
    # Download successful results (optional - only if you need them)
    curl -s "${ORG_INSTANCE}/services/data/${API_VERSION}/jobs/ingest/${job_id}/successfulResults/" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Accept: text/csv" \
        -o "bulk_results/working/${name}_successful.csv" 2>/dev/null
    
    # Get job info via REST API
    curl -s "${ORG_INSTANCE}/services/data/${API_VERSION}/jobs/ingest/${job_id}" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        | jq '.' > "bulk_results/working/${name}_job_info.json" 2>/dev/null
    
    # Check if there are actual failures
    local failed_count=0
    if [ -s "bulk_results/working/${name}_failed.csv" ]; then
        failed_count=$(($(wc -l < "bulk_results/working/${name}_failed.csv") - 1))
        
        # Only copy to failures directory if there are actual failed records
        if [ "$failed_count" -gt 0 ]; then
            cp "bulk_results/working/${name}_failed.csv" "bulk_results/failures/${name}_failed.csv"
            echo "  ⚠️  $failed_count failures"
        else
            echo "  ✓  Success"
        fi
    else
        echo "  ✓  Success"
    fi
    
    # Generate summary
    local records_processed=$(jq -r '.numberRecordsProcessed // 0' "bulk_results/working/${name}_job_info.json" 2>/dev/null)
    local records_failed=$(jq -r '.numberRecordsFailed // 0' "bulk_results/working/${name}_job_info.json" 2>/dev/null)
    
    echo "$name,$records_processed,$records_failed" >> bulk_results/load_summary.csv
}

# Main execution
echo "========================================"
echo "Bulk Data Load"
echo "Started at: $(date)"
echo "========================================"
echo ""

# Initialize summary CSV
echo "Object,Records Processed,Records Failed" > bulk_results/load_summary.csv

# Get org credentials once
get_org_info

#run_bulk_upsert "data/households.csv" "Account" "MM_Member_Id__c" "households"
#run_bulk_upsert "data/persons.csv" "Account" "MM_Member_Id__c" "persons"
#run_bulk_upsert "data/businesses.csv" "Account" "MM_Member_Id__c" "businesses"
run_bulk_upsert "data/partners.csv" "Account" "Agency_BP_Id__c" "partners"
run_bulk_upsert "data/contacts.csv" "Contact" "Producer_BP_Id__c" "contacts"
run_bulk_upsert "data/producers.csv" "Producer" "Producer_External_Id__c" "producers"
#run_bulk_upsert "data/acr.csv" "AccountContactRelation" "ACR_Ext_Id__c" "acr"
#run_bulk_upsert "data/aar.csv" "AccountRelationship" "AA_External_Id__c" "aar"
#run_bulk_upsert "data/policy.csv" "InsurancePolicy" "Agreement_Key__c" "policy"
#run_bulk_upsert "data/ipp.csv" "InsurancePolicyParticipant" "Policy_Participant_External_Id__c" "ipp"
#run_bulk_upsert "data/ipp_stubbed.csv" "InsurancePolicyParticipant" "Policy_Participant_External_Id__c" "ipp_stubbed"
#run_bulk_upsert "data/ProducerPolicyAssignment.csv" "ProducerPolicyAssignment" "PPA_External_Id__c" "ppa"

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
failure_count=$(ls -1 bulk_results/failures/*.csv 2>/dev/null | wc -l)
if [ "$failure_count" -gt 0 ]; then
    echo "⚠️  Failures detected in $failure_count file(s)"
    echo "   See: bulk_results/failures/"
    echo ""
    echo "Sample errors:"
    for failed_file in bulk_results/failures/*_failed.csv; do
        if [ -f "$failed_file" ]; then
            filename=$(basename "$failed_file" _failed.csv)
            echo ""
            echo "  $filename:"
            # Show first error with column headers
            head -n 2 "$failed_file" | sed 's/^/    /'
        fi
    done
else
    echo "✓  All records loaded successfully!"
fi

echo ""
echo "Results:"
echo "  - bulk_results/load_summary.csv  : Summary of all loads"
echo "  - bulk_results/failures/         : Failed records only (empty if all succeeded)"
echo "  - bulk_results/working/          : Detailed job info and all results"