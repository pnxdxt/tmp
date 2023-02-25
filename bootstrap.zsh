#!/usr/bin/env zsh

# Check if running macOS
if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo "Sorry, this is meant to be run on macOS only"
  exit
fi

# Keep-alive: update existing sudo time stamp until the script has finished
if test ! "$(command -v sudo)"; then
  echo_warn "The Script Require Root Access. Please Enter Your Password."
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  echo_ok "Done!"
fi

echo "Hello world"
cd ~ || exit 1

declare -r DOTFILES_UTILS_URL="https://raw.githubusercontent.com/pnxdxt/tmp/main/utils.zsh"

download() {
	local url="$1"
	local output="$2"
	if command -v "curl" &> /dev/null; then
		curl \
			--location \
			--silent \
			--show-error \
			--output "$output" \
			"$url" \
				&> /dev/null
	return $?

	elif command -v "wget" &> /dev/null; then
		wget \
			--quiet \
			--output-document="$output" \
			"$url" \
				&> /dev/null
		return $?
	fi
	return 1
}


download_utils() {
	local tmpFile="$(mktemp /tmp/XXXXX)"
	download "$DOTFILES_UTILS_URL" "$tmpFile" \
			&& . "$tmpFile" \
			&& rm -rf "$tmpFile" \
			&& return 0

	return 1
}

# Load utils
if [ -x "utils.sh" ]; then
	echo "utils.sh exists"
	. "utils.sh" || exit 1
else
	download_utils || exit 1
fi
