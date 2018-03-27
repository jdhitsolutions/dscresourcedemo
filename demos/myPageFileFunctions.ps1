#requires -version 5

Function Set-AutomaticManagedPageFile {
    #The default behavior is to enable automatic page file management
    
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Position = 0)]
        [string]$Computername = $env:COMPUTERNAME,
        [ValidateSet("Enabled", "Disabled")]
        [Parameter(Mandatory)]
        [String]$Setting,
        [switch]$Passthru
    )
    
    Write-Verbose "Connecting to $computername"
    
    $cs = Get-CimInstance win32_computersystem -ComputerName $Computername
    Write-Verbose "Current setting: $($cs.AutomaticManagedPageFile)"
    
    if ($Setting -eq 'Enabled') {
        Write-Verbose "Enabling Automatic Managed Page File"
        $property = @{AutomaticManagedPageFile = $True}
    }
    else {
        $property = @{AutomaticManagedPageFile = $False}
    }
    
    Write-verbose "Using settings"
    Write-Verbose ($property | out-string)
    
    #commit the changes
    $cs | Set-CimInstance -Property $property -PassThru:$Passthru |
        Select -ExpandProperty AutomaticManagedPageFile
    
    Write-Verbose "Setting complete. You might need to restart the server."
    
}
    
Function Set-PageFileSetting {
    #The default behavior is to enable automatic page file management
    #Sizes are in MB units
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Position = 0)]
        [string]$Computername = $env:computername,
        [uint32]$InitialSize = 0,
        [uint32]$MaximumSize,
        [switch]$Passthru
    )
    
    if (Get-AutomaticManagedPageFile -Computername $Computername) {
        Write-Warning "Page file is set to be managed automatically. You need to disable it first."
    }
    else {
        Write-Verbose "Connecting to $computername"
        $pfs = Get-CimInstance -ClassName Win32_PageFileSetting -ComputerName $Computername
        $property = @{}
        if ($InitialSize) {
            $property.Add("InitialSize", $InitialSize)
        }
        if ($MaximumSize) {
            $property.Add("Maximumsize", $MaximumSize)
        }
    
        Write-Verbose "Using settings"
        Write-Verbose ($property | out-string)
    
        #commit the changes
        $pfs | Set-CimInstance -Property $property -PassThru:$Passthru
    
        Write-Verbose "Setting complete. You might need to restart the server."
    } #else
    
}
    
Function Get-AutomaticManagedPageFile {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [string]$Computername = $env:COMPUTERNAME
    )
    
    Write-Verbose "Connecting to $computername"
    
    $cs = Get-CimInstance win32_computersystem -ComputerName $Computername
    $cs.AutomaticManagedPageFile
    
}
    
Function Get-PageFileSetting {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [string]$Computername = $env:COMPUTERNAME
    )
    
    
    if (Get-AutomaticManagedPageFile -Computername $Computername) {
        Write-Warning "Page file is set to be managed automatically. You need to disable it first."
    }
    else {
        Write-Verbose "Connecting to $computername"
        Get-CimInstance -ClassName Win32_PageFileSetting -ComputerName $Computername |
            Select PSComputername, Name, InitialSize, MaximumSize
    }
} 
    
Function Get-MyPageFile {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [ValidateNotNullorEmpty()]
        [string]$Computername = $env:COMPUTERNAME
    )
    
    Write-Verbose "Connecting to $computername"
    $cs = Get-CimInstance -ClassName win32_computersystem -ComputerName $computername
    
    
    if ($cs.AutomaticManagedPagefile) {
        $InitialSize = 0
        $MaximumSize = 0
    }
    else {
        #get pagefile setting if Automatic Management is $False
        $pfs = Get-PageFileSetting -Computername $computername
        $InitialSize = $pfs.InitialSize
        $MaximumSize = $pfs.MaximumSize
    }
    Get-CimInstance -ClassName Win32_PageFileUsage -ComputerName $Computername |
        Select Name, @{Name = "AutomaticManagement"; Expression = { $cs.AutomaticManagedPagefile}},
    @{Name = "InitialSize"; Expression = {$InitialSize}},
    @{Name = "MaximumSize"; Expression = {$MaximumSize}},
    @{Name = "Computername"; Expression = {$_.PSComputername}}
    
} 

    