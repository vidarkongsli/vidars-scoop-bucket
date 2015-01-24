(gc $psScriptRoot\template.ini) -replace '\$installDir\$',$PsScriptRoot > $psScriptRoot\install.ini

& $PSScriptRoot\Firefox%20Setup%2035.0.exe /INI="`"$PSScriptRoot\install.ini`"" -ms
