# brew
if test (uname -s) = "Darwin"; and test -d /opt/homebrew
  eval (/opt/homebrew/bin/brew shellenv)
else if test (uname -s) = "Linux"; and test -d /home/linuxbrew/.linuxbrew
  eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

test -d $HOME/.local/bin; and set -gx PATH $HOME/.local/bin $PATH

# webi
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
