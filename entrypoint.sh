#!/bin/bash

set -euo pipefail

STATE=error
GITHUB_API_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}/statuses/${HEAD_SHA}"

if backstop $1; then
  STATE=success
fi

if [ "$1" == "reference"]; then
    STATUS_DATA="{\"state\": \"pending\", \"description\": \"Report\", \"context\": \"Visual regression test\", \"target_url\": \"${BACKSTORE_URL}\"}"
    curl --fail --silent -X POST --user ":${GITHUB_TOKEN}" "${GITHUB_API_URL}" --data "${STATUS_DATA}"
fi

if [ "$1" == "test" ]; then
    echo "$BACKSTORE_KEY" > /tmp/key
    chmod go= /tmp/key

    REFERENCE_IMAGES=$(jq -r .paths.bitmaps_reference backstop.json)
    TEST_IMAGES=$(jq -r .paths.bitmaps_test backstop.json)
    HTML_REPORT=$(jq -r .paths.html_report backstop.json)
    SHA=$(echo $GITHUB_REPOSITORY:$HEAD_SHA | sha1sum - | cut -d" " -f 1)

    rsync -e 'ssh -i /tmp/key -p 1984 -o StrictHostKeyChecking=no' -r ${REFERENCE_IMAGES} ${TEST_IMAGES} ${HTML_REPORT} store@backstore.reload.dk:backstore/${SHA}/

    BACKSTORE_URL=https://backstore.reload.dk/${SHA}/$(basename $HTML_REPORT)

    STATUS_DATA="{\"state\": \"${STATE}\", \"description\": \"Report\", \"context\": \"Visual regression test\", \"target_url\": \"${BACKSTORE_URL}\"}"
    curl --fail --silent -X POST --user ":${GITHUB_TOKEN}" "${GITHUB_API_URL}" --data "${STATUS_DATA}"
fi

if [ "$STATE" == "success" ]; then
  exit
fi

exit 1
