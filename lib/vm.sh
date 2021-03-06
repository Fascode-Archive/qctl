#!/usr/bin/env bash

GetVMUUIDFromName(){
    local _TargetName="${1-""}" _File _Output=() _Name _UUID

    [[ -n "${_TargetName}" ]] || {
        MsgError "UUIDが指定されていません"
        return 1
    }

    while read -r _File; do
        _UUID="$(GetVMUUIDFromPath "${_File}")"
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

# 同じ名前の仮想マシンの数を返します
GetSameNameVMTimesFromName(){
    GetVMUUIDFromName "${1}" | wc -l
}

GetVMFilePathFromUUID(){
    local _VMDir _UUID="${1-""}"

    IsUUID "${_UUID}" || {
        MsgError "$_UUID is not UUID"
        return 1
    }

    _VMDir="$(GetConfigDir)"
    echo "${_VMDir}/$_UUID.conf"
}

GetVMFilePathFromStdinUUID(){
    local _UUID
    while read -r _UUID; do
        GetVMFilePathFromUUID "${_UUID}"
    done
}

GetVMUUIDFromStdinPath(){
    local _Vm
    while read -r _Vm; do
        GetVMUUIDFromPath "${_Vm}"
    done
}

GetVMUUIDFromPath(){
    basename "${1}" | sed "s|.conf$||g"    
}
