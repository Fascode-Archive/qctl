# Create new virtual machine
# CreateNewVM <Name>
CreateNewVM(){
    local _Name="${1=""}" _ConfigDir

    [[ -n "${_Name}" ]] || {
       MsgError "仮想マシンの名前が指定されていません"
       return 1
    }

    _ConfigDir="$(GetConfigDir)"

    echo -e "[VM]\nName = ${_Name}" > "${_ConfigDir}/${_Name}" && {
        MsgInfo "$_Name を作成しました"
        return 0
    }

    return 1
}
