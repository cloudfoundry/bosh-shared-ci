#!/usr/bin/env bash

set -euo pipefail

if [ -e task-output-folder/success ]; then
  echo "Success file found. The task completed successfully."
  exit 0
else
  echo "Missing success file. The task being checked did not complete successfully."
  exit 1
fi
