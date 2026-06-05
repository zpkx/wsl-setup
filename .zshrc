# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} m:{A-Z}={a-z}'

# load completions
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

eval "$(/home/peng/.local/bin/mise activate zsh)"
eval "$(sheldon source)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

alias ls='eza -F --icons --group-directories-first'
alias ll='ls -lHo --git'
alias la='ll -a'
alias lt='eza --tree --icons'
alias pn='pnpm'
alias cat='bat'

# Upgrade Everything
alias upev='sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y'

#ask() { claude -p "$@" | glow }

export EDITOR='nvim'
