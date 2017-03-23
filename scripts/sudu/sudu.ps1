
if(!$args) { "usage: sudo <cmd...>"; exit 1 }

function is_admin {
    return ([System.Security.Principal.WindowsIdentity]::GetCurrent().UserClaims | ? { $_.Value -eq 'S-1-5-32-544'})
}

function sudo_do($parent_pid, $dir, $cmd) {
    $src = 'using System.Runtime.InteropServices;
    public class Kernel {
        [DllImport("kernel32.dll", SetLastError = true)]
        public static extern bool AttachConsole(uint dwProcessId);

        [DllImport("kernel32.dll", SetLastError = true, ExactSpelling = true)]
        public static extern bool FreeConsole();
    }'

    $kernel = add-type $src -passthru

    $kernel::freeconsole()
    $kernel::attachconsole($parent_pid)
        
    $p = new-object diagnostics.process; $start = $p.startinfo
    $start.filename = "powershell.exe"
    $start.arguments = "-noprofile -encodedcommand $cmd"
    $start.useshellexecute = $false
    $start.workingdirectory = $dir
    $p.start()
    $p.waitforexit()
    return $p.exitcode
}

function serialize($a, $escape) {
    if($a -is [string] -and $a -match '\s') { return "'$a'" }
    if($a -is [array]) {
        return $a | % { (serialize $_ $escape) -join ', ' }
    }
    if($escape) { return $a -replace '[>&]', '`$0' }
    return $a
}

if($args[0] -eq '-do') {
    $null, $dir, $parent_pid, $cmd = $args
    $exit_code = sudo_do $parent_pid $dir $cmd
    exit $exit_code
}

if(!(is_admin)) {
    [console]::error.writeline("sudo: you must be an administrator to run sudo")
    exit 1
}

function base64($s) {
    [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($s))
}

$c = if ($args[0] -eq '-please') {
    Get-History -Count 1 | select -expandproperty CommandLine
} else {
    ($MyInvocation | select -expandproperty Line).Replace("$($MyInvocation | select -expandproperty InvocationName) ",'')
}

$wd = serialize (convert-path $pwd) # convert-path in case pwd is a PSDrive

$savetitle = $host.ui.rawui.windowtitle
$p = new-object diagnostics.process; $start = $p.startinfo
$start.filename = "powershell.exe"
$start.arguments = "-noprofile & '$pscommandpath' -do $wd $pid $(base64 $c)`nexit $lastexitcode"
$start.verb = 'runas'
$start.windowstyle = 'hidden'
try { $null = $p.start() }
catch { exit 1 } # user didn't provide consent
$p.waitforexit()
$host.ui.rawui.windowtitle = $savetitle

exit $p.exitcode