#requires -version 5.0

<%
if ($PLASTER_PARAM_Ensure -eq 'True') {
@"
Enum Ensure {
    Absent
    Present
}

"@
}
%>

[DSCResource()]
Class <%=$PLASTER_PARAM_ResourceName%> {

#define your keys
[DSCProperty(Key)]
[<%=$PLASTER_PARAM_KeyType%>]$<%=$PLASTER_PARAM_Key%>

<%
if ($PLASTER_PARAM_Ensure -eq 'True') {
@"
[DSCProperty(Mandatory)]
[Ensure]`$Ensure

"@
}
%>



[void]Set() {

    #Include this line if the resource requires a system reboot.
    #$global:DSCMachineStatus = 1


}

[boolean]Test() {

    $result = #insert your code
    Return $result

}

[<%=$PLASTER_PARAM_ResourceName%>]Get() {

    #add code to update properties with current values
    $this.<%=$PLASTER_PARAM_Key%> = #insert your code

    return $this
}

}