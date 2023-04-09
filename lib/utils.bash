#!/usr/bin/env bash

set -euo pipefail
set -x

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for okta-aws-cli.
GH_REPO="https://github.com/okta/okta-aws-cli"
TOOL_NAME="okta-aws-cli"
TOOL_TEST="okta-aws-cli --help"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if okta-aws-cli is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if okta-aws-cli has other means of determining installable versions.
  list_github_tags
}

download_release() {
  local version filename url
  version="$1"
  filename="$2"

  # we must get the os/architecture.
  ARCH=$(uname -m)
  OS=$(uname -s)
  ALTARCH=$(uname -m)
  ALTOS=$(uname -s)

  # Okta has changed from x86_64 to amd64 for Darwin starting from 0.3.0 (why? something I don't know?) so we need to adapt
  if [[ "${ARCH}" == "x86_64" && "${ASDF_INSTALL_VERSION}" == "0.3.0" ]]; then
      ALTARCH=amd64
  fi
  if [[ "${OS}" == "Linux" ]]; then
      ALTOS=linux
  fi

  arch=${ALTARCH}
  os=${ALTOS}

  # TODO: Adapt the release URL convention for okta-aws-cli
  url="$GH_REPO/releases/download/v${version}/okta-aws-cli_${version}_${os}_${arch}.tar.gz"

  # TODO: add a check of the signature
  # https://github.com/okta/okta-aws-cli/releases/download/v0.2.1/okta-aws-cli_0.2.1_Darwin_arm64.tar.gz

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="${3%/bin}/bin"
  local tool_cmd
  tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  if [[ ! -f "${ASDF_DOWNLOAD_PATH}/${tool_cmd}_v${version}" && ! -f "${ASDF_DOWNLOAD_PATH}/${tool_cmd}" ]]; then
    fail "ERROR: neither ${ASDF_DOWNLOAD_PATH}/${tool_cmd}_v${version} nor ${ASDF_DOWNLOAD_PATH}/${tool_cmd} exist. After untarring the downloaded release file I cannot find the executable"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"
    cp -p "${install_path}/${tool_cmd}_v${version}" "${install_path}/${tool_cmd}"

    # TODO: Assert okta-aws-cli executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

    test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
