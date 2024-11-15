#!/usr/bin/env bash
set -euxo pipefail

version_flag=""
if [ -f version/version ]; then
  version_flag="--version $(cat version/version)"
fi

git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"

pushd release_repo > /dev/null
  set +x
  echo "${PRIVATE_YML}" > config/private.yml
  set -x

  bosh create-release --final ${version_flag} --tarball=/tmp/release-tarball.tgz
  new_release_version=$(find releases/**/*.yml | grep -Eo '[0-9.]+[0-9]' | sort -V | tail -1)

  release_tarball_name="${new_release_version}"
  if [ -n "${RELEASE_TARBALL_BASE_NAME}" ]; then
    release_tarball_name="$RELEASE_TARBALL_BASE_NAME-$new_release_version"
  fi
  cp /tmp/release-tarball.tgz ../release_metadata/"${release_tarball_name}".tgz

  git add -A
  git status
  git commit -m "Final release ${new_release_version}"
popd  > /dev/null

echo "${new_release_version}" > release_metadata/version
echo "v${new_release_version}" > release_metadata/tag-name
echo "" > release_metadata/empty-file
