# AddNewDisk <Type> <Path>
AddNewDisk(){
    local _DiskDir _DiskFile="${1}" _DiskType="${2-"None"}" _UUID _Link
    _DiskDir="$(GetDiskDir)"

    [[ -e "${_DiskFile}" ]] || {
        MsgError "$_DiskFile does not exist"
        return 1
    }

    
    while true; do
        _UUID="$(uuidgen)"
        _Link="${_DiskDir}/${_DiskType}/${_UUID}"

        MakeNewDir "$(dirname "$_Link")"

        [[ -e "${_Link}" ]] && continue
        ln -s "${_DiskFile}" "$_Link"
        break
    done
}
