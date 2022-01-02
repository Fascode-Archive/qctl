MsgCommon(){
    for i in $(seq "$(echo -e "${*}" | wc -l)"); do
        echo -e "${*}" | head -n "${i}" | tail -n 1
    done
}

MsgError(){
    MsgCommon "Error: ${*}" >&2
}

MsgInfo(){
    MsgCommon " Info: ${*}" >&1
}

MsgWarn(){
    MsgCommon " Warn: ${*}" >&2
}

MsgDebug(){
    MsgCommon "Debug: ${*}" >&2
}


