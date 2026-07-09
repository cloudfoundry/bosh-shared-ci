#!/usr/bin/env bash
set -euxo pipefail

if [ ! -f version/version ]; then
  echo "ERROR: version/version file not found. The version resource must be provided as an input."
  exit 1
fi

new_release_version=$(cat version/version)

git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"

pushd release_repo > /dev/null
  set +x
  echo "${PRIVATE_YML}" > config/private.yml
  set -x

  bosh create-release --final --version "${new_release_version}" --tarball=/tmp/release-tarball.tgz

  release_tarball_name="${new_release_version}"
  if [ -n "${RELEASE_TARBALL_BASE_NAME}" ]; then
    release_tarball_name="$RELEASE_TARBALL_BASE_NAME-$new_release_version"
  fi
  cp /tmp/release-tarball.tgz ../release_metadata/"${release_tarball_name}".tgz

  commit_message="Final release ${new_release_version}"
  if [ -n "${GIT_COMMIT_MESSAGE_SUFFIX:-}" ]; then
    commit_message="${commit_message}${GIT_COMMIT_MESSAGE_SUFFIX}"
  fi

  git add -A
  git status
  git commit -m "${commit_message}"
popd  > /dev/null

echo "${new_release_version}" > release_metadata/version
echo "v${new_release_version}" > release_metadata/tag-name
echo "" > release_metadata/empty-file
