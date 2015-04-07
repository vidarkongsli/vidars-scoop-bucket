(gc $psScriptRoot\imagemagick.inf) -replace '\$installpath\$',$PsScriptRoot > $psScriptRoot\imagemagick000.inf
$cmdLine = "`"`"$PSScriptRoot\\ImageMagick-6.9.1-1-Q16-x64-dll.exe`" /LOADINF=`"$PSScriptRoot\imagemagick000.inf`"`"" /silent
write-debug (gc $psScriptRoot\imagemagick000.inf)
& cmd /C $cmdline