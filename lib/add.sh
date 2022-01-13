#!/usr/bin/env bash
# Create new virtual machine
# CreateNewVM <Name>
CreateNewVM(){
    local _Name="${1-""}" _ConfigDir _FullPath

    [[ -n "${_Name}" ]] || {
       MsgError "仮想マシンの名前が指定されていません"
       return 1
    }

    (( "$(GetSameNameVMTimesFromName "${_Name}" 2> /dev/null)" > 1 )) && {
        MsgError "同じ名前のファイルが既に存在しています。以下の仮想マシンは同じ名前を持っています。"
        GetVMUUIDFromName "${_Name}" 2> /dev/null | xargs -L 1 echo "- " >&2
        return 1
    } 

    _ConfigDir="$(GetConfigDir)"
    _FullPath="${_ConfigDir}/$(GenUUID).conf"

    #echo -e "[VM]\nName = ${_Name}" > "${_FullPath}" 
    sed "s|%VM_NAME%|${_Name}|g" "${DataDir}/Template.conf" > "${_FullPath}" && {
        MsgInfo "$_Name を作成しました"
        return 0
    }

    return 1
}
