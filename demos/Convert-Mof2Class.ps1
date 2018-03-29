Function Convert-MofToClass {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory)]
        [string]$Name,
        [string]$Module
    )
    
    Try {
        $resource = Get-DscResource @PSBoundParameters -ErrorAction Stop
    }
    Catch {
        Throw $_
        #bail out
        Return
    }
    
    $mof = Get-Childitem -path "$($resource.ParentPath)\*.mof" 
    
    $import = Import-xDscSchema -Schema $mof
        
    $converted = foreach ($item in $($import.DscResourceProperties | Sort-Object -Property Attribute)) {
        Switch ($item.Attribute) {
            "Key" {
                $dsctype = "[DSCProperty(Key)]"
            }
            "Required" {
                $dsctype = "[DscProperty(Mandatory)]"
            }
            "Write" {
                $dsctype = "[DscProperty()]"
            }
            "Read" {
                $dsctype = "[DscProperty(NotConfigurable)]"
            }
    
        } #Switch
    
        if ($item.Description) {
        $prop = @"
`n`n#$($item.Description)
$dsctype  
"@
        }
        else {
            $prop = @"
`n$dsctype  
"@
        }

        if ($item.ValueMap) {
    
            $prop += @"
`n[ValidateSet('$($item.values -join "','")')]
"@
        }
    
        $prop += @"
`n[$($item.Type)]`$$($item.name)
"@
    
        $prop
    
    } #foreach item

#define a Get hashtable with the properties

$import.DscResourceProperties | foreach -Begin {

$get=@"
<#
`tyou may need to get most of these properties

"@
} -Process {

$get+= "`n`t`$this.$($_.name) = <code>"
} -end {
$get+="`n`t#>"
}
    
#create the class outline as a here string
    $outline = @"
#You need a unique resource name

[DscResource()]
Class $($import.ResourceName) {
$converted

# Sets the desired state of the resource.
[void] Set() {
    #Include this line if the resource requires a system reboot.
    #`$global:DSCMachineStatus = 1   
    
    #Insert your code here 
            
} #Set        
    
# Tests if the resource is in the desired state.
[bool] Test() {   

    `$result = #<Insert your code here>      
    
    return `$result
    
} #Test    

# Gets the resource's current state.
[$($import.ResourceName)] Get()  {        

    # Return this instance or construct a new instance.
    $get

    return `$this 

} #Get   

} #end class $($import.ResourceName)
"@
    
    $outline 
    
} #close Convert-MofToClass
