# AddNewDisk <Type> <Path>
AddNewDisk(){
    local _DiskDir _DiskFile="${2}" _DiskType="${1-"None"}" _UUID _Link
    _DiskDir="$(GetDiskDir)"

    [[ -e "${_DiskFile}" ]] || {
        MsgError "$_DiskFile does not exist"
        return 1
    }
    
    while true; do
        _UUID="$(genuuid)"
        _Link="${_DiskDir}/${_DiskType}/${_UUID}"

        [[ -e "${_Link}" ]] && continue
        ln -s "${_DiskFile}" "$_Link"
        break
    done
}
