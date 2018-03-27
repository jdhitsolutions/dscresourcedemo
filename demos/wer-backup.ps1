function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $returnValue = @{
    Enabled = [System.Boolean]
    }

    $returnValue
    #>

    $wer = Get-WindowsErrorReporting
    Return @{
        Enabled = $wer
    }
} #get


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1

    if ($Enabled) {
        Enable-WindowsErrorReporting
    }
    else {
        Disable-WindowsErrorReporting
    }

} #set


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.Boolean]
        $Enabled
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $result = [System.Boolean]
    
    $result
    #>

    $wer = Get-WindowsErrorReporting

    if ($enabled -eq $Wer) {
        Return $True
    }
    else {
        Return $False
    }
} #test


Export-ModuleMember -Function *-TargetResource

