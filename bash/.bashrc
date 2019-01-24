#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2086

clear

export CONFIG_PATH="${HOME}/.bash-config"
export PROMPT_STYLE=extensive
export PATH=${CONFIG_PATH}/bin:$PATH

# y	year in 2-digit format, Y	year in 4-digit format
# m	month in 2-digit format
# d	day in 2-digit format
# T	time in 24-hour format
# %r	date in 12 hour AM/PM format
# %D	date in mm/dd/yy format
HISTTIMEFORMAT="%d-%m-%Y %r "
HISTCONTROL=ignorespace:ignoredups

# Source jm-shell custom prompt if it exists.
if [ -f "${CONFIG_PATH}/prompt/jm-shell/ps1" ]; then
	# shellcheck disable=1090
	source "${CONFIG_PATH}/prompt/jm-shell/ps1"
else
	source "${CONFIG_PATH}/bash/.bash_prompt"
fi

# ---- GIT Configuration----
git config --global color.ui true
git config --global include.path ~/.bash-config/git/.gitalias
git config --global help.autocorrect 1
git config --global core.excludesFile ~/.bash-config/git/.gitignore
git config --global core.attributesFile ~/.bash-config/git/.gitattributes
git config --global commit.template ~/.bash-config/git/.gitmessage

# ---- Directory Bookmark Manager ----
export SDIRS="${CONFIG_PATH}/.sdirs"
if [ ! -f "$SDIRS" ]; then
	echo "file does not exist"
	touch $SDIRS
fi
source "${CONFIG_PATH}/bashmark/bashmarks.sh"

# ----- HSTR configuration -----
if [ $(command -v hstr) ]; then
	alias hh=hstr # hh to be alias for hstr
	export HSTR_CONFIG=hicolor,case-sensitive,no-confirm,raw-history-view,warning
	HISTFILESIZE=10000
	HISTSIZE=${HISTFILESIZE}

	# ensure synchronization between Bash memory and history file
	export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

	#if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
	if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi

	# if this is interactive shell, then bind 'kill last command' to Ctrl-x k
	if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
fi

# ---- Intialize OS configurations ----
_myos="$(uname)"
case $_myos in
Darwin)
	if [ -f "${CONFIG_PATH}/bash/bash_mac_x64" ]; then

		# shellcheck disable=1090
		source "${CONFIG_PATH}/bash/bash_mac_x64"
	fi
	;;
Linux)
	if [ -f "${CONFIG_PATH}/bash/bash_linux_x64" ]; then
		source "${CONFIG_PATH}/bash/bash_linux_x64"
	fi
	;;
*) ;;
esac

function print_login_details() {
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
	# u_header "${msg} $(u_upper ${USER})"
	echo -e "Time ($(date +%Z)): $(date)\n     (UTC): $(date -u)"
	os_spec="uname -r -p -m"
	echo -e "Kernal: ${_myos} v$(${os_spec})"
	bash_version=$(bash --version | head -n1 | cut -d" " -f2-5)
	echo -e "${bash_version}"
	# u_header "INSTALLED"

	file="${CONFIG_PATH}/.installed"
	if [ ! -f "$file" ]; then
		{
			go version | head -n1
			python --version
			grep --version | head -n1
			gzip --version | head -n1
			m4 --version | head -n1
			make --version | head -n1
			patch --version | head -n1
			hstr --version | head -n1
			docker --version | head -n1
			echo 'int main(){}' >dummy.c && g++ -o dummy dummy.c
			if [ -x dummy ]; then
				echo "g++ $(g++ -dumpversion)"
				rm -f dummy.c dummy
			fi
			echo -e "\nlast updated on $(date '+%d-%m-%Y %H:%M:%S')"
			echo -e "get latest version by running:'rm -rf ${file} && bash' \n"
		} &>$file
	fi

	cat $file
}

print_login_details
