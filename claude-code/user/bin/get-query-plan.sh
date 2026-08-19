#!/usr/bin/env sh
set -e

if [ "$#" -ne 3 ]; then
	printf '%s\n' "Usage: $0 <query-id> <file-path> <namespace>" >&2
	exit 1
fi

query_id="$1"
file_path="$2"
namespace="$3"

if [ -z "$PIGMENT_TOKEN" ]; then
	printf '%s\n' "Error: PIGMENT_TOKEN environment variable is not set" >&2
	exit 1
fi

curl -s -X GET \
	--get \
	--data-urlencode "filePath=${file_path}" \
	-H "Authorization: Bearer ${PIGMENT_TOKEN}" \
	-H "X-Pigment-Location: ${namespace}" \
	"https://pigment.app/api/compute/internals/queryPlans/GetQueryPlan/${query_id}" |
	jq '.Plan'
