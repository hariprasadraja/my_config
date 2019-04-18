#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2086

clear
_myos="$(uname)"
if [[ $_myos == "Darwin" ]]; then

	# package coreutils contains various commands that works exactly like in
	# linux machines for mac os. If it is installed then use those commands.
	# This will overwrite some default macos commands with gnu commands
	# XXX: Make sure the coreutils has been installed properly

	coreutils="$(brew --prefix coreutils)/libexec/gnubin"
	if [ -d "${coreutils}" ]; then
		export PATH=${coreutils}:$PATH
	fi
fi

start=$(date +%s.%N)

if [ "${CONFIG_PATH}" == "" ]; then
	export CONFIG_PATH="${HOME}/.bash-config"
fi

export PROMPT_STYLE=extensive
export PATH=${CONFIG_PATH}/bin:$PATH

# y	year in 2-digit format,  Y	year in 4-digit format
# m	month in 2-digit format, d	day in 2-digit format
# T	time in 24-hour format,  %r	date in 12 hour AM/PM format, %D  date in mm/dd/yy format
HISTTIMEFORMAT="%d-%m-%Y %r "
HISTCONTROL=ignorespace:ignoredups

# Bash Prompt - You can use any one
source "${CONFIG_PATH}/prompt/jm-shell/ps1" || source "${CONFIG_PATH}/prompt/mathiasbynens/.bash_prompt"

# ---- GIT Configuration----
gitstatus=$(git config --get bashconfig.status)
if [ ! $gitstatus == true ]; then
	git config --global color.ui true
	git config --global include.path ${CONFIG_PATH}/git/.gitalias
	git config --global help.autocorrect 1
	git config --global core.excludesFile ${CONFIG_PATH}/git/.gitignore
	git config --global core.attributesFile ${CONFIG_PATH}/git/.gitattributes
	git config --global commit.template ${CONFIG_PATH}/git/.gitmessage

	# config to execute git configuration only once.
	git config --global bashconfig.status true
fi

# ---- Directory Bookmark Manager Setup ----
export SDIRS="${CONFIG_PATH}/.sdirs"
if [ ! -f "$SDIRS" ]; then
	echo "Creating file ${SDIRS} for storing bookmarks"
	touch $SDIRS
fi
source "${CONFIG_PATH}/bashmark/bashmarks.sh"

# ----- HSTR Setup -----
if [ $(command -v hstr) ]; then
	alias hh=hstr # hh to be alias for hstr
	export HSTR_CONFIG=hicolor,case-sensitive,no-confirm,raw-history-view,warning
	HISTFILESIZE=10000
	HISTSIZE=${HISTFILESIZE}

	# ensure synchronization between Bash memory and history file
	# export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

	#if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
	if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi

	# if this is interactive shell, then bind 'kill last command' to Ctrl-x k
	if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
fi

# ---- Intialize OS configurations ----
case ${_myos} in
Darwin)
	if [ -f "${CONFIG_PATH}/bash/bash_mac_x64.sh" ]; then
		# shellcheck disable=1090
		source "${CONFIG_PATH}/bash/bash_mac_x64.sh"
	fi
	;;
Linux)
	if [ -f "${CONFIG_PATH}/bash/bash_linux_x64.sh" ]; then
		source "${CONFIG_PATH}/bash/bash_linux_x64.sh"
	fi
	;;
*) ;;
esac

# ---- Scold Me, When I entered a wrong command ----
source "${CONFIG_PATH}/bash/command_not_found.sh"

_welcome-message() {
	# local login="last -2 $USER | cut -c 1- |head -1"
	# local lastlogin="last -2 $USER | cut -c 1-50|tail -1"
	local hour msg os_spec bash_version
	hour=$(date +%H) # Hour of the day
	msg="GOOD EVENING!"
	if [ $hour -lt 12 ]; then
		msg="GOOD MORNING!"
	elif [ $hour -lt 16 ]; then
		msg="GOOD AFTERNOON!"
	fi

	# Welcome message & system details
	utils log-header "${msg} $(utils string-upper ${USER})"
	echo -e "Time ($(date +%Z)): $(date)\n     (UTC): $(date -u)"
	os_spec="uname -r -p -m"
	echo -e "Kernal: ${_myos} v$(${os_spec})"
	bash_version=$(bash --version | head -n1 | cut -d" " -f2-5)
	echo -e "${bash_version}"
	echo "Hurray! Bash Config Loads in  $(echo "$(date +%s.%N) - $start" | bc -l) seconds"
}


#
# Autocompletion for Utils
#
_utils-autocomplete() {
	local cur
	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}
	if [ ${COMP_CWORD} -eq 1 ]; then
		_script_commands=$(utils -m)
		COMPREPLY=($(compgen -W "${_script_commands}" -- ${cur}))
	fi
	return 0
}

complete -F _utils-autocomplete utils


_welcome-message
