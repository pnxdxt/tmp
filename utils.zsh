# helpers
echo_ok() { echo '\033[1;32m'"$1"'\033[0m'; }
echo_warn() { echo '\033[1;33m'"$1"'\033[0m'; }
echo_error() { echo '\033[1;31mERROR: '"$1"'\033[0m'; }

print_result() {
	if [ "$1" -eq 0 ]; then
		echo_ok "✓ $2"
	else
		echo_error "$2"
		[ "$3" == "true" ] && exit 1
	fi
}

ask_for_sudo() {
	if test ! "$(command -v sudo)"; then
		echo "The Script Require Root Access. Please Enter Your Password."
		sudo -v &>/dev/null
		# https://gist.github.com/cowboy/3118588
		while true; do
			sudo -n true
			sleep 60
			kill -0 "$$" || exit
		done 2>/dev/null &
		echo "Done!"
	fi
}

skip_questions() {
	while :; do
		case $1 in
		-y | --yes) return 0 ;;
		*) break ;;
		esac
		shift 1
	done
	return 1
}

ask_for_confirmation() {
	echo_warn "$1 (y/n)"
	read -r -n 1
	printf "\n"
}

answer_is_yes() {
	[[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}

ask() {
	print_question "$1"
	read -r
}

get_answer() {
	printf "%s" "$REPLY"
}
