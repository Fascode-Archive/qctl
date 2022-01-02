#!/usr/bin/env bash

eval "$(sed "s|%LIB_DIR%|$(cd "$(dirname "${0}")" || exit 1 ; pwd)/lib|g" "${1}")"
