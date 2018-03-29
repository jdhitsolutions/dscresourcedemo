#http://stackoverflow.com/questions/32743812/testing-a-powershell-dsc-script-class-with-pester-unable-to-find-type-classna

#import your DSC class-based module
function New-PSClassInstance {
    param(
        [Parameter(Mandatory)]
        [String]$TypeName,
        [object[]]$ArgumentList = $null
    )
    $ts = [System.AppDomain]::CurrentDomain.GetAssemblies() |
        Where-Object Location -eq $null |
        Foreach-Object {
        $_.Gettypes()
    } | Where-Object name -eq $TypeName |
        Select-Object -Last 1

    if ($ts) {
        [System.Activator]::CreateInstance($ts, $ArgumentList )
    }
    else {
        $typeException = New-Object TypeLoadException $TypeName
        $typeException.Data.Add("ArgumentList", $ArgumentList)
        throw $typeException
    }
}

#$Class = New-PSClassinstance -TypeName myclass