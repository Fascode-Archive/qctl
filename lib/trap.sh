ErrorExitWithLineNo(){
    echo "Unexpected error (Line: ${1})"
}

trap 'ErrorExitWithLineNo $LINENO' ERR
