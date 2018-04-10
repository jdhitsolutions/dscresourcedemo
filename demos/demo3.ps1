#create a class-based version

# https://docs.microsoft.com/en-us/powershell/dsc/authoringresourceclass
# https://www.petri.com/create-programmer-style-class-based-dsc-resources

Return "Still not a script - demo!"

Enum Ensure {
    "Absent"
    "Present"
}

[DscResource()]
Class myThing {

    [DSCProperty(Key)]
    [string]$Name

    [DscProperty(Mandatory)]
    [string]$Foo

    [DscProperty()]
    [string[]]$Other

    [void]Set() {

    }
    [bool]Test() {
        $result = $True
        return $result 
    }
    [myThing]Get() {
        return $this
    }
} #close class


#convert existing resource to a class
psedit .\Convert-Mof2Class.ps1

#paste results into new files
Convert-MofToClass xsmbshare | Set-Clipboard
Convert-MofToClass automaticManagedPagefile | Set-Clipboard

#Create a new module

mkdir myPageFileSettingClass
$mod = ".\myPageFileSettingClass\myPageFileSettingClass.psm1"
Convert-MofToClass automaticManagedPagefile | Set-Content -Path $mod
Convert-MoftoClass CustomPageFile | Add-Content -path $mod

#edit the module, copying code from the legacy module
psedit $mod

#create a manifest and EXPORT RESOURCES!
$manparam = @{
    Path = ".\myPageFileSettingClass\myPageFileSettingClass.psd1"
    DscResourcesToExport = "AutomaticManagedPageFile2","CustomPageFile2"
    RootModule = "myPageFileSettingclass.psm1"
    PowerShellVersion = "5.1"
}
New-ModuleManifest @manparam
psedit $manparam.path

#test it

$copy = @{
    Path = ".\myPageFileSettingClass" 
    Destination = "C:\Program Files\WindowsPowerShell\modules\"
    Recurse = $true
    Container = $true
    Force = $True
  }
  
  Copy-item @copy

  Get-DscResource AutomaticManagedPageFile2 -Syntax
  Get-DscResource CustomPageFile2 -Syntax

  $config = @{
    InitialSize = 2048
    MaximumSize = 4096
  }
  
  Invoke-DscResource -Name CustomPageFile2 -ModuleName myPageFileSettingClass -Method test -Property $config -Verbose
  Invoke-DscResource -Name CustomPageFile2 -ModuleName myPageFileSettingClass -Method get -Property $config -Verbose
  Invoke-DscResource -Name CustomPageFile2 -ModuleName myPageFileSettingClass -Method set -Property $config -Verbose
  
 $config = @{
    Enabled= "True"
  }

Invoke-DscResource -Name AutomaticManagedPageFile2 -ModuleName myPageFileSettingClass -Method test -Property $config -Verbose
Invoke-DscResource -Name AutomaticManagedPageFile2 -ModuleName myPageFileSettingclass -Method get -Property $config -Verbose
Invoke-DscResource -Name AutomaticManagedPageFile2 -ModuleName myPageFileSettingClass -Method set -Property $config -Verbose
