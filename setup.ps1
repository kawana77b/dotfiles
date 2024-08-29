<#
.SYNOPSIS
  Setup symlinks for dotfiles.
.DESCRIPTION
  The “install” argument creates a symbolic link and the “uninstall” argument removes the symbolic link.
#>

param(
  [Parameter(Mandatory = $false)]
  [ValidateSet("install", "uninstall")]
  [string]$Action
)

$symlinks = @(
  @{Link = (Split-Path -Parent $PROFILE.CurrentUserAllHosts) + "\Profile.ps1"; Target = "$HOME\dotfiles\.config\powershell\profile.ps1" },
  @{Link = "$HOME\.wslconfig"; Target = "$HOME\dotfiles\wsl\.wslconfig" },

  @{Link = "$HOME\.vimrc"; Target = "$HOME\dotfiles\.vimrc" },
  @{Link = "$env:LOCALAPPDATA\nvim"; Target = "$HOME\dotfiles\.config\nvim" },

  @{Link = "$HOME\.tigrc"; Target = "$HOME\dotfiles\.tigrc" },

  @{Link = "$HOME\.config\starship.toml"; Target = "$HOME\dotfiles\.config\starship.toml" }
)

function Install-Symlinks {
  param (
    [array]$links
  )
  foreach ($link in $links) {
    if (-Not (Test-Path $link.Link)) {
      Write-Host "Creating symbolic link: $($link.Link) -> $($link.Target)"
      New-Item -ItemType SymbolicLink -Path $link.Link -Target $link.Target
    }
    else {
      Write-Host "Link already exists: $($link.Link)"
    }
  }
}

function Uninstall-Symlinks {
  param (
    [array]$links
  )
  foreach ($link in $links) {
    if (Test-Path $link.Link) {
      Write-Host "Removing symbolic link: $($link.Link)"
      Remove-Item $link.Link
    }
    else {
      Write-Host "Link not found: $($link.Link)"
    }
  }
}

if (!$IsWindows) {
  Write-Host "This script is only for Windows."
  exit
}

switch ($Action) {
  "install" { Install-Symlinks -links $symlinks }
  "uninstall" { Uninstall-Symlinks -links $symlinks }
  default { Get-Help $MyInvocation.MyCommand.Path -Full; exit }
}
