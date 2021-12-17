#!/bin/bash

set -euo pipefail

npm install -g  backstopjs

COMMAND=$1
STATE=failure
GITHUB_API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/statuses/${HEAD_SHA}"

STATUS_DATA="{\"state\": \"pending\", \"description\": \"${COMMAND}\", \"context\": \"Visual regression test\"}"
curl --fail -X POST --user ":${GITHUB_TOKEN}" "${GITHUB_API_URL}" --data "${STATUS_DATA}"

backstop "${COMMAND}" || true

if [ "${COMMAND}" == "test" ]; then
    echo "$BACKSTORE_KEY" > /tmp/key
    chmod go= /tmp/key

    REFERENCE_IMAGES=$(jq -r .paths.bitmaps_reference backstop.json)
    TEST_IMAGES=$(jq -r .paths.bitmaps_test backstop.json)
    HTML_REPORT=$(jq -r .paths.html_report backstop.json)
    SHA=$(echo "${GITHUB_REPOSITORY}:${HEAD_SHA}" | sha1sum - | cut -d" " -f 1)
    ERRORS=$(sed -zE 's/.*errors="([0-9]+)".*/\1/' backstop_data/ci_report/xunit.xml)

    if [[ "${ERRORS}" == "0" ]]; then
        STATE=success
    fi

    rsync -e 'ssh -i /tmp/key -p 1984 -o StrictHostKeyChecking=no' -r "${REFERENCE_IMAGES}" "${TEST_IMAGES}" "${HTML_REPORT}" "store@backstore.reload.dk:backstore/${SHA}/"

    BACKSTORE_URL=https://backstore.reload.dk/${SHA}/$(basename "${HTML_REPORT}")

    STATUS_DATA="{\"state\": \"${STATE}\", \"description\": \"Report\", \"context\": \"Visual regression test\", \"target_url\": \"${BACKSTORE_URL}\"}"
    curl --fail --silent -X POST --user ":${GITHUB_TOKEN}" "${GITHUB_API_URL}" --data "${STATUS_DATA}"
fi
