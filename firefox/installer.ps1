(gc $psScriptRoot\template.ini) -replace '\$installDir\$',$PsScriptRoot > $psScriptRoot\install.ini
$cmdLine = "`"Firefox%20Setup%2035.0.exe /INI=`"$PSScriptRoot\install.ini`"`""

& cmd /C $cmdline