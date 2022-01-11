GetVMList(){
    GetVMFileList | GetVMUUIDFromStdinPath
}

GetArchList(){
    readarray -t _BinDir < <(
        while read -r _file; do
            eval "echo ${_file}"
        done < <(tr ":" "\n" <<< "${PATH}")
    )
    find "${_BinDir[@]}" -name "qemu-system-*" -mindepth 1 -maxdepth 1 -print0 2> /dev/null | xargs -0 -I{} basename {} | sed "s|qemu-system-||g" | sort | uniq
}

GetVMFileList(){
    local _VMDir _FileList
    _VMDir="$(GetConfigDir)"

    readarray -t _FileList < <(
        while read -r _Vm; do
            ! IsUUID "$(GetVMUUIDFromPath "${_Vm}")" || echo "${_Vm}"
        done < <(find "${_VMDir}" -mindepth 1 -maxdepth 1 -type f)
    )

    PrintArray "${_FileList[@]}"
    return 0
}
