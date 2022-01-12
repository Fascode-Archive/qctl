#!/usr/bin/env bash

set -eu

CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"

SrcLibDir="${CurrentDir}/lib"
SrcDataDir="$CurrentDir/data"

QctlLibDir="$SrcLibDir"
LoadShells=("${SrcLibDir}/main.sh")

Remove_Line=(
    "#!/usr/bin/env bash"
    "%COMMON_CODE%"
)

ExcludeBase=false

# Load main library
for file in "${LoadShells[@]}"; do
    [[ -e "${file}" ]] && source "${file}"
done

: "${BaseDir="/"}"
: "${EtcDir="/etc/qctl"}"
: "${LibDir="/lib/qctl"}"
: "${BinDir="/bin"}"
: "${DataDir="/usr/share/qctl"}"

BuildMode=""
TargetPath=""

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
    echo " Install options:"
    echo "    -b | --basedir [dir]     The path of root. etc, bin and lib files will be installed here"
    echo "                             Default: ${BaseDir-""}"
    echo "    -e | --etcdir [dir]      The path of config directory under the base dir"
    echo "                             Default: ${EtcDir-""}"
    echo "    -l | --libdir [dir]      The path of library directory under the base dir"
    echo "                             Default: ${LibDir-""}"
    echo "    -c | --bindir [dir]      The path of commands directory under the base dir"
    echo "                             Default: ${BinDir-""}"
    echo "    -d | --datadir [dir]     The path of misc data directory under the base dir"
    echo "                             Default: ${DataDir-""}"
    echo "         --excludebase       Specify the path including basedir in the script"
    echo "                             Please read following message for detail"
    echo
    echo " About \"--excludebase\""
    echo "By default, installed scripts use the path containing basedir. "
    echo "This is useful if you are installing directly on your system."
    echo "Specify this option if you do not want the directory name to include basedir for reasons such as packaging."
    echo 
    echo "For example, if you use this option, the library itself will be installed in <basedir>/<libdir>, "
    echo "but the actual command will try to load <libdir>."
    echo
    echo " General options:"
    echo "    -h          This help message"
}

BuildScript(){
    # 削除する行の一覧
    readarray -t _Grep_Args < <(
        for _Str in "${Remove_Line[@]}"; do
            printf -- "-e\n"
            echo "${_Str}"
        done
    )

    # CommonCodeの挿入箇所
    local _CommonCodeLine
    _CommonCodeLine="$(sed -n "/%COMMON_CODE%/=" "${1}")"

    grep -Fxv "${_Grep_Args[@]}" "${1}" | \
    if [[ -n "${_CommonCodeLine}" ]]; then
        sed "${_CommonCodeLine}r ${CurrentDir}/src/qctl-common"
    else
        cat "${1}"
    fi | \
    sed '/^$/d' | \
    if [[ "${ExcludeBase}" = true ]]; then
        sed "s|%LIB_DIR%|${LibDir}|g" | \
        sed "s|%DATA_DIR%|${DataDir}|g"
    else
        sed "s|%LIB_DIR%|${LibFullPath}|g" | \
        sed "s|%DATA_DIR%|${DataFullPath}|g"
    fi
}

RunInstall(){
    local _Dir
    for _Dir in Etc Bin Data Lib; do
        eval "mkdir -p \"\${${_Dir}FullPath}\""
        eval "${_Dir}FullPath=\"\$(readlinkf \"\${${_Dir}FullPath}\")\""
    done
    

    EtcFullPath=$(readlinkf "${EtcFullPath}")

    # Install /src/ to /bin
    local _File
    while read -r _File; do
        BuildScript "${_File}" > "${BinFullPath}/$(basename "${_File}")"
        chmod 755 "${BinFullPath}/$(basename "${_File}")"
    done < <(find "${CurrentDir}/src/" -mindepth 1)

    # Install /lib to /lib
    while read -r _File; do
        cat "${_File}" > "${LibFullPath}/$(basename "${_File}")"
        chmod 755 "${LibFullPath}/$(basename "${_File}")"
    done < <(find "${CurrentDir}/lib/" -mindepth 1)

    # Install qctl.conf to /etc
    cat "$CurrentDir/qctl.conf" > "${EtcFullPath}/qctl.conf"

    # Install /data to /usr/share
    while read -r _File; do
        cp "${_File}" "${DataFullPath}"
    done < <(find "${CurrentDir}/data" -mindepth 1)
}

Main(){
    case "${BuildMode}" in
        "Script")
            BuildScript "${TargetPath}"
            ;;
        "Install")
            RunInstall
            ;;
        "")
            MsgError "There is nothing to do."
            exit 0
            ;;
    esac
}

# Parse options
OPTS=("s:" "i" "b:" "e:" "l:" "c:" "h") OPTL=("script:" "install" "basedir:" "etcdir:" "libdir:" "bindir:" "help" "excludebase") 
ParseCmdOpt SHORT="$(printf "%s" "${OPTS[@]}")" LONG="$(printf "%s," "${OPTL[@]}")" -- "${@}" || exit 1
eval set -- "${OPTRET[@]}"
unset OPTRET OPTS OPTL

while true; do
    case "${1}" in
        -s | --script)
            BuildMode="Script"
            TargetPath="${2}"
            shift 2
            ;;
        -i | --install)
            BuildMode="Install"
            shift 1
            ;;
        -b | --basedir)
            BaseDir="${2}"
            shift 2
            ;;
        -e | --etcdir)
            EtcDir="${2}"
            shift 2
            ;;
        -l | --libdir)
            LibDir="${2}"
            shift 2
            ;;
        -c | --bindir)
            BinDir="$2"
            shift 2
            ;;
        -d | --datadir)
            DataDir="$2"
            shift 2
            ;;
        -h | --help)
            HelpDoc
            exit 0
            ;;
        --excludebase)
            ExcludeBase=true
            shift 1
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

#EtcFullPath="$(readlinkf "$BaseDir/$EtcDir")"
#LibFullPath="$(readlinkf "$BaseDir/$LibDir")"
#BinFullPath="$(readlinkf "$BaseDir/$BinDir")"
#DataFullPath="$(readlinkf "$BaseDir/$DataDir")"

EtcFullPath="$BaseDir/$EtcDir"
LibFullPath="$BaseDir/$LibDir"
BinFullPath="$BaseDir/$BinDir"
DataFullPath="$BaseDir/$DataDir"

Main "${@}"
