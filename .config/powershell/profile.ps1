# -> $HOME\Documents\PowerShell\Profile.ps1

#--------------------------------
# Env
#--------------------------------
#起動時エンコーディングをUTF-8で設定する
$OutputEncoding = [System.Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

if ($IsWindows) {
  $env:LANG = "ja_JP.UTF-8"
}

# $env:VAGRANT_HOME = "D:\Vagrant\.vagrant.d"

# starship
$env:STARSHIP_CONFIG = "$HOME\.config\starship.toml"
if ($IsWindows) {
  $env:STARSHIP_CACHE = "$HOME\AppData\Local\Temp"
}

# GOLANG
$env:GOPATH = "$HOME\go"
$env:PATH = $env:PATH + ";$env:GOPATH"
## go getでプライベートリポジトリを取得するための設定
# $env:GOPRIVATE = ""
# $env:GOINSECURE = ""
# ~/Documents/PowerShell/Scripts/go.ps1があれば読み込む (自宅用)
if ($IsWindows -and (Test-Path "$HOME\Documents\PowerShell\Scripts\go.ps1")) {
  . "$HOME\Documents\PowerShell\Scripts\go.ps1"
}

# zoxide
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
  $env:_ZO_FZF_OPTS = '--height 40% --reverse'
  Invoke-Expression (& {
      $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
      (zoxide init --hook $hook powershell) -join "`n"
    })
}

# -------------------------------
# Functions
# -------------------------------

# -- 移動系

# 親ディレクトリへ移動する
function bd() {
  Set-Location ../
}

# ホームディレクトリへ移動する
function tohome() {
  Set-Location $HOME
}

if ($IsWindows) {
  # デスクトップへ移動する
  function todesktop() {
    $dir = Join-Path $HOME "Desktop"
    Set-Location $dir
  }

  # ドキュメントへ移動する
  function todocuments() {
    $dir = Join-Path $HOME "Documents"
    Set-Location $dir
  }

  # ダウンロードへ移動する
  function todownloads() {
    $dir = Join-Path $HOME "Downloads"
    Set-Location $dir
  }

  # ゴミ箱を開く
  function gabage() {
    Start-Process Shell:RecycleBinFolder
  }

  # 管理者権限で実行する
  function sudo($program, $arg) {
    if ($null -eq $arg) {
      Start-Process $program -Verb runas
    }
    else {
      Start-Process $program -Verb runas $arg
    }
  }

  if (Get-Command wt -ErrorAction SilentlyContinue) {
    # Windows Terminalで新規ディスプレイで指定ディレクトリを開く
    function wtd([string] $path) {
      if ([string]::IsNullOrEmpty($path) -eq $true) {
        $path = $PWD
      }
      wt -d $path
    }
  }

  # D://のルートがあればそこに移動する
  function tod() {
    $d_drive = Get-PSDrive | Where-Object { $_.Root -match "D:" }
    if ($null -eq $d_drive) {
      return;
    }
    $d_rootPath = $d_drive.Root
    if (Test-Path $d_rootPath) {
      Set-Location $d_rootPath
    }
  }
}

# powershellのユーザプロファイルディレクトリへ移動する
function touserprof() {
  $dir = (Get-Item $Profile.CurrentUserAllHosts).DirectoryName
  Set-Location $dir
}


# 再帰的にパス傘下のファイル・ディレクトリを消去
function rmall {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$DirectoryPath
  )

  if (Test-Path $DirectoryPath -PathType Container) {
    Remove-Item -Recurse -Force -Path $DirectoryPath 
    Write-Host "Directory removed: $DirectoryPath"
  }
  else {
    Write-Host "Directory not found: $DirectoryPath"
  }
}

# このセッションのみps1スクリプトを実行できるように実行ポリシーをセット
function setScriptablePolicy() {
  $currentPolicy = Get-ExecutionPolicy
  Set-ExecutionPolicy RemoteSigned -Scope Process -Force
  Write-Output ("ChangedPolicy in only this session: $currentPolicy --> " + (Get-ExecutionPolicy))
}

# 本セッション以外も含めた全てのコマンド履歴を(デフォルトでは最新から)順に取得する
function getHistory(
  [int]
  $First,
  [int]
  $Last,
  [switch]
  $FromOld = $false
) {
  $hists = Get-Content ((Get-PSReadlineOption).HistorySavePath)

  if ($FromOld -eq $false) {
    [System.Array]::Reverse(($hists))
  }

  if ($First -gt 0) {
    return $hists | Select-Object -First $First
  }

  if ($Last -gt 0) {
    return $hists | Select-Object -Last $Last
  }

  return $hists
}

if ($IsWindows -and (Get-Command conda -ErrorAction SilentlyContinue)) {
  function useconda() {
    #region conda initialize
    # !! Contents within this block are managed by 'conda init' !!
    If (Test-Path "$HOME\anaconda3\Scripts\conda.exe") {
    (& "$HOME\anaconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | Where-Object { $_ } | Invoke-Expression
    }
    #endregion
  }
}

# Reads Autoload Files
if ($IsWindows) {
  $psdir = Join-Path (Split-Path -Parent $PROFILE.CurrentUserAllHosts) "autoload"
  if (Test-Path -Path $psdir) {
    Get-ChildItem "${psdir}\*.ps1" | ForEach-Object { .$_ }
  }
  $psdir = $null
}

# DockerCompletion
# https://www.powershellgallery.com/packages/DockerCompletion
if ($IsWindows -and (Get-Command docker -ErrorAction SilentlyContinue)) {
  if (Get-Module -Name DockerCompletion -ErrorAction SilentlyContinue) {
    Import-Module DockerCompletion
  }
  if (Get-Module -Name CompletionPredictor -ErrorAction SilentlyContinue) {
    Import-Module CompletionPredictor
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin
  }
}

# starship
if ($IsWindows -and (Get-Command starship -ErrorAction SilentlyContinue)) {
  Invoke-Expression (&starship init powershell)
}

# -------------------------------
# Alias
# -------------------------------
## Default
Set-Alias touch New-Item
Set-Alias new New-Object
Set-Alias which Get-Command

## Windows
if ($IsWindows) {
  Set-Alias open explorer.exe
}

## Specialized
if (Get-Command fd -ErrorAction SilentlyContinue) {
  Set-Alias find fd
}

if (Get-Command rg -ErrorAction SilentlyContinue) {
  Set-Alias grep rg
}

if (Get-Command nvim -ErrorAction SilentlyContinue) {
  Set-Alias vim nvim
}

if (Get-Command tre -ErrorAction SilentlyContinue) {
  Set-Alias tree tre
}