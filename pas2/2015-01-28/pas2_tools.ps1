param (
	[Parameter(Mandatory)]
	[ValidateSet('init','build','init-frontend')]
	$cmd
)
$ErrorActionPreference = 'stop'

$sln = 'UDIR.PAS2.All.sln'

$runNpmInstall = {
	npm install --msvs_version=2013
}

$buildFrontend = {
	gulp copy-to-content
}

function goto-andRun($relativeDir, $script) {
	pushd $relativeDir
	& $script
	popd
}

ssh -T git@github.com | out-null
if ($lastexitcode -eq 255) {
	Write-error "Could not log in to GitHub. Get your act together an install SSH keys"
}

if ($cmd -eq 'init') {
	
	if (test-path .\.git) {
		Write-error "Current directory is already a git repo."
	}
	git clone git@github.com:Utdanningsdirektoratet/PAS2-hoved.git
}

if ($cmd -eq 'build') {
	if (-not(test-path .\$sln)) {
		Write-error "$sln not found in the current directory."
	}
	msbuild /target:build /p:Configuration=Debug
}

if ($cmd -eq 'init-frontend') {
	if (test-path .\$sln) {
		goto-andRun 'UDIR.PAS2.Web\ContentSrc' { $runNpmInstall;$buildFrontend }
	} elseif (test-path .\UDIR.PAS2.Web.csproj) {
		goto-andRun .\ContentSrc { $runNpmInstall;$buildFrontend }	
	} elseif (test-path .\gulpfile.js) {
		& { $runNpmInstall;$buildFrontend }
	} else {
		Write-error "Source not found."
	}
}
