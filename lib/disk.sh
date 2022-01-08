# AddNewDisk <Type> <Path>
AddNewDisk(){
    local _DiskDir _DiskFile="${1}" _DiskType="${2-"None"}" _UUID _Link
    _DiskDir="$(GetDiskDir)"

    [[ -e "${_DiskFile}" ]] || {
        MsgError "$_DiskFile does not exist"
        return 1
    }


    GetDiskPathList | grep -qx "$_DiskFile" && {
        MsgError "This file has already been added."
        MsgError "UUID is $(GetDiskUUIDFromPath "${_DiskFile}")"
        exit 1
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

# GetPathFromDiskUUID <UUID>
GetPathFromDiskUUID(){
    local _DiskDir _UUID="${1-""}"
    _DiskDir="$(GetDiskDir)"

    [[ -z "${_UUID}" ]] && {
        MsgError "Usage: GetPathFromDiskUUID <UUID>"
        return 1
    }

    readarray -t _UUID_FullPath_List < <(find "${_DiskDir}" -mindepth 2 -maxdepth 2 -type l)
    readarray -t _UUID_List < <(PrintArray "${_UUID_FullPath_List[@]}" | xargs -I{} basename {})

    PrintArray "${_UUID_List[@]}" | grep -qx "${_UUID}" || {
        MsgError "No disk with such a UUID was found."
        return 1
    }

    #readlinkf "$(find "${_DiskDir}" -name "${_UUID}" -mindepth 2 -maxdepth 2 -type l)"
    readlinkf "$(PrintArray "${_UUID_FullPath_List[@]}" | grep -E "/${_UUID}$")"
}

GetDiskUUIDList(){
    GetDiskUUIDPathList | xargs -0 -I{} basename {}
}

GetDiskUUIDPathList(){
    find "$(GetDiskDir)" -mindepth 2 -maxdepth 2 -type l -print0
}

GetDiskPathList(){
    readarray -t _UUID_List < <(GetDiskUUIDList)
    local _uuid
    for _uuid in "${_UUID_List[@]}"; do
        GetPathFromDiskUUID "${_uuid}"
    done
}

GetDiskUUIDFromPath(){
    #readlinkf "$(find "$(GetDiskDir)" -name "${1}" -mindepth 2 -maxdepth 2 -type l -print0 )"
    GetDiskUUIDPathFromPath "${1}" | xargs -I{} basename {}
}

# Return UUID-simlimk path
# GetDiskUUIDPathFromPath <Image Path>
GetDiskUUIDPathFromPath(){
    local _DiskDir _TargetPath="${1-""}" _UUID _Path
    _DiskDir="$(GetDiskDir)"
    while read -r _UUID_FullPath; do
        _UUID="$(basename "${_UUID_FullPath}")"
        _Path="$(readlinkf "${_UUID}")"
        if [[ "${_Path}" = "${_TargetPath}" ]]; then
            echo "${_Path}"
            return 0
        fi
    done < <(find "${_DiskDir}" -mindepth 2 -maxdepth 2 -type l)
}
