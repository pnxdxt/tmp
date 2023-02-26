#!/usr/bin/env bash

check_dependencies() {
	if ! command -v git >/dev/null 2>&1; then
		echo "Failed: git is not installed"
		exit 1
	fi
}

create_zinit_home() {
	if ! test -d "${ZINIT_HOME}"; then
		mkdir -p "${ZINIT_HOME}"
		chmod g-w "${ZINIT_HOME}"
		chmod o-w "${ZINIT_HOME}"
	fi
}

create_zinit_tmpdir() {
	# use -d instead of --directory for macos (BSD) compatibility
	ZINIT_TMPDIR="$(mktemp -d)"
	if [ ! -d "$ZINIT_TMPDIR" ]; then
		echo_error "Tempdir creation failed. This ain't good"
		exit 1
	fi

	trap 'rm -rvf "$ZINIT_TMPDIR"' EXIT INT
}

# Get the download-progress bar tool
download_git_output_processor() {
	url="https://raw.githubusercontent.com/${ZINIT_REPO}/${ZINIT_COMMIT:-${ZINIT_BRANCH}}/share/git-process-output.zsh"
	script_path="${ZINIT_TMPDIR}/git-process-output.zsh"

	echo "Fetching git-process-output.zsh from $url"
	if command -v curl >/dev/null 2>&1; then
		curl -fsSL -o "$script_path" "$url"
	elif command -v wget >/dev/null 2>&1; then
		wget -q -O "$script_path" "$url"
	fi

	# shellcheck disable=2181
	if [ "$?" -eq 0 ]; then
		chmod a+x "$script_path" 2>/dev/null
	fi

	unset url script_path
}

zinit_git_exec() {
	command git -C "${ZINIT_INSTALL_DIR}" "$@"
}

zinit_checkout_ref() {
	ref="${ZINIT_BRANCH}"
	git_obj_type="branch"

	if [ -n "$ZINIT_COMMIT" ]; then
		ref="$ZINIT_COMMIT"
		git_obj_type="commit"
	fi

	if zinit_git_exec checkout "$ref" >/dev/null 2>&1; then
		echo "Checked out $git_obj_type $ref"
	else
		echo "Failed to check out $git_obj_type $ref"
	fi

	unset ref git_obj_type
}

zinit_install() {
	cd "${ZINIT_HOME}" || exit 1

	{
		command git clone --progress --branch "$ZINIT_BRANCH" \
			"https://github.com/${ZINIT_REPO}" \
			"${ZINIT_REPO_DIR_NAME}" 2>&1 | {
			"${ZINIT_TMPDIR}/git-process-output.zsh" || cat
		}
	} 2>/dev/null

	zinit_checkout_ref

	if [ -d "${ZINIT_REPO_DIR_NAME}" ]; then
		echo "Zinit succesfully installed"
	else
		echo "Failed to install Zinit"
	fi
}

config_dir() {
	rm -rf "$CONFIG_DIR" &
	>/dev/null
	mkdir -p "$CONFIG_DIR"
}

config_git_exec() {
	command git -C "${CONFIG_DIR}" "$@"
}

config_checkout_ref() {
	ref="${CONFIG_BRANCH}"
	git_obj_type="branch"

	if config_git_exec checkout "$ref" >/dev/null 2>&1; then
		echo "Checked out $git_obj_type $ref"
	else
		echo "Failed to check out $git_obj_type $ref"
	fi

	unset ref git_obj_type
}

config_install() {
	cd "$HOME" || exit 1

	{
		command git clone --progress --branch "$CONFIG_BRANCH" \
			"https://github.com/${CONFIG_REPO}" \
			"${CONFIG_REPO_DIR_NAME}" 2>&1 | {
			"${ZINIT_TMPDIR}/git-process-output.zsh" || cat
		}
	} 2>/dev/null

	config_checkout_ref

	if [ -d "${CONFIG_REPO_DIR_NAME}" ]; then
		echo "Config succesfully installed"
	else
		echo "Failed to install config"
	fi
}

config_setup() {
	source "$CONFIG_DIR/bootstrap.sh"
}

# Globals. Can be overridden.
ZINIT_REPO="${ZINIT_REPO:-zdharma-continuum/zinit}"
ZINIT_BRANCH="${ZINIT_BRANCH:-main}"
ZINIT_COMMIT="${ZINIT_COMMIT:-}" # no default value
ZINIT_HOME="${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit}"
ZINIT_REPO_DIR_NAME="${ZINIT_REPO_DIR_NAME:-zinit.git}"
ZINIT_INSTALL_DIR=${ZINIT_INSTALL_DIR:-${ZINIT_HOME}/${ZINIT_REPO_DIR_NAME}}

check_dependencies
create_zinit_home
create_zinit_tmpdir
download_git_output_processor

if [ -d "${ZINIT_INSTALL_DIR}/.git" ]; then
	ZINIT_UPDATE=1
else
	zinit_install
fi

CONFIG_REPO="pnxdxt/zsh-config"
CONFIG_REPO_DIR_NAME=".zsh-config"
CONFIG_BRANCH="master"
CONFIG_DIR="$HOME/${CONFIG_REPO_DIR_NAME}"

config_dir
config_install
config_setup
