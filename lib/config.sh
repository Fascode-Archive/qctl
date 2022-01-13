#!/usr/bin/env bash

[[ "${ShowDebugMsg}" = false ]] || export _crshini_debug=true

# Load Libcrshini
CrshiniList=(
    "${QctlLibDir}/../crshini/src/libcrshini"
    "${QctlLibDir}/libcrshini.sh"
    "/usr/lib/libcrshini"
)
LoadShellFIles "${CrshiniList[@]}"

# Define functions
GetMainConfigFilePath(){
    local _config=(
        "${MainConfig-"/etc/qctl.conf"}"
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
ConfigFile="$(GetMainConfigFilePath)"

# GetMainConfigValue <Section> <Param>
GetMainConfigValue(){
    #shellcheck disable=SC2005
    eval echo "$(_crshini_get "${ConfigFile}" "${@}" | sed 's/^[[:blank:]]*//')"
}

# SetMainConfigToFile <Section> <Param> <Value>
SetMainConfigToFile(){
    _crshini_set "${ConfigFile}"
}


