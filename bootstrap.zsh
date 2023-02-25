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
echo ${(%):-%N}
