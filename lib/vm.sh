# GetVMConfigValue <VM> <Section> <Param>
GetVMConfigValue(){
    local _VMDir _VMName="${1}" _Section="${2}" _Param="${3}"
    _VMDir="$(GetConfigDir)"

    (( "${#}" == 3 )) || {
        MsgError "Usage: GetVMConfigValue <VM> <Section> <Param>"
        return 1
    }

    local _VMConfig="${_VMDir}/${_VMName}"

    #shellcheck disable=SC2005
    eval echo "$(_crshini_get "${_VMConfig}" "$_Section" "${_Param}")"
}

# SetVMConfigToFile <VM> <Section> <Param> <Value>
SetVMConfigToFile(){
    local _VMDir _VMName="${1}" #_Section="${2}" _Param="${3}" _Value="${4}"
    _VMDir="$(GetConfigDir)"

    (( "${#}" == 4 )) || {
        MsgError "Usage: SetVMConfigToFile <VM> <Section> <Param> <Value>"
        return 1
    }

    local _VMConfig="${_VMDir}/${_VMName}"

    shift 1

    _crshini_set "${_VMConfig}" "${@}"
}

# SetVMStatus <VM> <Param> <Value>
SetVMStatus(){
    SetVMConfigToFile "${1}" "Status" "${2}" "${3}"
}

# GetVMStatus <VM> <Param>
GetVMStatus(){
    GetVMConfigValue "${1}" "Status" "${2}"
}

