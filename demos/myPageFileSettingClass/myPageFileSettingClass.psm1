#You need a unique resource name

[DscResource()]
Class AutomaticManagedPageFile2 {
[DSCProperty(Key)]  
[ValidateSet("True","False")]
[String]$Enabled

# Sets the desired state of the resource.
[void] Set() {
    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1   
    
    $cs = Get-CimInstance -classname win32_computersystem 

    if ($this.Enabled -eq "True") {
        $property = @{AutomaticManagedPageFile = $True}
    }
    else {
        $property = @{AutomaticManagedPageFile = $False}
    }
       
    #commit the changes
    $cs | Set-CimInstance -Property $property 
            
} #Set        
    
# Tests if the resource is in the desired state.
[bool] Test() {   

    $cs = Get-CimInstance -classname win32_computersystem 
    if ($this.Enabled -eq $CS.AutomaticManagedPagefile) {
        Return $True
    }
    else {
        Return $False
    }
    
} #Test    

# Gets the resource's current state.
[AutomaticManagedPageFile2] Get()  {        

    # Return this instance or construct a new instance.
    $cs = Get-CimInstance win32_computersystem 
    $this.Enabled = $cs.AutomaticManagedPageFile
    return $this 

} #Get   

} #end class AutomaticManagedPageFile2

#You need a unique resource name

[DscResource()]
Class CustomPageFile2 {


#Set the initial size in MB
[DSCProperty(Key)]  
[UInt32]$InitialSize 

#Set the maximum size in MB
[DscProperty(Mandatory)]  
[UInt32]$MaximumSize 

[DscProperty(NotConfigurable)]  
[String]$Name

# Sets the desired state of the resource.
[void] Set() {
    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1   
    
    $pfs = Get-CimInstance -ClassName Win32_PageFileSetting 
    $property = @{
        InitialSize = $this.InitialSize
        MaximumSize = $this.MaximumSize
    }
            
        #commit the changes
        $pfs | Set-CimInstance -Property $property 
            
} #Set        
    
# Tests if the resource is in the desired state.
[bool] Test() {   

    $pfs =  Get-CimInstance -ClassName Win32_PageFileSetting 
    if ($pfs.InitialSize -eq $this.InitialSize -AND $pfs.MaximumSize -eq $this.MaximumSize) {
        Return $True
    }
    Else {
        Return $False
    }
} #Test    

# Gets the resource's current state.
[CustomPageFile2] Get()  {        

    # Return this instance or construct a new instance.
    $cs = Get-CimInstance -ClassName Win32_PageFileSetting 
    if ($cs.name) {
        $this.Name        = $CS.Name
        $this.InitialSize = $CS.InitialSize
        $this.MaximumSize = $CS.MaximumSize
    }
    else {
        Write-Warning "Page file is set to be managed automatically. You need to disable it first."
    }
        return $this
} #Get   

} #end class CustomPageFile2
