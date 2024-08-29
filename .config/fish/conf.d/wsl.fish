if set -q WSL_DISTRO_NAME
  set -x GPG_TTY $(tty)
end