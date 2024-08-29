alias tohome='cd $HOME'
alias bd='cd ../'
alias cls='clear'

type -q git; alias g='git'

if type -q eza
  alias ls='eza -a'
  alias ll='eza -l -a'
  alias tree='eza --tree'
end

type -q nvim; and alias vim='nvim'

type -q 7zz; and alias 7z='7zz'

if type -q docker
  abbr -a dps docker ps -a
  abbr -a dit docker exec -it
  abbr -a dcu docker compose up -d
  abbr -a dcd docker compose down
end