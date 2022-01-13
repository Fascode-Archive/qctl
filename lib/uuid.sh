#!/usr/bin/env bash

IsUUID(){
    local _UUID="${1-""}"
    [[ "${_UUID//-/}" =~ ^[[:xdigit:]]{32}$ ]] && return 0
    return 1
}

GenUUID(){
    which uuidgen >/dev/null 2>&1 || {
        MsgError "uuidgen was not found!"
        return 1
    }
    uuidgen
}
