if test -d $HOME/go
  set -gx PATH $HOME/go/bin $PATH
  set -gx GOPATH $HOME/go
  set -gx GOBIN $HOME/go/bin
end

if test -d $HOME/.dotnet
  set -gx PATH $HOME/.dotnet/tools $PATH
end

if test -d "$HOME/.wasmer"
  set -gx WASMER_DIR "$HOME/.wasmer"
  test -s "$WASMER_DIR/wasmer.sh"; and source "$WASMER_DIR/wasmer.sh"
end

if test -d "$HOME/.wasmtime"
  set -gx WASMTIME_HOME "$HOME/.wasmtime"
  string match -r ".wasmtime" "$PATH" > /dev/null; or set -gx PATH "$WASMTIME_HOME/bin" $PATH
end
