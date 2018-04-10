Return "Are you still trying to run demo scripts?"

#let's look at more complex example
#these commands work interactively
psedit .\myPageFileFunctions.ps1

<#

Planning: might need 2 resources

AutomaticManagedPageFile
 Enabled = True | False

CustomPageFile
[uint32] InitialSize [key]
[uint32] MaximumSize [mandatory]
  
#>

#region building the module

New-xDscResourceProperty -name Enabled -Attribute Key -Type Boolean | tee-object -Variable p1
$p1

New-xDscResource -Name AutomaticManagedPageFile -Property $p1 -ModuleName myPageFileSetting -Path . -Force

#add a second resource to the module
#Watch your types
New-xDscResourceProperty -Name InitialSize -Type Uint32 -Attribute Key -Description "Set the initial size in MB" | tee -var p2
New-xDscResourceProperty -Name MaximumSize -Type Uint32 -Attribute Required -Description "Set the maximum size in MB" | tee -var p3

#create a read-ony property
New-xDscResourceProperty -Name Name -Type String -Attribute Read | Tee-object -Variable p4

#append this resource to the existing module
New-xDscResource -Name CustomPageFile -Property $p2,$p3,$p4 -ModuleName myPageFileSetting -Path . -Force

#endregion

#region edit the modules

psedit .\myPageFileSetting\DSCResources\AutomaticManagedPageFile\AutomaticManagedPageFile.psm1
psedit .\myPageFileSetting\DSCResources\CustomPageFile\CustomPageFile.psm1

#copy
Copy-item -Path .\myPageFileSetting -Destination $env:ProgramFiles\WindowsPowerShell\Modules -Recurse -Container -force

#endregion

#region Test

Get-dscresource AutomaticManagedPageFile -Syntax

$config = @{
  Enabled=$False
}

Invoke-DscResource -Name AutomaticManagedPageFile -ModuleName myPageFileSetting -Method test -Property $config -Verbose
Invoke-DscResource -Name AutomaticManagedPageFile -ModuleName myPageFileSetting -Method get -Property $config -Verbose
Invoke-DscResource -Name AutomaticManagedPageFile -ModuleName myPageFileSetting -Method set -Property $config -Verbose

Get-DscResource CustomPageFile -Syntax
$config = @{
  InitialSize = 1024
  MaximumSize = 4096
}

Invoke-DscResource -Name CustomPageFile -ModuleName myPageFileSetting -Method test -Property $config -Verbose
Invoke-DscResource -Name CustomPageFile -ModuleName myPageFileSetting -Method get -Property $config -Verbose
Invoke-DscResource -Name CustomPageFile -ModuleName myPageFileSetting -Method set -Property $config -Verbose

#endregion

#region create a configuration

Configuration CustomPF {
  Param([string[]]$Computername)

  Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1
  Import-DscResource -ModuleName myPageFileSetting -ModuleVersion 1.0

  Node $Computername {
    AutomaticManagedPageFile DisablePF {
      Enabled = $False
    }

    CustomPageFile CustomPF {
      DependsOn = "[AutomaticManagedPageFile]DisablePF"
      InitialSize = 1024
      MaximumSize = 2048
    }
  }
}

CustomPF -Computername SRV1 

$sess = New-PSSession -vmname SRV1 -Credential company\artd

$copy = @{
  Path = "$env:ProgramFiles\WindowsPowerShell\Modules\myPageFileSetting" 
  Destination = "C:\Program Files\WindowsPowerShell\modules\"
  Recurse = $true
  Container = $true
  tosession = $sess
  Force = $True
}

Copy-item @copy

Invoke-Command {Get-dscresource *pagefile} -session $sess

$cim = new-cimsession -ComputerName SRV1 -Credential company\artd
cls
Start-DscConfiguration -Path .\CustomPF -wait -verbose -CimSession $cim

Get-DscConfiguration -CimSession $cim
Get-ciminstance win32_pagefilesetting -cimsession $cim | Select-Object *

#endregion
