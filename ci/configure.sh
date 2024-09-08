#!/usr/bin/env bash

set -eu

fly -t "${CONCOURSE_TARGET:-bosh}" set-pipeline -p "bosh-shared-ci" -c ci/pipeline.yml
