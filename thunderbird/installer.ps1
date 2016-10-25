(gc $psScriptRoot\template.ini) -replace '\$installDir\$',$PsScriptRoot > $psScriptRoot\install.ini

$exePath = join-path $PSScriptRoot 'Thunderbird%20Setup%2045.4.0.exe'
$iniPath = join-path $PsScriptRoot 'install.ini'
$args = "/INI=`"$iniPath`""
Start-process -FilePath $exePath -ArgumentList $args -Wait
