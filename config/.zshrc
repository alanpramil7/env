export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
DISABLE_LS_COLORS="true"
source $ZSH/oh-my-zsh.sh

alias v='nvim'
alias e='exit'
alias c='clear'

# Aliases: tmux
alias ta='tmux attach'
alias tl='tmux list-sessions'
alias tn='tmux new-session -s'

# Aliases: rg
alias rg="rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim --colors=line:fg:black --colors=line:style:bold --colors=path:fg:magenta --colors=match:style:nobold"

# Aliases: safety
alias cp='cp --interactive'
alias mv='mv --interactive'

# Aliases: utility
alias bat='cat /sys/class/power_supply/BAT0/capacity'
alias bt='sudo systemctl start bluetooth'

# Man colors
man() {
  GROFF_NO_SGR=1 \
  LESS_TERMCAP_mb=$'\e[31m' \
  LESS_TERMCAP_md=$'\e[34m' \
  LESS_TERMCAP_me=$'\e[0m' \
  LESS_TERMCAP_se=$'\e[0m' \
  LESS_TERMCAP_so=$'\e[1;30m' \
  LESS_TERMCAP_ue=$'\e[0m' \
  LESS_TERMCAP_us=$'\e[35m' \
  command man "$@"
}

# ZLE
KEYTIMEOUT=1  # 10ms for grouping escape sequences
WORDCHARS='-_:'

setopt interactive_comments

# Jobs
setopt auto_continue  # continue jobs on disown
setopt check_jobs  # do not exit shell with jobs
setopt check_running_jobs

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST="$HISTSIZE"

setopt extended_history
setopt inc_append_history
setopt inc_append_history_time
setopt share_history
setopt hist_fcntl_lock

setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_no_store  # ignore fc command

HISTORY_IGNORE='(rm *|rf *)'

# History: interactive search
__history() {
  LBUFFER="$(fc -ln 0 | fzf --query="${LBUFFER}")"
  zle redisplay
}

zle -N __history

# Completion
LISTMAX=10000  # do not show warning if there is too much items in completion

setopt glob_dots  # include dotfiles into completion by default
setopt hash_cmds  # hash command locations
setopt list_packed

autoload -Uz compinit
compinit -C  # -C disables security checks on dump file

# _complete is base completer
# _approximate will fix completion if there is no matches
# _extensions will complete glob patters with extensions
zstyle ':completion:*' completer _extensions _complete _approximate

zstyle ':completion:*' menu select  # menu with selection
zstyle ':completion:*' increment yes
zstyle ':completion:*' verbose yes
zstyle ':completion:*' squeeze-slashes yes  # replace // with /

zstyle ':completion:*' file-sort modification  # show recently used files first
zstyle ':completion:*' list-dirs-first yes
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"  # colored files and directories, blue selection box
zstyle ':completion:*' ignored-patterns '.git'

zstyle ':completion:*' rehash false  # improves performance
zstyle ':completion:*' use-cache true

# Plugin: autosuggestions
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#606090'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40

# Plugin: syntax highlighting
# source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
ZSH_HIGHLIGHT_MAXLENGTH=120

# Rainbow brackets in special order, easier for eyes
ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=green'
ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=blue'
ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[bracket-level-6]='fg=red'

# Custom styles
# Errors
# ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,underline'

# Keywords
# ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=blue'

# Commands
# ZSH_HIGHLIGHT_STYLES[precommand]='fg=cyan'
# ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[global-alias]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[arg0]='fg=magenta'

# Strings
# ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
# ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'
# ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'

# Redirections
# ZSH_HIGHLIGHT_STYLES[redirection]='fg=cyan'

# Paths
# ZSH_HIGHLIGHT_STYLES[path]='none'

# Keybinds
bindkey -s ^f "tmux-sessionizer\n"

export EDITOR='nvim'
export ENV_DIR='~/personal/env'

export PATH="$PATH:/home/al/.local/bin/"
export PATH="$PATH:/home/al/personal/env/scripts/"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(zoxide init zsh)"

# . "$HOME/.local/bin/env"

# bun completions
[ -s "/home/al/.bun/_bun" ] && source "/home/al/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
