#!/bin/bash

# Check if the required arguments (AWS region and output CSV file) are provided
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <aws-region> <output-csv-file>"
    exit 1
fi

region="$1"
output_csv="$2"

# Get a list of IAM roles in the specified region
roles=$(aws iam list-roles --region "$region" --output json | jq -r '.Roles[].RoleName')

# Write CSV header to the output file
echo "RoleName,AttachedPolicy,InlinePolicy" > "$output_csv"

# Iterate through each role and append its attached and inline policies to the CSV file
for role in $roles; do
    attached_policies=$(aws iam list-attached-role-policies --role-name "$role" --output json | jq -r '.AttachedPolicies[].PolicyName' | tr '\n' ',' | sed 's/,$//')
    inline_policies=$(aws iam list-role-policies --role-name "$role" --output json | jq -r '.PolicyNames[]' | tr '\n' ',' | sed 's/,$//')

    # Append role name, attached policies, and inline policies to the CSV file
    echo "\"$role\",\"$attached_policies\",\"$inline_policies\"" >> "$output_csv"
done
