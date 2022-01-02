#!/usr/bin/env bash

eval "$(sed "s|%LIB_DIR%|$(cd "$(dirname "${0}")"; pwd)/lib|g" "${1}")"
