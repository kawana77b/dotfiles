if status is-interactive
    # Commands to run in interactive sessions can go here
    if type -q nvm
      test -f ~/.nvmrc; and nvm use > /dev/null 2>&1
    end

    type -q starship; and starship init fish | source
    type -q zoxide; and zoxide init fish | source
    type -q bookmark; and bookmark init fish | source
end
