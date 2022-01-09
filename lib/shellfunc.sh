CheckFunctionDefined(){
    typeset -f "${1}" 1> /dev/null
}

PrintArray(){
    (( $# >= 1 )) || return 0
    printf "%s\n" "${@}"
}

RemoveFile(){
    local _file _ConfigDir _VMDir
    _ConfigDir=$(GetConfigDir)
    _DiskDir=$(GetDiskDir)
    for _file in "${@}"; do
        MsgDebug "Remove $_file"
        { [[ "${_file}" = "$_ConfigDir"* ]] || [[ "${_file}" = "$_DiskDir"* ]]; } || {
            MsgError "スクリプトの管理外のファイルを削除しないでください"
            return 1
        }
        rm -rf "${_file}"
    done
}
