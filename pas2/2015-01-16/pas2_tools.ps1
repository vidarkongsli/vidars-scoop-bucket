param (
	$cmd
)
$ErrorActionPreference = 'stop'
if ($cmd -eq 'init') {
	if (test-path 'PAS2-Hoved') {
		Write-Error 'PAS2-Hoved already exists'
	}
	git clone git@github.com:Utdanningsdirektoratet/PAS2-hoved.git
	scoop update .\PAS2-Hoved\pas2_tools.json
}

	
