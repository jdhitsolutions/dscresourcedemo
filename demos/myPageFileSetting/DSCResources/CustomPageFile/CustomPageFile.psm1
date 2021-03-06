function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.UInt32]
        $InitialSize,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $MaximumSize
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $returnValue = @{
    InitialSize = [System.UInt32]
    MaximumSize = [System.UInt32]
    Name = [System.String]
    }

    $returnValue
    #>
    $CS = Get-CimInstance -ClassName Win32_PageFileSetting 
    if ($cs.name) {
        Return @{
            Name        = $CS.Name
            InitialSize = $CS.InitialSize
            MaximumSize = $CS.MaximumSize
        }
    }
    else {
        Write-Warning "Page file is set to be managed automatically. You need to disable it first."

    }

} #Get


function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.UInt32]
        $InitialSize,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $MaximumSize
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1

    $pfs = Get-CimInstance -ClassName Win32_PageFileSetting 
    $property = @{
        InitialSize = $InitialSize
        MaximumSize = $MaximumSize
    }
                
    #commit the changes
   # this was the original expression
   $pfs | Set-CimInstance -Property $property
   
   #this is the version that works better with Pester
   #Set-CimInstance -InputObject $pfs -Property $property


} #Set


function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.UInt32]
        $InitialSize,

        [parameter(Mandatory = $true)]
        [System.UInt32]
        $MaximumSize
    )

    #Write-Verbose "Use this cmdlet to deliver information about command processing."

    #Write-Debug "Use this cmdlet to write debug information while troubleshooting."


    <#
    $result = [System.Boolean]
    
    $result
    #>
    $pfs = Get-CimInstance -ClassName Win32_PageFileSetting 
    if ($pfs.InitialSize -eq $InitialSize -AND $pfs.MaximumSize -eq $MaximumSize) {
        Return $True
    }
    Else {
        Return $False
    }
} #Test


Export-ModuleMember -Function *-TargetResource

