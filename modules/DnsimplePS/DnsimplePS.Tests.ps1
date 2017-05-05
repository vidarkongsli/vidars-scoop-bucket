. $PSSCriptRoot\DnSimplePS.ps1

function WriteTheToken($account,$token,$p) {
    Write-AccessToken -Account $account -AccessToken $token -Path $p
}

Describe 'DnSimplePS module' {
    Context 'Token storage' {
        It 'Should write access tokens to file' {
            $p = join-path $TestDrive '.storage'
            WriteTheToken 'a' 'x' $p
            [xml](Get-Content $p) | Select-Xml "/s:Objs/s:Obj/s:DCT/s:En/s:S[text()='a']" `
                -ErrorAction 'silentlycontinue' `
                -Namespace @{s = 'http://schemas.microsoft.com/powershell/2004/04'} `
                | Should Not BeNullOrEmpty
        }

    }
}

