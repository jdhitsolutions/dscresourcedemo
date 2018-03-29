
import-module ..\CustomPageFile.psm1 -force

InModuleScope CustomPageFile {

    Describe  Test {

        Mock Get-CimInstance {
            New-Ciminstance -clientonly -class win32_pagefilesetting -property @{
                Name="c:\pagefile.sys"
                InitialSize=1024
                MaximumSize=2048
            }           
        } -ParameterFilter {$classname -eq "win32_pagefilesetting"} -Verifiable

        $result = Test-TargetResource -InitialSize 1024 -MaximumSize 2048
        It "Should run Get-CimInstance" {
            Assert-VerifiableMock
        }
        It "Should be true" {
            $result | Should be $True
        }

        It "Should be false when values don't match" {
            $result = Test-TargetResource -InitialSize 2048 -MaximumSize 4096
            $result | Should be $False
        }
    } #test

    Describe Set {
       
        Mock Get-CimInstance {
            New-Ciminstance -clientonly -class win32_pagefilesetting -property @{
                Name="c:\pagefile.sys"
                InitialSize=1024
                MaximumSize=2048
            }           
        } -ParameterFilter {$classname -eq "win32_pagefilesetting"} -Verifiable

        Mock Set-CimInstance { }
    
        $result = Set-TargetResource -InitialSize 1024 -MaximumSize 2048
   
        It "Runs Get-CimInstance" {
            Assert-VerifiableMock
        }
        It "Runs Set-CimInstance" {
            Assert-MockCalled -CommandName "Set-CimInstance"
        }
    } #set

    Describe Get {
        Mock Get-CimInstance {
            New-Ciminstance -clientonly -class win32_pagefilesetting -property @{
                Name="c:\pagefile.sys"
                InitialSize=1024
                MaximumSize=2048
            }   
        } -ParameterFilter {$classname -eq "win32_pagefilesetting"} -Verifiable

        $result = Get-TargetResource -InitialSize 1024 -MaximumSize 2048
        It "Should run Get-CimInstance" {
            Assert-VerifiableMock
        }

        It "Should have an initial size of 1024" {
            $result.initialSize | Should be 1024
        }

        It "Should have a maximum size of 2048" {
            $result.MaximumSize | should be 2048
        }

        It "Should have a name of c:\pagefile.sys" {
            $result.name | should be "C:\pagefile.sys"
        }

        It "Should fail if the pagefile is set to automatic" {
            Mock Get-Ciminstance {
                return $null
            } -ParameterFilter  {$classname -eq "win32_pagefilesetting"} 
            $result = Get-TargetResource -InitialSize 1024 -MaximumSize 2048 -WarningAction SilentlyContinue
            $result | Should be $null   
        }
    }#get

} #modulescope
