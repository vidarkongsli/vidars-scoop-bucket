(gc $psScriptRoot\template.ini) -replace '\$installDir\$',$PsScriptRoot > $psScriptRoot\install.ini

& $PSScriptRoot\Firefox%20Setup%20Stub%2034.0.5.exe /INI="$PSScriptRoot\install.ini" -ms
