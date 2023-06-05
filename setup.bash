#!/usr/bin/env bash

set -euo pipefail

HELP="
Usage:

bash [--github | --gitlab] $0 PLUGIN_NAME TOOL_TEST GH_USER AUTHOR_NAME TOOL_GH TOOL_PAGE LICENSE

All arguments are optional and will be interactively prompted when not given.

PLUGIN_NAME.
   A name for your new plugin always starting with \`asdf-\` prefix.

TOOL_TEST.
   A shell command used to test correct installation.
   Normally this command is something taking \`--version\` or \`--help\`.

GH_USER.
   Your GitHub/GitLab username.

AUTHOR_NAME.
   Your name, used for licensing.

TOOL_GH.
   The tool's GitHub homepage. Default installation process will try to use
   this to access GitHub releases.

TOOL_PAGE.
   Documentation site for tool usage, mostly informative for users.

LICENSE.
   A license keyword.
   https://help.github.com/en/github/creating-cloning-and-archiving-repositories/licensing-a-repository#searching-github-by-license-type
"
HELP_PLUGIN_NAME="Name for your plugin, starting with \`asdf-\`, eg. \`asdf-foo\`"
HELP_TOOL_CHECK="Shell command for testing correct tool installation. eg. \`foo --version\` or \`foo --help\`"
HELP_TOOL_REPO="The tool's GitHub homepage."
HELP_TOOL_HOMEPAGE="The tool's documentation homepage if necessary."

ask_for() {
	local prompt="$1"
	local default_value="${2:-}"
	local alternatives="${3:-"[$default_value]"}"
	local value=""

	while [ -z "$value" ]; do
		echo "$prompt" >&2
		if [ "[]" != "$alternatives" ]; then
			echo -n "$alternatives " >&2
		fi
		echo -n "> " >&2
		read -r value
		echo >&2
		if [ -z "$value" ] && [ -n "$default_value" ]; then
			value="$default_value"
		fi
	done

	printf "%s\n" "$value"
}

download_license() {
	local keyword file
	keyword="$1"
	file="$2"

	curl -qsL "https://raw.githubusercontent.com/github/choosealicense.com/gh-pages/_licenses/${keyword}.txt" |
		extract_license >"$file"
}

extract_license() {
	awk '/^---/{f=1+f} f==2 && /^$/ {f=3} f==3'
}

test_url() {
	curl -fqsL -I "$1" | head -n 1 | grep 200 >/dev/null
}

ask_license() {
	local license keyword

	printf "%s\n" "Please choose a LICENSE keyword." >&2
	printf "%s\n" "See available license keywords at" >&2
	printf "%s\n" "https://help.github.com/en/github/creating-cloning-and-archiving-repositories/licensing-a-repository#searching-github-by-license-type" >&2

	while true; do
		license="$(ask_for "License keyword:" "APACHE-2.0" "MIT/APACHE-2.0/MPL-2.0/AGPL-3.0")"
		keyword=$(echo "$license" | tr '[:upper:]' '[:lower:]')

		url="https://choosealicense.com/licenses/$keyword/"
		if test_url "$url"; then
			break
		else
			printf "Invalid license keyword: %s\n" "$license"
		fi
	done

	printf "%s\n" "$keyword"
}

set_placeholder() {
	local name value out file tmpfile
	name="$1"
	value="$2"
	out="$3"

	git grep -P -l -F --untracked "$name" -- "$out" |
		while IFS=$'\n' read -r file; do
			tmpfile="$file.sed"
			sed "s#$name#$value#g" "$file" >"$tmpfile" && mv "$tmpfile" "$file"
		done
}

setup_github() {
	local cwd out tool_name tool_repo check_command author_name github_username tool_homepage ok primary_branch

	cwd="$PWD"
	out="$cwd/out"

	# ask for arguments not given via CLI
	tool_name="${1:-$(ask_for "$HELP_PLUGIN_NAME")}"
	tool_name="${tool_name/asdf-/}"
	check_command="${2:-$(ask_for "$HELP_TOOL_CHECK" "$tool_name --help")}"

	github_username="${3:-$(ask_for "Your GitHub username")}"
	author_name="${4:-$(ask_for "Your name" "$(git config user.name 2>/dev/null)")}"

	tool_repo="${5:-$(ask_for "$HELP_TOOL_REPO" "https://github.com/$github_username/$tool_name")}"
	tool_homepage="${6:-$(ask_for "$HELP_TOOL_HOMEPAGE" "$tool_repo")}"
	license_keyword="${7:-$(ask_license)}"
	license_keyword="$(echo "$license_keyword" | tr '[:upper:]' '[:lower:]')"

	primary_branch="main"

	cat <<-EOF
		Setting up plugin: asdf-$tool_name

		author:        $author_name
		plugin repo:   https://github.com/$github_username/asdf-$tool_name
		license:       https://choosealicense.com/licenses/$license_keyword/


		$tool_name github:   $tool_repo
		$tool_name docs:     $tool_homepage
		$tool_name test:     \`$check_command\`

		After confirmation, the \`$primary_branch\` will be replaced with the generated
		template using the above information. Please ensure all seems correct.
	EOF

	ok="${8:-$(ask_for "Type \`yes\` if you want to continue.")}"
	if [ "yes" != "$ok" ]; then
		printf "Nothing done.\n"
	else
		(
			set -e
			# previous cleanup to ensure we can run this program many times
			git branch template 2>/dev/null || true
			git checkout -f template
			git worktree remove -f out 2>/dev/null || true
			git branch -D out 2>/dev/null || true

			# checkout a new worktree and replace placeholders there
			git worktree add --detach out

			cd "$out"
			git checkout --orphan out
			git rm -rf "$out" >/dev/null
			git read-tree --prefix="" -u template:template/

			download_license "$license_keyword" "$out/LICENSE"
			sed -i '1s;^;TODO: INSERT YOUR NAME & COPYRIGHT YEAR (if applicable to your license)\n;g' "$out/LICENSE"

			set_placeholder "<YOUR TOOL>" "$tool_name" "$out"
			set_placeholder "<TOOL HOMEPAGE>" "$tool_homepage" "$out"
			set_placeholder "<TOOL REPO>" "$tool_repo" "$out"
			set_placeholder "<TOOL CHECK>" "$check_command" "$out"
			set_placeholder "<YOUR NAME>" "$author_name" "$out"
			set_placeholder "<YOUR GITHUB USERNAME>" "$github_username" "$out"
			set_placeholder "<PRIMARY BRANCH>" "$primary_branch" "$out"

			git add "$out"
			# remove GitLab specific files
			git rm -rf "$out/.gitlab" "$out/.gitlab-ci.yml" "$out/README-gitlab.md" "$out/contributing-gitlab.md"
			# rename GitHub specific files to final filenames
			git mv "$out/README-github.md" "$out/README.md"
			git mv "$out/contributing-github.md" "$out/contributing.md"
			git commit -m "Generate asdf-$tool_name plugin from template."

			cd "$cwd"
			git branch -M out "$primary_branch"
			git worktree remove -f out
			git checkout -f "$primary_branch"

			printf "All done.\n"
			printf "Your %s branch has been reset to an initial commit.\n" "$primary_branch"
			printf "Push to origin/%s with \`git push --force-with-lease\`\n" "$primary_branch"

			printf "Review these TODO items:\n"
			git grep -P -n -C 3 "TODO"
		) || cd "$cwd"
	fi
}

setup_gitlab() {
	local cwd out tool_name tool_repo check_command author_name github_username gitlab_username tool_homepage ok primary_branch

	cwd="$PWD"
	out="$cwd/out"

	# ask for arguments not given via CLI
	tool_name="${1:-$(ask_for "$HELP_PLUGIN_NAME")}"
	tool_name="${tool_name/asdf-/}"
	check_command="${2:-$(ask_for "$HELP_TOOL_CHECK" "$tool_name --help")}"

	gitlab_username="$(ask_for "Your GitLab username")"
	author_name="${4:-$(ask_for "Your name" "$(git config user.name 2>/dev/null)")}"

	github_username="${3:-$(ask_for "Tool GitHub username")}"
	tool_repo="${5:-$(ask_for "$HELP_TOOL_REPO" "https://github.com/$github_username/$tool_name")}"
	tool_homepage="${6:-$(ask_for "$HELP_TOOL_HOMEPAGE" "$tool_repo")}"
	license_keyword="${7:-$(ask_license)}"
	license_keyword="$(echo "$license_keyword" | tr '[:upper:]' '[:lower:]')"

	primary_branch="main"

	cat <<-EOF
		Setting up plugin: asdf-$tool_name

		author:        $author_name
		plugin repo:   https://gitlab.com/$gitlab_username/asdf-$tool_name
		license:       https://choosealicense.com/licenses/$license_keyword/


		$tool_name github:   $tool_repo
		$tool_name docs:     $tool_homepage
		$tool_name test:     \`$check_command\`

		After confirmation, the \`$primary_branch\` will be replaced with the generated
		template using the above information. Please ensure all seems correct.
	EOF

	ok="${8:-$(ask_for "Type \`yes\` if you want to continue.")}"
	if [ "yes" != "$ok" ]; then
		printf "Nothing done.\n"
	else
		(
			set -e
			# previous cleanup to ensure we can run this program many times
			git branch template 2>/dev/null || true
			git checkout -f template
			git worktree remove -f out 2>/dev/null || true
			git branch -D out 2>/dev/null || true

			# checkout a new worktree and replace placeholders there
			git worktree add --detach out

			cd "$out"
			git checkout --orphan out
			git rm -rf "$out" >/dev/null
			git read-tree --prefix=/ -u template:template/

			download_license "$license_keyword" "$out/LICENSE"

			set_placeholder "<YOUR TOOL>" "$tool_name" "$out"
			set_placeholder "<TOOL HOMEPAGE>" "$tool_homepage" "$out"
			set_placeholder "<TOOL REPO>" "$tool_repo" "$out"
			set_placeholder "<TOOL CHECK>" "$check_command" "$out"
			set_placeholder "<YOUR NAME>" "$author_name" "$out"
			set_placeholder "<YOUR GITHUB USERNAME>" "$github_username" "$out"
			set_placeholder "<YOUR GITLAB USERNAME>" "$gitlab_username" "$out"
			set_placeholder "<PRIMARY BRANCH>" "$primary_branch" "$out"

			git add "$out"
			# remove GitHub specific files
			git rm -rf "$out/.github" "$out/README-github.md" "$out/contributing-github.md"
			# rename GitLab specific files to final filenames
			git mv "$out/README-gitlab.md" "$out/README.md"
			git mv "$out/contributing-gitlab.md" "$out/contributing.md"
			git commit -m "Generate asdf-$tool_name plugin from template."

			cd "$cwd"
			git branch -M out "$primary_branch"
			git worktree remove -f out
			git checkout -f "$primary_branch"

			printf "All done.\n"
			printf "Your %s branch has been reset to an initial commit.\n" "$primary_branch"
			printf "You might want to push using \`--force-with-lease\` to origin/%s\n" "$primary_branch"

			printf "Showing pending TODO tags that you might want to review\n"
			git grep -P -n -C 3 "TODO"
		) || cd "$cwd"
	fi
}

case "${1:-}" in
"-h" | "--help" | "help")
	printf "%s\n" "$HELP"
	exit 0
	;;
"--gitlab")
	shift
	setup_gitlab "$@"
	;;
"--github")
	shift
	setup_github "$@"
	;;
*)
	setup_github "$@"
	;;
esac
