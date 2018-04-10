Return "This is a demo script you dunderhead."

#region start with code

Get-WindowsErrorReporting
Disable-WindowsErrorReporting
Enable-WindowsErrorReporting

#endregion

#region xDSCResourceDesigner

# https://github.com/PowerShell/xDSCResourceDesigner
find-module xdscresourcedesigner  
# install-module xdscresourcedesigner

Get-command -module xDSCResourceDesigner

#endregion

#region Create a resource

# https://docs.microsoft.com/en-us/powershell/dsc/authoringresourcemof

$prop = New-xDscResourceProperty -Name Enabled -Type Boolean -Attribute Key
$prop

New-xDscResource -Name myWER -Property $prop -Path . -ModuleName myWERConfiguration -Force

#endregion

#region Edit

psedit .\myWERConfiguration\DSCResources\myWER\myWER.psm1

#copy files
Copy-Item -path .\myWERConfiguration -Recurse -Container -Destination $env:ProgramFiles\WindowsPowerShell\Modules -force -PassThru

#endregion

#region Testing

Test-xDscSchema .\myWERConfiguration\DSCResources\myWER\myWER.schema.mof
Test-xDscResource -Name myWER
Get-dscresource myWER -Syntax

help Invoke-DscResource

$config = @{
    Enabled = $True
}

Invoke-DscResource -name myWER -modulename myWERConfiguration -method test -Property $config -verbose
Invoke-DscResource -name myWER -modulename myWERConfiguration -method set -Property $config -verbose
Invoke-DscResource -name myWER -modulename myWERConfiguration -method get -Property $config -verbose

#endregion
