PrepareConfigDir(){
    local _ConfigDir
    _ConfigDir="$(GetMainConfigValue "Main" "ConfigDir" | sed 's/^[[:blank:]]*//')"

    [[ -n "${_ConfigDir}" ]] || {
        MsgError "Failed to get vm directory path."
        return 1
    }

    [[ -e "${_ConfigDir}" ]] || {
        MsgWarn "${_ConfigDir} was not found. Creating ..."
        mkdir -p "${_ConfigDir}"
    }

    echo "${_ConfigDir}"
}

GetConfigDir(){
    PrepareConfigDir
}

CheckBashVersion(){
    MsgDebug "Your bash is ${BASH_VERSION}"
}
