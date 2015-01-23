
$iniContents = gc $PSScriptRoot\template.ini

$iniContents.Replace('$installdir$', $PSScriptRoot) > $PSScriptRoot\template.ini

#& $PSScriptRoot\Firefox%20Setup%20Stub%2034.0.5.exe /INI="$PSScriptRoot\template.ini"
