#!/usr/bin/env bash
set -eu

_CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
_TargetScript="${1-""}"

[[ -n "${_TargetScript}" ]] || {
    echo "Usage: test.sh <script> <script args> ..." >&2
    exit 1
}

_Remove_Line=(
    "#!/usr/bin/env bash"
    "%COMMON_CODE%"
)

shift 1

_CommonCodeLine="$(sed -n "/%COMMON_CODE%/=" "${_TargetScript}")"
readarray -t _Grep_Args < <(
    for _Str in "${_Remove_Line[@]}"; do
        printf -- "-e\n"
        echo "${_Str}"
    done
)

eval "$(
    if [[ -n "${_CommonCodeLine}" ]]; then
        sed "${_CommonCodeLine}r ${_CurrentDir}/src/qctl-common" "${_TargetScript}"
    else
        cat "${_TargetScript}"
    fi | sed "s|%LIB_DIR%|${_CurrentDir}/lib|g" | \
    grep -Fxv "${_Grep_Args[@]}"
    )"
