#!/usr/bin/env bash
set -euo pipefail

version_number="$(cat version/version)"

updated_blob=0
parsed_blobs="$(echo "$BLOBS" | jq -r '.[]')"

pushd input_repo
  for blob in $parsed_blobs; do
    current_version="$(git show HEAD:config/blobs.yml | grep "${blob}" | grep -Eo "[0-9]+(\.[0-9]+)+")"
    previous_version="$(git show v$version_number:config/blobs.yml | grep "${blob}" | grep -Eo "[0-9]+(\.[0-9]+)+")"

    if [ "${current_version}" != "${previous_version}" ]; then
      if [ "${updated_blob}" == "0" ]; then
        release_notes="### Updates:"
      fi
      updated_blob=1

      release_notes="${release_notes}
* Updates ${blob} from ${previous_version} to ${current_version}"
    fi
  done
popd

if [ "${updated_blob}" == "0" ]; then
  touch blob-updates/success
  echo "Blobs ${parsed_blobs} have not been updated."
  exit 1
fi

echo "${release_notes}"

echo "${release_notes}" >> release-notes/release-notes.md
touch release-notes/needs-release
touch blob-updates/success
