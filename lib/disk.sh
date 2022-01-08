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

# GetPathFromUUID <UUID>
GetPathFromUUID(){
    local _DiskDir _UUID="${1-""}"
    _DiskDir="$(GetDiskDir)"

    [[ -z "${_UUID}" ]] && {
        MsgError "Usage: GetPathFromUUID <UUID>"
        return 1
    }

    readarray -t _UUID_FullPath_List < <(find "${_DiskDir}" -mindepth 2 -maxdepth 2 -type l)
    readarray -t _UUID_List < <(PrintArray "${_UUID_FullPath_List[@]}" | xargs -I{} basename {})

    PrintArray "${_UUID_List[@]}" | grep -qx "${_UUID}" || {
        MsgError "No disk with such a UUID was found."
        return 1
    }

    readlinkf "$(find "${_DiskDir}" -name "${_UUID}" -mindepth 2 -maxdepth 2 -type l)"
}
