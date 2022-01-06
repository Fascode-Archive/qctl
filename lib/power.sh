# StartVM <VM>
StartVM(){
    local _VMName="${1=""}"

    test -n "$_VMName" || {
        MsgError "Usage: StartVM <VM>"
        return 1
    }

    local _VMType
    _VMType=$(GetVMConfigValue "$_VMName" "VM" "Type")

    if CheckFunctionDefined "StartVMWith${_VMType}"; then
        eval "StartVMWith$_VMType" "${_VMName}"
    else
        MsgError "Failed to start ${_VMName}.\n${_VMType} does not supported yet."
        return 1
    fi
}

# Start
StartVMWithQemu(){
    local _VMName="${1}" _LoadVMConfig _VMDir
    _VMDir="$(GetConfigDir)"

    readarray -t _VmAllCofig < <(_crshini_get_format="lines" _crshini_get "${_VMDir}/${_VMName}" | sed "s|\[ VM \] ||g")

    _GetVMConfigFromAll(){
        local _Param="${1}"
        PrintArray "${_VmAllCofig[@]}" | \
            awk "{if( \"${_Param}\" == \$1 ){ print \$0 }}" | cut -d "=" -f 2 | sed 's/^ *//; s/\s*$//'
    }

    _GetVMConfigFromAll Name
    
    
}
