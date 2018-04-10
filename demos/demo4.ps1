#create a class-based resource from xDSCResourceDesigner

Return "Not a script, silly. Walk through demo."

$props = @()
$props+= New-xDscResourceProperty -Name Name -Attribute Key -Type String
$props+= New-xDscResourceProperty -Name Enabled -Attribute Required -Type Boolean
$props+= New-xDscResourceProperty -Name Setting -Attribute write -ValueMap "Apple","Banana","Cherry" -Values "Apple","Banana","Cherry" -type String
$props+= New-xDscResourceProperty -Name Bar -Type "String[]" -Attribute write
$props+= New-xDscResourceProperty -Name Size -Type String -Attribute Read

$props

$map = @{
    Key = "Key"
    Required = "Mandatory"
    Write= $Null
    Read = "NotConfigurable"
}


$items = foreach ($item in $props) {
    $classprop = @"
`n[DscProperty($($map.($item.Attribute)))]

"@

    if ($item.ValueMap) {
        $joined = $item.ValueMap -join "','"
        $classprop+= "[ValidateSet('$joined')]`n"
    }
$classprop+="[$($item.type)]`$$($item.Name)`n"

$classprop
}

$items

#define a template for the class
$template = @"

[DSCResource()]
Class myThingy {
$items

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
[MyThingy] Get()  {        

    # Return this instance or construct a new instance.
    return `$this 

} #Get   

} #end class myThingy

"@

$template | Set-Clipboard

#You could also create a Plaster template
cls
#create the MyResource DSC resource module
Invoke-Plaster -TemplatePath .\DSCClassResourceTemplate -DestinationPath $env:temp\MyResource

code $env:temp\MyResource
