# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples
# Based off of https://github.com/mkasberg/dotfiles/tree/master

echo Loading bashrc...

# # If not running interactively, don't do anything
# case $- in
#     *i*) ;;
#       *) echo "Not interactive, exiting."; return;;
# esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=200000
HISTFILESIZE=200000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    # Default color prompt:
    #PS1='$${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
 
    # Read Mike's custom prompt, apply it to PS1.
    source "$HOME/.mkps1"
    PS1="$(__mkps1)"
else
    # Modified to support git status in PS1.
    # Also modified by Mike to function better.
    #PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    PS1='\n${debian_chroot:+($debian_chroot)}\u:\w$(__git_ps1 " (%s)")\n\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Trim the number of directories in PS1 \w:
#export PROMPT_DIRTRIM=3

# Alias definitions.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f "$HOME/.bash_aliases" ]; then
    . "$HOME/.bash_aliases"
fi

# Use bat when viewing man pages.
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# Configure the ls colours/theme.
if [ -f "$HOME/.set_ls_theme" ]; then 
    . $HOME/.set_ls_theme SIMPLE_SOLARIZED
fi

# hash will return a zero exit code if the operand exists, i.e. the if branch is taken.
if hash fzf; then
    eval "$(fzf --bash)"
else
    # Enable ctrl + s forward search in bash by disabling XON/XOFF flow control.
    stty -ixon
fi


export _BASHRC_LOADED=true
if [ -f "$HOME/.bash_profile" ] && [ "$_BASH_PROFILE_LOADED" != true ]; then
    echo Loading bash profile from bashrc...
    source "$HOME/.bash_profile"
else
    unset _BASH_PROFILE_LOADED
    unset _BASHRC_LOADED
fi
