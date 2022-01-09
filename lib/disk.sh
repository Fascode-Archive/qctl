# ディスクタイプ一覧
# - CD
# -


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
    GetDiskUUIDPathList | xargs -I{} basename {}
}

GetDiskUUIDPathList(){
    find "$(GetDiskDir)" -mindepth 2 -maxdepth 2 -type l
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
# ディスクのパスからUUIDのシンボリックリンクのフルパスを返す
# GetDiskUUIDPathFromPath <Image Path>
GetDiskUUIDPathFromPath(){
    local _DiskDir _TargetPath="${1-""}" _UUID _Path
    _DiskDir="$(GetDiskDir)"
    while read -r _UUID_FullPath; do
        _UUID="$(basename "${_UUID_FullPath}")"
        _Path="$(readlinkf "${_UUID}")"
        if [[ "$(basename "${_Path}")" = "${_UUID}" ]]; then
            echo "${_UUID_FullPath}"
            return 0
        fi
    done < <(find "${_DiskDir}" -mindepth 2 -maxdepth 2 -type l)
    return 1
}

GetDiskUUIDPathFromUUID(){
    local _DiskDir
    _DiskDir="$(GetDiskDir)"
    find "${_DiskDir}" -mindepth 2 -maxdepth 2 -type l -name "${1}"
}

# Remove
RemoveDisk(){
    local _Target="${1-""}"

    [[ -n "${_Target}" ]] || {
        MsgError "Usage: RemoveDisk <UUID or Path>"
    }

    if IsUUID "${_Target}"; then
        MsgDebug "$_Target is UUID"
        _Target="$(GetDiskUUIDPathFromUUID "${_Target}")"
    else
        MsgDebug "$_Target is path."
        if ! IsUUID "$(basename "${_Target}")"; then
            MsgDebug "Get UUID path from disk path"
            _Target="$(GetDiskUUIDPathFromPath "${_Target}")"
        fi
    fi

    #_Target="$(GetDiskUUIDPathFromUUID "${_Target}")"
    MsgDebug "Remove ${_Target}"
    [[ -h "$_Target" ]] && {
        RemoveFile "${_Target}"
        MsgInfo "$_Target was successfully removed"
        return 0
    }
    return 0
}


GetDiskTypeFromUUID(){
    local _UUID="${1}" _UUID_FullPath
    _UUID_FullPath="$(GetDiskUUIDPathFromUUID "${_UUID}")"
    basename "$(dirname "${_UUID_FullPath}")"
}

IsCorrectDiskUUID(){
    local _UUID="${1}"
    
    # シンボリックリンクが存在することの確認
    GetDiskUUIDList | grep -qx "${_UUID}" || return 1

    # シンボリックリンクの先が存在することの確認
    [[ -e "$(GetPathFromDiskUUID "${_UUID}")" ]] || return 1

    return 0
}
