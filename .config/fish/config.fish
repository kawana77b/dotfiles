if status is-interactive
    # Commands to run in interactive sessions can go here
    alias tohome='cd $HOME'
    alias bd='cd ../'
    alias cls='clear'

    if test (uname -s) = "Darwin"; and test -d /opt/homebrew
      eval (/opt/homebrew/bin/brew shellenv)
    else if test (uname -s) = "Linux"; and test -d /home/linuxbrew/.linuxbrew
      eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end

    if uname -r | string match -q -- "*WSL*"
      set -x GPG_TTY $(tty)
    end

    test -d $HOME/.local/bin; and set -gx PATH $HOME/.local/bin $PATH

    type -q nvim; and alias vim='nvim'

    type -q 7zz; and alias 7z='7zz'

    if type -q eza
      alias ls='eza -a'
      alias ll='eza -l -a'
      alias tree='eza --tree'
    end

    if type -q docker
      abbr -a dps docker ps -a
      abbr -a dit docker exec -it
      abbr -a dcu docker compose up -d
      abbr -a dcd docker compose down
    end

    if test -d $HOME/go
      set -gx PATH $HOME/go/bin $PATH
      set -gx GOPATH $HOME/go
      set -gx GOBIN $HOME/go/bin
    end

    if test -d $HOME/.dotnet
      set -gx PATH $HOME/.dotnet/tools $PATH
    end

    if type -q nvm
      test -f ~/.nvmrc; and nvm use > /dev/null 2>&1
    end

    test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
    
    if test -d "$HOME/.wasmer"
     set -gx WASMER_DIR "$HOME/.wasmer"
     test -s "$WASMER_DIR/wasmer.sh"; and source "$WASMER_DIR/wasmer.sh"
    end
    
    if test -d "$HOME/.wasmtime"
     set -gx WASMTIME_HOME "$HOME/.wasmtime"
     string match -r ".wasmtime" "$PATH" > /dev/null; or set -gx PATH "$WASMTIME_HOME/bin" $PATH
    end

    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
    type -q bookmark; and bookmark init fish | source
end
