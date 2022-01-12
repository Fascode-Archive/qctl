#!/usr/bin/env bash

set -eu

CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"

QctlLibDir="${CurrentDir}/lib"
DataDir="$CurrentDir/data"

LoadShells=("${QctlLibDir}/main.sh")

# Load main library
for file in "${LoadShells[@]}"; do
    [[ -e "${file}" ]] && source "${file}"
done

: "${BaseDir="/"}"
: "${EtcDir="/etc"}"
: "${LibDir="/lib"}"
: "${BinDir="/bin"}"


HelpDoc(){
    echo "usage build.sh [option]"
    echo
    echo "Build qctl and install to the dir"
    echo
    echo " Install options:"
    echo "    -s | --script [path]     Build the specified script"
    echo "                             Script will be outputed to stdin"
    echo "    -i | --install           Build all scripts and install"
    echo "                             Outout directory can be specified"
    echo
    echo " Instal options:"
    echo "    -b | --basedir [dir]     The path of root. etc, bin and lib files will be installed here"
    echo "                             Default: ${BaseDir-""}"
    echo "    -e | --etcdir [dir]      The path of config directory under the base dir"
    echo "                             Default: ${EtcDir-""}"
    echo "    -l | --libdir [dir]      The path of library directory under the base dir"
    echo "                             Default: ${LibDir-""}"
    echo "    -c | --bindir [dir]      The path of commands directory under the base dir"
    echo "                             Default: ${BinDir-""}"
    echo
    echo " General options:"
    echo "    -h          This help message"
}

Main(){
    :
}

# Parse options
OPTS=("s:" "i" "b:" "e:" "l:" "c:" "h") OPTL=("script:" "install" "basedir:" "etcdir:" "libdir:" "bindir:" "help")
ParseCmdOpt SHORT="$(printf "%s" "${OPTS[@]}")" LONG="$(printf "%s," "${OPTL[@]}")" -- "${@}" || exit 1
eval set -- "${OPTRET[@]}"
unset OPTRET OPTS OPTL

while true; do
    case "${1}" in
        -h | --help)
            HelpDoc
            exit 0
            ;;
        --)
            shift 1
            break
            ;;
        *)
            MsgError "Argument exception error '${1}'"
            MsgError "Please report this error to the developer." 1
            ;;
    esac
done

Main "${@}"
