GetVMList(){
    WorkInProgress
}

GetArchList(){
    WorkInProgress
}

GetVMFileList(){
    local _VMDir _FileList
    _VMDir="$(GetConfigDir)"

    readarray -t _FileList < <(
        find "${_VMDir}" -mindepth 1 -maxdepth 1 -type f 
    )

    printf "%s\n" "${_FileList[@]}"
    return 0
}
