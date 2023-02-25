#!/usr/bin/env zsh

# Check if running macOS
if ! [[ "$OSTYPE" =~ darwin* ]]; then
  echo "Sorry, this is meant to be run on macOS only"
  exit
fi

# helpers
function echo_ok { echo '\033[1;32m'"$1"'\033[0m'; }
function echo_warn { echo '\033[1;33m'"$1"'\033[0m'; }
function echo_error { echo '\033[1;31mERROR: '"$1"'\033[0m'; }

# Close any open System Preferences panes, to prevent them from overriding settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Keep-alive: update existing sudo time stamp until the script has finished
if test ! "$(command -v sudo)"; then
  echo_warn "The Script Require Root Access. Please Enter Your Password."
  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  echo_ok "Done!"
fi

echo "Hello world"
