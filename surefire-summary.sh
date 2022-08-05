#!/bin/bash
set -eux -o pipefail

# Summarize the Maven test results
mvn surefire-report:report
REPORT_FILE=target/site/surefire-report.html

mkdir -p workflow-report/unit-test/

# I know this is madness ...
VALUES=$(cat ${REPORT_FILE} | pup 'json{}' | yq -P .[].children[].children[].children[3].children[].children[2].children[4].children[].children.[1])

TESTS=$(echo "${VALUES}" | yq '.children[0].text')
ERRORS=$(echo "${VALUES}" | yq '.children[1].text')
FAILURES=$(echo "${VALUES}" | yq '.children[2].text')
SKIPPED=$(echo "${VALUES}" | yq '.children[3].text')
SUCCESS_RATE=$(echo "${VALUES}" | yq '.children[4].text')
TIME=$(echo "${VALUES}" | yq '.children[5].text')

# ... but I am going to say "prototype" and tell myself it's okay.
yq -e -o json -n "\
.workflow.unit-test.attestations.tests.name = \"tests\" |
.workflow.unit-test.attestations.tests.value = \"${TESTS}\" | \
.workflow.unit-test.attestations.tests.description = \"\" | \
.workflow.unit-test.attestations.errors.name = \"errors\" | \
.workflow.unit-test.attestations.errors.value = \"${ERRORS}\" | \
.workflow.unit-test.attestations.errors.description = \"\" | \
.workflow.unit-test.attestations.failures.name = \"failures\" | \
.workflow.unit-test.attestations.failures.value = \"${FAILURES}\" | \
.workflow.unit-test.attestations.failures.description = \"\" | \
.workflow.unit-test.attestations.skipped.name = \"skipped\" | \
.workflow.unit-test.attestations.skipped.value = \"${SKIPPED}\" | \
.workflow.unit-test.attestations.skipped.description = \"\" | \
.workflow.unit-test.attestations.success-rate.name = \"success-rate\" | \
.workflow.unit-test.attestations.success-rate.value = \"${SUCCESS_RATE}\" | \
.workflow.unit-test.attestations.success-rate.description = \"\" | \
.workflow.unit-test.attestations.time.name = \"time\" | \
.workflow.unit-test.attestations.time.value = \"${TIME}\" | \
.workflow.unit-test.attestations.time.description = \"\"" \
> workflow-report/unit-test/step-evidence.json

