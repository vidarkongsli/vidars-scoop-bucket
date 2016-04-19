param(
    $version = '3.5.2'
    )
$args = "/x `"$PSScriptRoot\Setup NcFTP $version.msi`" /qn"
Start-process -FilePath 'msiexec' -ArgumentList $args -Wait