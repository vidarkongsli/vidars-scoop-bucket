if(!(test-path $profile)) {
    $profile_dir = split-path $profile
    if(!(test-path $profile_dir)) { mkdir $profile_dir > $null } 
    '' > $profile
}

$text = gc $profile
if(($text | sls 'setenvforvs') -eq $null) {
    write-host 'Adding Visual Studio environment init to your powershell profile'

    # read and write whole profile to avoid problems with line endings and encodings
    $new_profile = @($text) + "try { & 'setenvforvs.ps1'} catch { }"
    $new_profile > $profile
} else {
    write-host 'it looks like the Visual Studio init is already in your powershell profile, skipping'
}