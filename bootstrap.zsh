#!/usr/bin/env zsh

# Check if running macOS
if ! [[ "$OSTYPE" =~ darwin* ]]; then
	echo "Sorry, this is meant to be run on macOS only"
	exit
fi

download() {
	local url="$1"
	local output="$2"
	echo url: "$url"
	if command -v "curl" &>/dev/null; then
		curl \
			--location \
			--silent \
			--show-error \
			--output "$output" \
			"$url" \
			&>/dev/null
		return $?

	elif command -v "wget" &>/dev/null; then
		wget \
			--quiet \
			--output-document="$output" \
			"$url" \
			&>/dev/null
		return $?
	fi
	return 1
}

declare -r GITHUB_REPOSITORY="pnxdxt/tmp"
declare -r DOTFILES_UTILS_URL="https://raw.githubusercontent.com/$GITHUB_REPOSITORY/main/utils.zsh"
declare -r DOTFILES_TARBALL_URL="https://github.com/$GITHUB_REPOSITORY/tarball/main"
declare dotfilesDirectory="$HOME/tmp/.dotfiles"
declare skipQuestions=false

main() {
	local tmpFile=""

	# Load utils
	cd ~ || exit 1
	tmpFile="$(mktemp /tmp/XXXXX)"
	echo "tmpFile: $tmpFile"
	download "$DOTFILES_UTILS_URL" "$tmpFile" && . "$tmpFile" && rm -rf "$tmpFile"

	# Keep-alive: update existing sudo time stamp until the script has finished
	ask_for_sudo

	# download dotfiles
	echo_warn "• Download and extract archive"
	tmpFile="$(mktemp /tmp/XXXXX)"
	download "$DOTFILES_TARBALL_URL" "$tmpFile"
	print_result $? "Download archive" "true"
	printf "\n"

	skip_questions "$@" && skipQuestions=true

	if ! $skipQuestions; then
		ask_for_confirmation "Do you want to store the dotfiles in '$dotfilesDirectory'?"

		if ! answer_is_yes; then
			dotfilesDirectory=""
			while [ -z "$dotfilesDirectory" ]; do
				ask "Please specify another location for the dotfiles (path): "
				dotfilesDirectory="$(get_answer)"
			done
		fi

		# Ensure the `dotfiles` directory is available
		while [ -e "$dotfilesDirectory" ]; do
			ask_for_confirmation "'$dotfilesDirectory' already exists, do you want to overwrite it?"
			if answer_is_yes; then
				rm -rf "$dotfilesDirectory"
				break
			else
				dotfilesDirectory=""
				while [ -z "$dotfilesDirectory" ]; do
					ask "Please specify another location for the dotfiles (path): "
					dotfilesDirectory="$(get_answer)"
				done
			fi
		done

		printf "\n"
	else
		rm -rf "$dotfilesDirectory" &>/dev/null
	fi

	mkdir -p "$dotfilesDirectory"
	print_result $? "Create '$dotfilesDirectory'" "true"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	# Extract archive in the `dotfiles` directory.
	extract "$tmpFile" "$dotfilesDirectory"
	print_result $? "Extract archive" "true"

	# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	rm -rf "$tmpFile"
	print_result $? "Remove archive"

	# Change to the `dotfiles` directory
	cd "$dotfilesDirectory" || exit 1
	echo "$(pwd)"
	echo "$(ls -a)"
}

main "$@"
echo "Done"
