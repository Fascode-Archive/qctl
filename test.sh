#!/usr/bin/env bash
set -eu

_CurrentDir="$(cd "$(dirname "${0}")" || exit 1 ; pwd)"
_TargetScript="${1-""}"

[[ -n "${_TargetScript}" ]] || {
    echo "Usage: test.sh <script> <script args> ..." >&2
    exit 1
}

shift 1

eval "$("${_CurrentDir}/build.sh" -b "/" -l "${_CurrentDir}/lib" -s "${_TargetScript}")"
