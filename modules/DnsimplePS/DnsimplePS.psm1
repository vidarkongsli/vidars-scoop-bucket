

function BaseUri($Account) {
    "https://api.dnsimple.com/v2/$Account/"
}

function RecordsUri($Account, $Zone) {
    "$(BaseUri $Account)zones/$Zone/records"
}

function RecordUri($Account, $Zone, $id) {
    "$(RecordsUri $Account $Zone)/$Id"
}

function Set-AccessToken($Token) {
    $script:_oauth2_access_token = $Token
}

function Create-Headers($Token) {
    $t = if ($Token) { $Token } else { $_oauth2_access_token }
    if (-not $t) {
        Write-Error "No access token."
        return
    }
    @{'Authorization'="Bearer $t"}
}

function Get-ZoneRecords{
    [CmdletBinding()]
    param(
        $Account,
        $Zone,
        $AccessToken = $null,
        $RecordType = $null,
        $Name = $null,
        $NameLike = $null
        )
    $old__errPref = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'stop'
        $Uri = "$(BaseUri $Account)zones/$Zone/records"
        $query = @{}
        if ($RecordType) { $query.Add('type',$RecordType) }
        if ($Name) { $query.Add('name', $Name) }
        if ($NameLike) { $query.Add('name_like', $NameLike) }
        if ($query.Count > 0) {
            $qRaw = $query | % { "$_.Name=$_.Value" } 
        }
        Write-Debug "Requesting: GET $Uri"
        Invoke-RestMethod -Method Get -Uri $Uri -Headers (Create-Headers $AccessToken) -UseBasicParsing `
            | Select-Object -ExpandProperty data
    } finally {
        $ErrorActionPreference = $old__errPref
    }
}

function Add-ZoneRecord {
    param(
        $Account,
        $Zone,
        $AccessToken,
        $RecordType = $null,
        $Name,
        $Content
        )

    $data = New-Object -Type PSObject -Property @{
        'name' = $Name
        'content' = $Content
        'type' = $RecordType
    }

    Invoke-RestMethod -Method POST -Uri (RecordsUri $Account $Zone) -Headers (Create-Headers $AccessToken) `
        -Body (ConvertTo-Json -InputObject $data) -ContentType 'application/json' `
        | Select-Object -ExpandProperty data
}

function Get-ZoneRecord {
    param(
        $Account,
        $Zone,
        $AccessToken,
        $Id
        )

    Invoke-RestMethod -Method GET -Uri (RecordUri $Account $Zone $Id) -Headers (Create-Headers $AccessToken) `
        | Select-Object -ExpandProperty data
}

function Remove-ZoneRecord {
    param(
        $Account,
        $Zone,
        $AccessToken,
        $Id,
        [switch]$Force
        )

    if (-not($Force)) {
        $choice = ""
        while ($choice -notmatch "[y|n]"){
            $choice = read-host "Deleting record. Are you sure? (Y/N)"
        }
        if ($choice -eq 'n') {
            Write-Host "Cancelled by user"
            Return
        }
    }
    $Uri = RecordUri $Account $Zone $Id
    Write-Debug "Requesting: DELETE $Uri"
    Invoke-RestMethod -Method DELETE -Uri $Uri -Headers (Create-Headers $AccessToken) `
        | Select-Object -ExpandProperty data
}

function Get-AccessToken {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        $clientId,
        [Parameter(Mandatory)]
        $clientSecret
        )

    $ie = new-object -ComObject InternetExplorer.application
    $ie.Height = 480
    $ie.Width = 640
    $ie.ToolBar = $false
    $ie.StatusBar = $false
    $ie.TheaterMode = $false
    $ie.AddressBar = $false
    $ie.Silent = $false
    $state = Get-Random
    $ie.Navigate("https://dnsimple.com/oauth/authorize?response_type=code&client_id=$clientId&state=$state&redirect_uri=https://github.com/vidarkongsli/vidars-scoop-bucket")
    $ie.Visible = $true
    while (-not($ie.LocationUrl -match "error=[^&]*|code=[^&]*") -and $ie.Visible -eq $true)
    {
        Start-Sleep -Milliseconds 200
    }
    $query = ($ie.LocationUrl -split '\?')[-1] -split '\&'
    $codeParameter = $query | ? { $_ -match '^code=' }
    $ie.Quit()
    if ($codeParameter) {
        $code = $codeParameter.Replace('code=','')
    } else {
        $error = $query | ? { $_ -match '^error=' }
        $errorDescription = $query | ? { $_ -match '^error_description=' }
        Write-error "No code found. Error: $error, $errorDescription"
    }
    invoke-restmethod -Method POST -Uri 'https://api.dnsimple.com/v2/oauth/access_token' `
        -Body @{
            'grant_type'='authorization_code'
            'client_id'=$clientId
            'client_secret'=$clientSecret
            'code'=$code
            'redirect_uri'='https://github.com/vidarkongsli/vidars-scoop-bucket'
            'state'=$state
        } `
        | Select-Object -ExpandProperty access_token
}

Export-ModuleMember -Function Add-ZoneRecord,Get-ZoneRecords,Get-ZoneRecord,Remove-ZoneRecord,Set-AccessToken,Get-AccessToken
