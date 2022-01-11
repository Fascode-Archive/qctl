# Create new virtual machine
# CreateNewVM <Name>
CreateNewVM(){
    local _Name="${1-""}" _ConfigDir _FullPath

    [[ -n "${_Name}" ]] || {
       MsgError "仮想マシンの名前が指定されていません"
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
