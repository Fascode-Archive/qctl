# Create new virtual machine
# CreateNewVM <Name>
CreateNewVM(){
    local _Name="${1=""}" _ConfigDir

    [[ -n "${_Name}" ]] || {
       MsgError "仮想マシンの名前が指定されていません"
       return 1
    }

    local _FullPath="${_ConfigDir}/${_Name}"

    _ConfigDir="$(GetConfigDir)"

    if [[ -e "${_FullPath}" ]; then
        MsgError "すでに同じ名前の仮想マシンが存在しています"]
        return 1
    fi

    echo -e "[VM]\nName = ${_Name}" > "${_FullPath}" && {
        MsgInfo "$_Name を作成しました"
        return 0
    }

    return 1
}
