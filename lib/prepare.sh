PrepareConfigDir(){
    local _ConfigDir
    _ConfigDir="$(GetConfigValue "Main" "ConfigDir")"

    [[ -n "${_ConfigDir}" ]] || {
        MsgError "Failed to get vm directory path."
        return 1
    }

    [[ -e "${_ConfigDir}" ]] || {
        MsgWarn "${_ConfigDir} was not found. Creating ..."
        mkdir -p "${_ConfigDir}"
    }
}

GetConfigDir(){
    local _ConfigDir
    _ConfigDir="$(GetConfigValue "Main" "ConfigDir")"
    PrepareConfigDir
    echo "${_ConfigDir}"
}

CheckBashVersion(){
    MsgDebug "Your bash is ${BASH_VERSION}"
}
