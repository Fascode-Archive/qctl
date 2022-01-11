GetVMUUIDFromName(){
    local _TargetName="${1-""}" _File _Output=() _Name _UUID

    [[ -n "${_TargetName}" ]] || {
       MsgError "UUIDが指定されていません"
       return 1
    }

    while read -r _File; do
        _UUID="$(basename "${_FIle}")"
        _Name="$(GetVMConfigValue "${_UUID}" "VM" "Name")"
        if [[ "${_Name}" = "${_TargetName}" ]]; then
            _Output+=("${_UUID}")
        fi
    done < <(GetVMFileList)

    (( "${#_Output[@]}" > 1 )) && {
        MsgWarn "同じ名前の仮想マシンが複数見つかりました"
    }

    (( "${#_Output[@]}" <= 0 )) && {
        MsgError "そのような名前の仮想マシンは見つかりませんでした"
        return 1
    }

    PrintArray "${_Output[@]}"
}


GetVMFilePathFromUUID(){
    local _VMDir _UUID="${1}"
    _VMDir="$(GetConfigDir)"
    echo "${_VMDir}/$_UUID.conf"
}

GetVMUUIDFromStdinPath(){
    local _Vm
    while read -r _Vm; do
        GetVMUUIDFromPath "${_Vm}"
    done
}

GetVMUUIDFromPath(){
    basename "${_Vm}" | sed "s|.conf$||g"    
}
