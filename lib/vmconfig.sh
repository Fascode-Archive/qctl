# GetVMConfigValue <VM UUID> <Section> <Param>
GetVMConfigValue(){
    local _VMFile _VMUUID="${1}" _Section="${2}" _Param="${3}"

    (( "$#" == 3 )) || {
        MsgError "Usage: GetVMConfigValue <VM> <Section> <Param>"
        return 1
    }

    _VMFile="$(GetVMFilePathFromUUID "${_VMUUID}")"

    #shellcheck disable=SC2005
    eval echo "$(_crshini_get "${_VMFile}" "$_Section" "${_Param}")"
}

# SetVMConfigToFile <VM> <Section> <Param> <Value>
SetVMConfigToFile(){
    local _VMFile _VMUUID="${1-""}" _Section="${2-""}" _Param="${3-""}" _Value="${4-""}"
    _VMDir="$(GetConfigDir)"

    (( "$#" == 4 )) || {
        MsgError "Usage: SetVMConfigToFile <VM> <Section> <Param> <Value>"
        return 1
    }

    _VMFile="$(GetVMFilePathFromUUID "${_VMUUID}")"

    shift 1

    _crshini_set "${_VMFile}" "${@}"
}

# SetVMStatus <VM> <Param> <Value>
SetVMStatus(){
    SetVMConfigToFile "${1}" "Status" "${2}" "${3}"
}

# GetVMStatus <VM> <Param>
GetVMStatus(){
    GetVMConfigValue "${1}" "Status" "${2}"
}

