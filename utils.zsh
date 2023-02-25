# helpers
print_in_color() {
	printf "%b" "$(tput setaf "$2" 2>/dev/null)" "$1" "$(tput sgr0 2>/dev/null)"
}

print_in_green() {
	print_in_color "$1" 2
}

print_in_purple() {
	print_in_color "$1" 5
}

print_in_red() {
	print_in_color "$1" 1
}

print_in_yellow() {
	print_in_color "$1" 3
}

print_question() {
	print_in_yellow "   [?] $1"
}

print_success() {
	print_in_green "   [✔] $1\n"
}

print_warning() {
	print_in_yellow "   [!] $1\n"
}

print_error() {
	print_in_red "   [✖] $1 $2\n"
}

print_error_stream() {
	while read -r line; do
		print_error "↳ ERROR: $line"
	done
}

print_result() {
	if [ "$1" -eq 0 ]; then
		print_success "$2"
	else
		print_error "$2"
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
	print_question "$1 (y/n) "
	read -r -n 1
	printf "\n"
}

answer_is_yes() {
	echo "REPLY: $REPLY"
	[[ "$REPLY" =~ ^[Yy]$ ]] && return 0 || return 1
}

ask() {
	print_question "$1"
	read -r
}

get_answer() {
	printf "%s" "$REPLY"
}

extract() {
	local archive="$1"
	local outputDir="$2"

	if command -v "tar" &>/dev/null; then
		tar \
			--extract \
			--gzip \
			--file "$1" \
			--strip-components 1 \
			--directory "$2"
		return $?
	fi

	return 1
}
