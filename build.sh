#!/usr/bin/env bash

_CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"

EtcDir=/etc/qctl
LibDir=/usr/lib/qctl/
BinDir=/usr/bin/
DESTDIR="${1}"

mkdir -p "${DESTDIR}/$BinDir" "${DESTDIR}/${LibDir}"

while read -r file; do
    sed "$(sed -n "/%COMMON_CODE%/=" "${file}")r ${_CurrentDir}/src/qctl-common" "${file}" | \
    grep -xv "%COMMON_CODE%" | \
    sed "s|%LIB_DIR%|${DESTDIR}/${LibDir}|g" > "${DESTDIR}/${BinDir}/$(basename "${file}")"
    chmod 755 "${DESTDIR}/${BinDir}/$(basename "${file}")"
done < <(find "${_CurrentDir}/src/" -mindepth 1)

while read -r file; do
    cat "${file}" > "${DESTDIR}/${LibDir}/$(basename "${file}")"
    chmod 755 "${DESTDIR}/${LibDir}/$(basename "${file}")"
done < <(find "${_CurrentDir}/lib/" -mindepth 1)
