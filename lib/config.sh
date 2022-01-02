#!/usr/bin/env bash

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
        "${ScriptDir}/../qctl.conf"
        "${XDG_CONFIG_HOME:-"${HOME}/.config"}/qctl.conf"
        "/etc/qctl.conf"
    )
    local _file
    for _file in "${_config[@]}"; do
        [[ -e "${_file}" ]] && {
            echo "${_file}"
            return 0
        }
    done
}
ConfigFile="$(GetConfigFile)"

GetConfigValue(){
    :
}
