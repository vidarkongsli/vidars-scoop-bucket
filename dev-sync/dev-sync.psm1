
$ErrorActionPreference = 'stop'

function mklink { cmd /c mklink /d $args }

function set-sync($syncRoot, $codeUserDirectory) {
    if (-not(test-path $syncRoot -PathType Container))
    {
        Write-Error "Path $syncRoot does not exist."     
    }
    if (test-path $codeUserDirectory) {
        $proceed = Read-Host "Current local data at $codeUserDirectory will be deleted. Are you sure? (y/n)"
        if ($proceed -ne 'y') {
            Write-host "Cancelled by user."
            return
        }
        Write-host "Removing existing local directory"
        remove-item $codeUserDirectory -Recurse -Force
    }

    mklink $codeUserDirectory $syncRoot
}

function set-vscodesync{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({test-path $_ -pathtype Container})]
        $oneDrivePath
    )

    $syncRoot = "$oneDrivePath\dev-sync\code\User"
    $codeUserDirectory = "$($env:APPDATA)\Code\User"
    set-sync $syncRoot $codeUserDirectory
}

function set-vssync{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({test-path $_ -pathtype Container})]
        $oneDrivePath
    )

    $syncRoot = "$oneDrivePath\dev-sync\vs\Code snippets"
    $codeUserDirectory = "$($env:USERPROFILE)\Documents\Visual Studio 2017\Code snippets"
    set-sync $syncRoot $codeUserDirectory
}

function set-pssync{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateScript({test-path $_ -pathtype Container})]
        $oneDrivePath
    )

    $syncRoot = "$oneDrivePath\documents\WindowsPowershell"
    $codeUserDirectory = split-path $profile
    set-sync $syncRoot $codeUserDirectory    
}

export-modulemember set-pssync,set-vscodesync,set-vssync