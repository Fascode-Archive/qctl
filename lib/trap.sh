ErrorExitWithLineNo(){
    echo "Unexpected error (Line: ${1})" >&2
    exit "${2}"
}

trap 'ErrorExitWithLineNo $LINENO $?' ERR
