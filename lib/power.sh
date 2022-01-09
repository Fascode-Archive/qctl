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
    #-- Prepare --#
    local _VMName="${1}" _GetVMConfigFromAll _VMDir _Qemu_Command _Qemu_Args
    declare -A _VMConfig=()
    _VMDir="$(GetConfigDir)"

    readarray -t _VmAllCofig < <(_crshini_get_format="lines" _crshini_get "${_VMDir}/${_VMName}" | sed "s|\[ VM \] ||g")

    _GetVMConfigFromAll(){
        local _Param="${1}"
        _VMConfig["${_Param}"]="$(PrintArray "${_VmAllCofig[@]}" | \
            awk "{if( \"${_Param}\" == \$1 ){ print \$0 }}" | cut -d "=" -f 2 | sed 's/^ *//; s/\s*$//')"
    }

    #-- Load configs --#
    _GetVMConfigFromAll Name
    _GetVMConfigFromAll Disks
    _GetVMConfigFromAll Memory
    _GetVMConfigFromAll KVM
    readarray -t _DiskList < <(
        while read -r _Disk; do
            IsCorrectDiskUUID "${_Disk}" || {
                MsgWarn "$_Disk is missing UUID." >&2
                continue
            }
            echo "${_Disk}"
        done < <(tr "," "\n" <<< "${_VMConfig["Disks"]}"))

    #-- Configure arguments --#

    # KVM
    [[ "${_VMConfig["KVM"]}" = true ]] && _Qemu_Args+=("-enable-kvm")

    # Disks
    PrintArray  "${_DiskList[@]}"

    
}
