#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Script to extract all active users with FederationId to CSV
# Usage: ./extract_users.sh [output_filename.csv]

OUTPUT_FILE=${1:-"users_with_federation_id.csv"}

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

echo "Extracting active users with FederationId..."

# Query active users with FederationId
if sf data query \
  --query "SELECT Id, Username, Email, FirstName, LastName, FederationIdentifier, IsActive, ProfileId, UserRoleId, TimeZoneSidKey, LocaleSidKey, EmailEncodingKey, LanguageLocaleKey FROM User WHERE IsActive = true AND FederationIdentifier != null" \
  --result-format csv \
  > "$OUTPUT_FILE"; then
  
  # Verify file was created and has content
  if [ ! -f "$OUTPUT_FILE" ]; then
    echo "✗ Error: Output file was not created"
    exit 1
  fi
  
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "✗ Error: Output file is empty"
    exit 1
  fi
  
  echo "✓ Successfully exported users to: $OUTPUT_FILE"
  RECORD_COUNT=$(tail -n +2 "$OUTPUT_FILE" | wc -l | tr -d ' ')
  echo "  Records exported: $RECORD_COUNT"
  
  if [ "$RECORD_COUNT" -eq 0 ]; then
    echo "⚠ Warning: No records found matching the criteria"
  fi
else
  echo "✗ Export failed with exit code: $?"
  exit 1
fi