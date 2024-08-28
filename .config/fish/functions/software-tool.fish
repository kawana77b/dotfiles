function software-tool --argument-names cmd --description "Manage various OS package repositories."
  set -l repos snap flatpak brew apt

  switch $cmd
    case "" -h --help
      echo "software-tool (fish-function):"
      echo "    Manage various OS package repositories."
      echo ""
      echo "    Options:"
      echo "      -h/--help: help"
      echo ""
      echo "    SUBCOMMANDS:"
      echo "      update: Update various package repositories. For example: $(string join ', ' $repos)."
      echo "              Update only that package manager by supplying a variable-length argument."
      return 0
    case update
      set -l _repos $repos
      if test (count $argv) -ge 2
          set _repos $argv[2..(count $argv)]
      end

      for repo in $_repos
        if not contains $repo $repos; or ! type -q $repo
          continue
        end

        echo "💡 $repo"
        switch $repo
          case snap
            sudo snap refresh
          case flatpak
            flatpak update
          case brew
            brew update
          case apt
            if test (uname -s) = "Linux"
              sudo apt update && sudo apt upgrade
            end
        end
      end
  end

  return 0
end
