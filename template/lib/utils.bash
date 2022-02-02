#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for <YOUR TOOL>.
GH_REPO="<TOOL REPO>"
TOOL_NAME="<YOUR TOOL>"
TOOL_TEST="<TOOL CHECK>"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if <YOUR TOOL> is not hosted on GitHub releases.
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
  # Change this function if <YOUR TOOL> has other means of determining installable versions.
  list_github_tags
}

download_release() {
  local version="$1"
  local filename="$2"

  # TODO: Adapt the OS & Architecture naming convention for <YOUR TOOL>
  # See the release flavours in the /releases page of <YOUR TOOL>
  #local uname_s="$(uname -s)"
  #local uname_m="$(uname -m)"
  #local os arch

  #case "$uname_s" in
  #FreeBSD) os="freebsd" ;;
  #Darwin) os="darwin" ;;
  #Linux) os="linux" ;;
  #*) fail "OS not supported: $uname_s" ;;
  #esac

  #case "$uname_m" in
  #i?86) arch="386" ;;
  #x86_64) arch="amd64" ;;
  #aarch64) arch="arm64" ;;
  #armv8l) arch="arm64" ;;
  #arm64) arch="arm64" ;;
  #armv7l) arch="arm" ;;
  #mips) arch="mips" ;;
  #mipsel) arch="mipsle" ;;
  #mips64) arch="mips64" ;;
  #mips64el) arch="mips64le" ;;
  #*) fail "Architecture not supported: $uname_m" ;;
  #esac

  # TODO: Adapt the release URL convention for <YOUR TOOL>
  # Example: local url="$GH_REPO/archive/v${version}-${os}-${arch}.tar.gz"
  local url="$GH_REPO/archive/v${version}.tar.gz"

  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

    # TODO: Asert <YOUR TOOL> executable exists.
    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error ocurred while installing $TOOL_NAME $version."
  )
}
