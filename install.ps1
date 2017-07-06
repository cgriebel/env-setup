 param (
    [switch]$install = $false
 )

Write-Host $PSBoundParameters

$wid=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$prp=new-object System.Security.Principal.WindowsPrincipal($wid)
$adm=[System.Security.Principal.WindowsBuiltInRole]::Administrator
$IsAdmin=$prp.IsInRole($adm)
if (!$IsAdmin)
{
    Write-Host $myinvocation.mycommand.definition
    Write-Host "This script can only be ran with elevated rights" -ForegroundColor "white" -BackgroundColor "red"
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

$client = New-Object System.Net.WebClient

# #todo add check for file
function DownloadSetupFile
{
    param([string]$output_name, [string]$url )
    if($install){
        $start_time = Get-Date
        Write-Host "Downloading $output_name" -ForegroundColor "green"
        Write-Host "    from $url"
        $file_name = [System.IO.Path]::GetTempFileName();
        $client.DownloadFile($url, "C:\\$file_name.exe")
        Write-Host "    Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)\n"
        Invoke-Expression ".\$file_name.exe" | Out-Null
    }
}

DownloadSetupFile "VS Code" "https://go.microsoft.com/fwlink/?LinkID=623230" 
# DownloadSetupFile "ditto.exe" "Ditto" `
#     "https://downloads.sourceforge.net/project/ditto-cp/Ditto/3.21.134.0/DittoSetup_3_21_134_0.exe?r=http%3A%2F%2Fditto-cp.sourceforge.net%2F&ts=1499303979&use_mirror=ayera"
DownloadSetupFile
# Git
Write-Host "Copying .gitconfig to $env:userprofile"
Copy-Item "$PSScriptRoot\.gitconfig" "$env:userprofile"


# Posh Git
if($install){
    Install-PackageProvider NuGet -Force
    Import-PackageProvider NuGet -Force
    PowerShellGet\Install-Module posh-git -Scope CurrentUser
    Update-Module posh-git
    Import-Module posh-git
    Add-PoshGitToProfile
}

Read-Host -Prompt "Press Enter to exit"
