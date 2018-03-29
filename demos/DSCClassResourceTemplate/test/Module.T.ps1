$ModuleName = "<%=$PLASTER_PARAM_ModuleName%>.psm1"
$ModuleManifestPath = "$PSScriptRoot\..\<%=$PLASTER_PARAM_ModuleName%>.psd1"
$ModulePath = "$PSScriptRoot\..\$ModuleName"

Import-module $Modulepath -force

InModuleScope <%=$PLASTER_PARAM_ModuleName%> {

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

Describe '<%=$PLASTER_PARAM_ModuleName%> Manifest Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

Describe <%=$PLASTER_PARAM_ResourceName%> {

    Context Get {

    } #get

    Context Set {


    } #set

    Context Test {

    }

} 

} #inModuleScope

Remove-Module <%=$PLASTER_PARAM_ModuleName%>
