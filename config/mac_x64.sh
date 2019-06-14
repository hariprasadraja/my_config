#!/usr/bin/env bash
# ---- Personal Configured Alias ----
# inspiered from https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html

# enable color support of ls and also add handy aliases
dircolors="$(brew --prefix coreutils)/libexec/gnubin/dircolors"
dir_color="${BASHCONFIG_PATH}/resources/dircolors/ansi-universal"
if [ -x "${dircolors}" ]; then
	test -r "${dir_color}" && eval "$(dircolors ${dir_color})"
	alias ls='gls -ctFsh --color=auto'  #List all files sorted by last modified.
	alias la='gls -atFsh --color=auto'  #list all files and folders (both hidden) with memory.
	alias ll='gls -altFsh --color=auto' #List all files and folders in long listing format
	alias l.='ls -d .* --color=auto'    #List only dot files and dot directories

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto' #Interpret  PATTERN  as  a  list  of  fixed strings, separated by newlines
	alias egrep='egrep --color=auto' #Interpret PATTERN as an extended regular  expression
fi

unset dircolors dir_color

# Add alias if 'code' cmd exist.
if [ -x "$(command -v code)" ]; then
	alias code='code -n --max-memory 4096'
	alias diff='code -n -d'
fi

alias update='brew update && brew upgrade'
alias uninstall='brew uninstall'

# Rewrite the Builtin cd command to list directory after switching into it
cd() {
	builtin cd "$@" && ls
}

alias ..='cd ..'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
alias ~="cd ~"

alias mkdir='mkdir -pv'
alias bc='bc -l'
alias sha1='openssl sha1'
alias h='history'
alias j='jobs -l'
alias path='echo -e ${PATH//:/\\n}'

alias now='date +"%d-%m-%Y (24-hrs: %T  | 12-hrs: %r)"'
alias nowutc='date -u +"%d-%m-%Y (24-hrs: %T | 12-hrs: %r)"'

# Stop after sending count ECHO_REQUEST packets #
alias ping='ping -c 5'

# Do not wait interval 1 second, go fast
alias fastping='ping -c 100 -s.2'

# show opened ports
alias ports='netstat -tulanp'

## shortcut for iptables and pass it via sudo
alias ipt='sudo /sbin/iptables' # display all rules #
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'

# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -rfvI' # confirmation #
alias mv='mv -i'
alias cp='cp -i'
alias mkdir='mkdir -pv'

alias ln='ln -i' # Parenting changing perms on / #

alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

alias root='sudo -i'

## pass options to free ##
alias meminfo='free -m -l -t'

## get top process eating memory
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'

## get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3'
alias pscpu10='ps auxf | sort -nr -k 3 | head -10'

## get GPU ram on desktop / laptop##
alias gpumeminfo='grep -i --color memory /var/log/Xorg.0.log'

## python
alias python='python3'

# Exec Path
alias path='util log-header "PATH(s)" && echo -e "$(echo $PATH | tr ":" "\n" | nl)"'

# print colorized output for programs
# https://github.com/jingweno/ccat/issues
alias cat="ccat"

alias df="df -Tha --total"
alias du="du -ach"
alias free="free -mt"
alias ps="ps auxf --sort=-pcpu,+pmem"

# Downaload via go get
alias goget="go get -u -v -t -f"

# untar FileName to unpack any .tar file.
# add -z for zip file
alias untar='tar -xvf '

# generate a random, 20-character password for a new online account
alias getpass="openssl rand -base64 20"

# Downloaded a file and need to test the checksum
alias sha='shasum -a 256 '

# Need to test how fast the Internet Is?
alias speed='speedtest-cli --server 2406 --simple --secure'

# External Ip address or Public Ip address
alias ipe='curl ipinfo.io/ip || (curl http://ipecho.net/plain; echo)'

# print the environment variables in sorted order
envs() {
	if [ -n "${@}" ]; then
		env ${@} | sort
		return
	fi

	env | sort
}

# ---- Import Aliases for Docker ----
source ${BASHCONFIG_PATH}/config/docker.sh

# if user is not root, pass all commands via sudo #
if [ $UID -ne 0 ]; then
	alias update='brew update && brew upgrade'
	alias remove='brew uninstall'
	alias install='brew install'

	# do not delete / or prompt if deleting more than 3 files at a time #
	alias rm='sudo rm -rfvI'
	alias mv='sudo mv -i'
	alias cp='sudo cp -i'
	alias mkdir='sudo mkdir -pv'
fi
