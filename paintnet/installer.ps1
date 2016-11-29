$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
dir $scriptPath
& $scriptPath\paint.net.4.0.12.install.exe /auto "TARGET=$scriptPath" DESKTOPSHORTCUT=0
del $scriptPath\paint.net.4.0.12.install.exe