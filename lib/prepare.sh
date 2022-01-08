# MakeNewDir <dir> <dir> ...
MakeNewDir(){
    local _Dir

    (( "${#}" < 1 )) && {
        MsgError "Usage: MakeNewDir <dir1> <dir2> ..."
        return 1
    }

    for _Dir in "${@}" ; do
        { [[ ! -d "${_Dir}" ]] && [[ ! -e "${_Dir}" ]]; } && {
            MsgWarn "${_ConfigDir} was not found. Creating ..."
            mkdir -p "${_Dir}"
        }
    done
}

PrepareConfigDir(){
    local _ConfigDir
    _ConfigDir="$(GetMainConfigValue "Main" "ConfigDir" | sed 's/^[[:blank:]]*//')"

    [[ -n "${_ConfigDir}" ]] || {
        MsgError "Failed to get vm directory path."
        return 1
    }

    MakeNewDir "${_ConfigDir}"

    echo "${_ConfigDir}"
}

GetConfigDir(){
    PrepareConfigDir
}

CheckBashVersion(){
    MsgDebug "Your bash is ${BASH_VERSION}"
}

PrepareDiskDir(){
    local _DiskDir
    _DiskDir="$(GetMainConfigValue "Main" "DiskDir" | sed 's/^[[:blank:]]*//')"

    [[ -n "${_DiskDir}" ]] || {
        MsgError "Failed to get disk directory path."
        return 1
    }

    MakeNewDir "${_DiskDir}"

    echo "${_DiskDir}"
}

GetDiskDir(){
    PrepareDiskDir
}
