#!/usr/bin/env bash

set -euo pipefail

GIT_VERSION=$(git --version)
GIT_VERSION=${GIT_VERSION##* }
# TODO: Ensure this is the correct GitHub/GitLab homepage where releases can be downloaded for <YOUR TOOL>.
REPO="<TOOL REPO>"
TOOL_NAME="<YOUR TOOL>"
TOOL_TEST="<TOOL CHECK>"
IS_GITHUB=$(
  [[ "$REPO" =~ "github" ]]
  echo $?
)

git_supports_sort() {
  awk '{ split($0,a,"."); if ((a[1] < 2) || (a[2] < 18)) { print "1" } else { print "0" } }' <<<"$1"
}

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ $(git_supports_sort "${GIT_VERSION}") -eq 1 ]; then
  printf "must have git >= 2.18.0, have ${GIT_VERSION}\n"
  exit 1
fi

# NOTE: You might want to remove this if <YOUR TOOL> is not hosted on GitHub or GitLab releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
elif [ -n "${GITLAB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITLAB_API_TOKEN")
fi

list_remote_tags() {
  git -c 'versionsort.suffix=a' -c 'versionsort.suffix=b' \
    -c 'versionsort.suffix=r' -c 'versionsort.suffix=p' \
    -c 'versionsort.suffix=-' -c 'versionsort.suffix=_' \
    ls-remote --exit-code --tags --refs --sort="version:refname" "$REPO" |
    awk -F'[/v]' '$NF ~ /^[0-9]+.*/ { print $NF }' || fail "no releases found"
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if <YOUR TOOL> has other means of determining installable versions.
  list_remote_tags
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  # TODO: Adapt the release URL convention for <YOUR TOOL>
  if [ $IS_GITHUB -eq 0 ]; then
    url="$REPO/archive/v${version}.tar.gz"
  else
    url="$REPO/-/archive/${version}/${TOOL_NAME}-${version}.tar.gz"
  fi
  printf "%s: %s\n" "url" "$url"
  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    # TODO: Assert <YOUR TOOL> executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
