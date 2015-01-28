$text = gc $profile
if(($text | sls 'setenvforvs.ps1') -eq $null) {
    Exit 0
}

$new_profile = $text -replace [regex]::escape("try { & 'setenvforvs.ps1'} catch { }"), ''
$new_profile > $profile