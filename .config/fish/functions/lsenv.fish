function lsenv --argument-names cmd --description "Displays various information depending on the given subcommand"
  set -l os (uname -s)

  switch $cmd
    case "" --help -h
      echo "lsenv (fish-function): "
      echo "      Displays various information depending on the given subcommand."
      echo ""
      echo "      Options:"
      echo "         -h/--help : help"
      echo ""
      echo "      SUBCOMMANDS:"
      echo "         env       : Displays a list of environment variables"
      echo "         user      : Displays a variety of user-related information"
      echo "         path      : Displays a list of PATH." 
      echo "         globalip  : Displays Global IP Address"
      echo "         git       : Displays a list of git config" 
      echo "         os        : Display information about the OS by locating the configuration file" 
      echo "         nw        : Display network connection status"
      # -- Linux ---
      if test $os = "Linux"
      echo "         users     : Displays a list of registered users"
      echo "         group     : Displays a list of groups. If the user is a member, the user is shown" 
      echo "         systemctl : Displays the service status of systemctl"
      end
      # ------------
    case env
      env | awk -F '=' '{ printf "%-50s | %s\n", $1, $2 }'
      return 0

    case user
      set -l keys kernel os lang user groups shell ipv4 ipv6 systemenv hosts grub
      for k in $keys
        set -l v ""
        switch $k
          case kernel
            set v (uname -s)
          case os
            set v (echo (uname -o) (uname -r) (uname -p))
          case lang
            set v (echo $LANG)
          case user
            set v (whoami)
          case groups
            if test $os = "Linux"; and type -q groups
              set v (groups $USER | awk -F ":" '{ printf "%s", $2 }' | string trim)
            end
          case shell
          case ipv4
            type -q ip; and set v (ip -4 addr show | awk '/inet / {print $2}' | cut -d/ -f1 | awk '{printf "%s ", $0}' | string trim)
          case ipv6
            type -q ip; and set v (ip -6 addr show | awk '/inet6 / {print $2}' | cut -d/ -f1 | awk '{printf "%s ", $0}' | string trim)
          case systemenv
            test -f /etc/environment; and set v "/etc/environment"
          case hosts
            test -f /etc/hosts; and set v "/etc/hosts"
          case grub
            test -f /etc/default/grub; and set v "/etc/default/grub"
        end

        if test $v != ""
          echo "$k=" $v | awk -F '=' '{ printf "%-20s | %s\n", $1, $2 }'
        end
      end
      set -e keys
      return 0

    case path
      echo $PATH | sed -e 's/ /\n/g'
      return 0

    case globalip
      if type -q curl
        curl inet-ip.info
      end
      return 0

    case git
      if type -q git
        git config --list | awk -F '=' '{ printf "%-50s | %s\n", $1, $2 }'
      end
      return 0

    case os
      if test $os = "Linux"
        grep -H "" /etc/*version
        grep -H "" /etc/*release
        return 0
      else if test $os = "Darwin"
        sw_vers
        return 0
      else
        return 1
      end

    case nw
      if test $os = "Linux"
        type -q nmcli; and nmcli device status
      else if test $os = "Darwin"
        type -q jq; and system_profiler SPAirPortDataType -json | jq ".SPAirPortDataType.[].spairport_airport_interfaces.[].spairport_current_network_information"
      else
        return 1
      end
      return 0
  end

  if test $os = "Linux"
    switch $cmd
      case users
        if test -f /etc/passwd
          cut -d: -f1 /etc/passwd
        end
        return 0

      case group
        if test -f /etc/group
          awk -F: '{ if ($4 == "") printf "%-30s | %s\n", $1, "-"; else printf "%-30s | %s\n", $1, $4 }' /etc/group
        end
        return 0

      case systemctl
        if type -q systemctl
          systemctl list-unit-files -t service --no-pager | grep --color=never -E 'enabled|disabled'
        end
        return 0
    end
  end

  return 0
end
