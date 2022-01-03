#!/usr/bin/env bash
_CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
eval "$(
    sed "$(sed -n "/%COMMON_CODE%/=" "${1}")r ${_CurrentDir}/src/qctl-common" "${1}" | \
    sed "s|%LIB_DIR%|${_CurrentDir}/lib|g"
    )"
