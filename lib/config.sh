#!/usr/bin/env bash

export _crshini_debug=true

# Load Libcrshini
CrshiniList=(
    "${QctlLibDir}/../crshini/src/libcrshini"
    "${QctlLibDir}/libcrshini.sh"
    "/usr/lib/libcrshini"
)
LoadShellFIles "${CrshiniList[@]}"

# Define functions
GetConfigFile(){
    local _config=(
        "${QctlLibDir}/../qctl.conf"
        "${XDG_CONFIG_HOME:-"${HOME}/.config"}/qctl.conf"
        "/etc/qctl.conf"
    )
    local _file
    for _file in "${_config[@]}"; do
        [[ -e "${_file}" ]] && {
            MsgDebug "Use ${_file} as config file" >&2
            echo "${_file}"
            return 0
        }
    done
    MsgError "Config file was not found."
    return 1
}
ConfigFile="$(GetConfigFile)"

# GetConfigValue <Section> <Param>
GetConfigValue(){
    _crshini_get "${ConfigFile}" "${@}"
}

# SetConfigToFile <Section> <Param> <Value>
SetConfigToFile(){
    _crshini_set "${ConfigFile}"
}


