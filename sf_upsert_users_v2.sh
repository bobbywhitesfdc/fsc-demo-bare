#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Script to upsert users using FederationIdentifier as external ID via Bulk API
# Usage: ./upsert_users.sh [input_filename.csv]

INPUT_FILE=${1:-"users_with_federation_id.csv"}

# Check if SF CLI is installed
if ! command -v sf &> /dev/null; then
  echo "✗ Error: Salesforce CLI (sf) not found. Please install it first."
  exit 1
fi

# Check if authenticated to an org
if ! sf org display --json &> /dev/null; then
  echo "✗ Error: Not authenticated to a Salesforce org."
  echo "  Please run: sf org login web"
  exit 1
fi

# Check if file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "✗ Error: File '$INPUT_FILE' not found"
  exit 1
fi

# Check if file is empty
if [ ! -s "$INPUT_FILE" ]; then
  echo "✗ Error: File '$INPUT_FILE' is empty"
  exit 1
fi

# Validate CSV has headers
if ! head -n 1 "$INPUT_FILE" | grep -q "FederationIdentifier"; then
  echo "✗ Error: CSV file must contain 'FederationIdentifier' column"
  exit 1
fi

RECORD_COUNT=$(tail -n +2 "$INPUT_FILE" | wc -l | tr -d ' ')
echo "Upserting $RECORD_COUNT records from: $INPUT_FILE"
echo "Using FederationIdentifier as external ID..."

# Perform bulk upsert using FederationIdentifier as the external ID field
if sf data upsert bulk \
  --sobject User \
  --file "$INPUT_FILE" \
  --external-id FederationIdentifier \
  --wait 10; then
  
  echo "✓ Upsert completed successfully"
  echo ""
  echo "To check bulk job details, use:"
  echo "  sf data query --query \"SELECT Id, State, NumberRecordsProcessed, NumberRecordsFailed FROM AsyncApexJob WHERE JobType = 'BatchApexWorker' ORDER BY CreatedDate DESC LIMIT 1\" --use-tooling-api"
else
  EXIT_CODE=$?
  echo "✗ Upsert failed with exit code: $EXIT_CODE"
  echo "  Check the Salesforce Setup > Bulk Data Load Jobs for details"
  exit $EXIT_CODE
fi