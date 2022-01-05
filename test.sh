#!/usr/bin/env bash
_CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
_TargetScript="${1}"
shift 1

eval "$(
    sed "$(sed -n "/%COMMON_CODE%/=" "${_TargetScript}")r ${_CurrentDir}/src/qctl-common" "${_TargetScript}" | \
    sed "s|%LIB_DIR%|${_CurrentDir}/lib|g" | \
    grep -xv "%COMMON_CODE%"
    )"
