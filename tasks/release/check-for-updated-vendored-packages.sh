#!/usr/bin/env bash
set -euo pipefail

version_number="$(cat version/version)"

updated_package=0
parsed_packages="$(echo "$PACKAGES" | jq -r '.[]')"

pushd input_repo
  for package in ${parsed_packages}; do
    current_version="$(git log -n 1 --format=format:"%B" -- packages/${package} | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')"
    previous_version="$(git log -n 1 --format=format:"%B" "v${version_number}" -- packages/${package} | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')"

    if [ "${current_version}" != "${previous_version}" ]; then
      if [ "${updated_package}" == "0" ]; then
        release_notes="### Package Updates:"
      fi
      updated_package=1

      release_notes="${release_notes}
* Updates ${package} from ${previous_version} to ${current_version}"
    fi
  done
popd

if [ "${updated_package}" == "0" ]; then
  touch package-updates/success
  echo "Packages ${parsed_packages} have not been updated."
  exit 1
fi

echo "${release_notes}"

echo "${release_notes}" >> release-notes/release-notes.md
touch release-notes/needs-release
touch package-updates/success
