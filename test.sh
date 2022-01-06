#!/usr/bin/env bash
_CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
_TargetScript="${1}"
shift 1

_CommonCodeLine="$(sed -n "/%COMMON_CODE%/=" "${_TargetScript}")"

eval "$(
    if [[ -n "${_CommonCodeLine}" ]]; then
        sed "${_CommonCodeLine}r ${_CurrentDir}/src/qctl-common" "${_TargetScript}"
    else
        cat "${_TargetScript}"
    fi | sed "s|%LIB_DIR%|${_CurrentDir}/lib|g" | \
    grep -xv "%COMMON_CODE%"
    )"
