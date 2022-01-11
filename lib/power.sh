# StartVM <VM>
StartVM(){
    local _VMUUID="${1=""}"

    { test -n "$_VMUUID" || IsUUID "${_VMUUID}"; }|| {
        MsgError "Usage: StartVM <VMUUID>"
        return 1
    }

    local _VMType
    _VMType=$(GetVMConfigValue "$_VMUUID" "VM" "Type")

    if CheckFunctionDefined "StartVMWith${_VMType}"; then
        eval "StartVMWith$_VMType" "${_VMUUID}"
    else
        MsgError "Failed to start ${_VMUUID}.\n${_VMType} does not supported yet."
        return 1
    fi
}

# Start
StartVMWithQemu(){
    #-- Prepare --#
    local _VMUUID="${1}" _GetVMConfigFromAll _VMDir _Qemu_Command _Qemu_Args _VMFile
    declare -A _VMConfig=()
    _VMDir="$(GetConfigDir)"
    _VMFile="$(GetVMFilePathFromUUID "${_VMUUID}")"

    readarray -t _VmAllCofig < <(_crshini_get_format="lines" _crshini_get "${_VMFile}" | sed "s|\[ VM \] ||g")

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
    _GetVMConfigFromAll SoundHardware
    _GetVMConfigFromAll USB
    while read -r _Disk; do
        IsCorrectDiskUUID "${_Disk}" || {
            MsgWarn "$_Disk is missing UUID." >&2
            continue
        }
        case "$(GetDiskTypeFromUUID "${_Disk}")" in
            "CD")
                _CdUUIDList+=("${_Disk}")
                _CdPathList+=("$(GetPathFromDiskUUID "${_Disk}")")
                ;;
            "None")
                MsgError "The type of $_Disk is \"None\", which is not supported currently."
                ;;
        esac
    done < <(tr "," "\n" <<< "${_VMConfig["Disks"]}")
    _AllTypeDiskPathList=("${_CdPathList[@]}")

    #-- Configure arguments --#

    # Name
    _Qemu_Args+=("-name" "${_VMConfig["Name"]}")

    # Disk
    for _Disk in "${_AllTypeDiskPathList[@]}"; do
        _Qemu_Args+=("-drive" "file=${_Disk},if=ide,media=disk,")
    done

    # KVM
    [[ "${_VMConfig["KVM"]}" = true ]] && _Qemu_Args+=("-enable-kvm")

    # Disks
    (( "${#_AllTypeDiskPathList[@]}" >= 1 )) || MsgWarn "ディスクが1つも指定されていません"
    #PrintArray  "${_DiskList[@]}"

    # RAM
    _Qemu_Args+=("-m" "${_VMConfig["Memory"]}")

    # Sound
    _Qemu_Args+=("-soundhw" "${_VMConfig["SoundHardware"]}")

    # USB
    [[ "${_VMConfig["USB"]}" = true ]] && _Qemu_Args+=("-usb")

    # Display
    #_Qemu_Args+=("-display sdl,grab-on-hover=on")

    #-- Start Qemu --#
    qemu-system-x86_64 "${_Qemu_Args[@]}"
}
