
#this may have issues when running in VSCode or there might be a caching problem
#You might need to run repeated tests in new sessions

# powershell -noprofile -command {Invoke-Pester}
import-module $psscriptroot\..\myPageFileSettingClass.psd1 -Force

InModuleScope MyPagefileSettingClass {
    function New-PSClassInstance {
        [cmdletbinding()]
        param(
            [Parameter(Mandatory)]
            [String]$TypeName,
            [object[]]$ArgumentList = $null
        )
        Write-Verbose "Starting $($myinvocation.MyCommand)"
        Write-Verbose "Searching for class $Typename"
        $ts = [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Where-Object Location -eq $null |
            Foreach-Object {
            $_.Gettypes()
        } | Where-Object name -eq $TypeName |
            Select-Object -Last 1
    
        if ($ts) {
            Write-Verbose "Creating an instance of $ts"
            [System.Activator]::CreateInstance($ts, $ArgumentList )
        }
        else {
            Write-Verbose "An exception happened"
            $typeException = New-Object TypeLoadException $TypeName
            $typeException.Data.Add("ArgumentList", $ArgumentList)
            throw $typeException
        }
        Write-Verbose "Ending $($myinvocation.MyCommand)"
    }

    Describe CustomPageFile2 {
        $instance = New-PSClassInstance -typename CustomPageFile2
        $instance.Initialsize = 1024
        $instance.Maximumsize = 2048
        $instance.Name = "c:\pagefile.sys"
        
        It "Should have a name property of c:\pagefile.sys" {
            $instance.name | Should be "c:\pagefile.sys"
        }
        It "Should have an initial size of 1024" {
            $instance.Initialsize | should be 1024
        }
        It "Should have an max size of 2048" {
            $instance.Maximumsize | should be 2048
        }
        
        Context Set {
            $instance2 = New-PSClassInstance -typename CustomPageFile2 
            $instance2.InitialSize = 1024
            $instance2.MaximumSize = 4096
            $instance2.Name = "c:\pagefile.sys" 
            $instance2 | Out-String | Write-Verbose   

            Mock Get-CimInstance {
                New-Ciminstance -ClientOnly -ClassName 'Win32_PageFileSetting' -Property @{
                   InitialSize = 0
                   MaximumSize = 0
                   Name = "c:\pagefile.sys"
               }                
           } -ParameterFilter {$Classname -eq "Win32_PageFileSetting"} -Verifiable
            Mock Set-CimInstance {}
            $result = $instance2.Set()

            It "Should call Get-CimInstance" {
                Assert-VerifiableMock
            }
            It "Should call Set-Ciminstance once" {
                Assert-MockCalled -CommandName Set-CimInstance -Exactly -Times 1
            }

            It "It should not return an object" {
                $result | Should be $Null
            }
        } #set

        Context Test {
            $instance3 = New-PSClassInstance -typename CustomPageFile2 
            $instance3.InitialSize = 2048
            $instance3.MaximumSize = 4096
            $instance3.Name = "c:\pagefile.sys" 
            $instance3 | out-string | Write-Verbose          
            Mock Get-CimInstance {
                 New-Ciminstance -ClientOnly -ClassName 'Win32_PageFileSetting' -Property @{
                    InitialSize = 2048
                    MaximumSize = 4096
                    Name = "c:\pagefile.sys"
                }                
            } -ParameterFilter {$Classname -eq "Win32_PageFileSetting"} -Verifiable
            $result = $instance3.Test() 
          
            It "Should return a boolean" {
                $result.GetType().name  | Should be "boolean"
            }
            It "Should call Get-CimInstance" {
                Assert-VerifiableMock
            }
            It "Should return True" {
                $result | Should be $True
            }
            It "Should fail on a property mismatch" {
                $instance3.InitialSize = 1024
                $result = $instance3.Test()
                $result | Should be $False
            }
        } #test

        Context Get {
            $instance4 = New-PSClassInstance -typename CustomPageFile2 
            $instance4.InitialSize = 2048
            $instance4.MaximumSize = 4096
            $instance4.Name = "c:\pagefile.sys" 
            $instance4 | out-string | Write-Verbose   

            Mock Get-CimInstance {
                Write-Verbose "In the mock"
                 New-Ciminstance -ClientOnly -ClassName 'Win32_PageFileSetting' -Property @{
                    InitialSize = 2048
                    MaximumSize = 4096
                    Name = "c:\pagefile.sys"
                }                
            } -ParameterFilter {$Classname -eq "Win32_PageFileSetting"} -Verifiable
            
            $result = $instance.Get()

            It "Should call Get-CimInstance" {
                Assert-VerifiableMock
            }
            It "Should return the pagefile name" {
                $result.name | Should be "c:\pagefile.sys"
            }

            It "Should return the initial size" {
                $result.InitialSize | Should be 2048
            }

            It "Should return the maximum size" {
                $result.Maximumsize | Should be 4096
            }
        } #get
    } #describe custom page file class

    Describe "AutomaticManagedPageFile2" {
        It -Pending "Has no tests at this time" {}
    }
} #module scope

Remove-module myPageFileSettingClass