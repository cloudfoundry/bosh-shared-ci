#!/usr/bin/env bash
set -euxo pipefail

pushd release_repo > /dev/null
  set +x
  if [ -n "${PRIVATE_YML}" ]; then
    echo "${PRIVATE_YML}" > config/private.yml
  fi
  set -x

  bosh create-release --timestamp-version --tarball ../release_tarball/release.tgz
popd  > /dev/null

release_metadata="$(bosh inspect-local-release ./release_tarball/release.tgz --json)"
new_release_version="$(bosh interpolate <(echo "${release_metadata}") --path /Tables/0/Rows/0/version)"

echo "${new_release_version}" > release-metadata/version
