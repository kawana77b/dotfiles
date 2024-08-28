#!/bin/bash

set -e

home_dir=$HOME
base_dir="$home_dir/dotfiles"
config_dir="$base_dir/.config"

home_files=(
  ".vimrc"
  ".tigrc"
)

dot_configs=(
  "starship.toml"
  "fish"
  "nvim"
  "powershell"
)

linux_config_dirs=(
  "terminator"
)

usage() {
  echo "Description: Setup dotfiles"
  echo "Usage: $0 {install|uninstall}"
  exit 1
}

create_symlink() {
  src=$1
  dst=$2
  if [ -e "$dst" ]; then
    echo "Skip: $dst already exists"
  else
    echo "Linking: $dst -> $src"
    ln -s "$src" "$dst"
  fi
}

remove_symlink() {
  dst=$1
  if [ -L "$dst" ]; then
    echo "Unlinking: $dst"
    unlink "$dst"
  else
    echo "Skip: $dst is not a symlink"
  fi
}

if [ $# -ne 1 ]; then
  usage
fi

case "$1" in
  install)
    echo "Setting up dotfiles"
    echo "--- Installing Configs ---"

    for file in "${home_files[@]}"; do
      create_symlink "$base_dir/$file" "$home_dir/$file"
    done

    mkdir -p "$home_dir/.config"
    for config in "${dot_configs[@]}"; do
      create_symlink "$config_dir/$config" "$home_dir/.config/$config"
    done

    if uname -s | grep -q "Linux"; then
      for config in "${linux_config_dirs[@]}"; do
        create_symlink "$config_dir/$config" "$home_dir/.config/$config"
      done
    fi

    echo "...Installation complete."
    ;;
  
  uninstall)
    echo "Uninstalling dotfiles"
    echo "--- Removing Configs ---"

    for file in "${home_files[@]}"; do
      remove_symlink "$home_dir/$file"
    done

    for config in "${dot_configs[@]}"; do
      remove_symlink "$home_dir/.config/$config"
    done

    if uname -s | grep -q "Linux"; then
      for config in "${linux_config_dirs[@]}"; do
        remove_symlink "$home_dir/.config/$config"
      done
    fi

    echo "...Uninstallation complete."
    ;;
  
  *)
    usage
    ;;
esac
