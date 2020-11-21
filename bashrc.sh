# .bashrc

# Source global definitions
if test -f /etc/bashrc ; then
	source /etc/bashrc
fi

# OSX SECTION, need to figure out how this works for WSL...
# Catalina has all sorts of goofy things that can mess with nix, this allows nix to run even though the /nix is a symlink
export NIX_IGNORE_SYMLINK_STORE=1

# END OSX

# User specific aliases and functions
# History search
hist_search() {
	history | grep -ie"$*"
}

# Change to the git root
alias cdgr='cd $(git rev-parse --show-toplevel); pwd'

# Give a quote by a knowledge cow.
if test -x "$(command -v fortune)" ; then
	if test -x "$( command -v cowsay)" ; then	
		$(command -v fortune) | "$(command -v cowsay)"
	else
		"$(command -v fortune)"
	fi
fi

# Adding user scripts to PATH variable
PATH=$(echo $PATH):${HOME}/ubin:${HOME}/.local/bin

# Changing prompt
YELLOW="\[\e[1;33m\]"
BLUE="\[\e[1;96m\]"
GREEN="\[\e[1;32m\]"
NO_COLOR="\[\e[0m\]"
export PS1="${YELLOW}\A${NO_COLOR} ${BLUE}\h ${GREEN}\W${NO_COLOR}\n\$ "
export COPYFILE_DISABLE=true

