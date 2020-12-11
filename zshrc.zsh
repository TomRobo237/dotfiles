# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Adding usr/local to PYTHONPATH
export PYTHONPATH='/usr/local/lib/python3.7/site-packages'

# Syntax hiliting for less
export LESSOPEN="| src-hilite-lesspipe.sh %s"
export LESS=' -R '

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

plugins=(
	git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Alias vi to Vim and ss to sudo last command
alias vi='vim'
alias ss='sudo "$(which zsh)" -c "$(history -p !!)"'

# LMGTFY
google() {
	open "http://www.google.com/search?q=$*"
}

# Use the Bash FG idenification by Job ID rather than lookup by name or need to add %
fg() {
    if [[ $# -eq 1 && $1 = - ]]; then
        builtin fg %-
    else
        builtin fg %"$@"
    fi
}


# Recursive grep with awk that prints line numbers use: awk-grep-r-nl REGEX FILES
awk-grep-r-nl() {
  myrex=$1 ; shift 1 ; awk -v myrex=$myrex '($0 ~ myrex) {print FILENAME, FNR":", $0}' $* 
}

# Some git things
alias cdnf='pushd /Users/tmiller/git/personal/noteserver/notes; pwd'
alias cdgr='cd $(git rev-parse --show-toplevel); pwd'
alias cleanup_git_branches='git branch --merged | grep -Ev "(^\*|master|dev)" | xargs git branch -d'

# OSX Section
#         # adding nix flag to ignore symlink warnings since firmlinks are a thing in OSX catalina...
#         export NIX_IGNORE_SYMLINK_STORE=1
#         source /Users/tmiller/.nix-profile/etc/profile.d/nix.sh
#         export NIX_PATH='darwin-config=/Users/tmiller/.nixpkgs/darwin-configuration.nix:/Users/tmiller/.nix-defexpr/channels:/Users/tmiller/.nix-defexpr/channels'
#         # Adding iterm Shell integration for ZSH
#         source ~/.iterm2_shell_integration.zsh
# END OSX Section

# Fuzzy finder
test -f ~/.fzf.zsh && source ~/.fzf.zsh

# Give a quote by a knowledge cow.
if test -x "$(command -v fortune)" ; then
	if test -x "$( command -v cowsay)" ; then	
		"$(command -v fortune)" | "$(command -v cowsay)"
	else
		"$(command -v fortune)"
	fi
fi
# If direnv exists run it.
if test -x "$(command -v direnv)" ; then
  eval "$(direnv hook zsh)"
fi
# Source any external shell files for work, so its in a seperate VCS.
for ext in $HOME/.ext_*zsh ; do
  source $ext
done
