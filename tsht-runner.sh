#!/bin/bash

if [[ -z "$TSHTLIB" ]];then
    echo "\$TSHTLIB is not set, export it or use the 'tsht' wrapper script."
    exit 201
fi

usage() {
    echo "Usage: tsht [-h] [<path/to/unit.tsht>...]"
}

while [[ "$1" =~ ^- ]];do
    case "$1" in
        --)
            shift
            break
            ;;
        # --version|-V)
        #     break
        #     ;;
        --help|-h)
            usage
            exit
            ;;
    esac
done

declare -a TESTS

if [[ -z "$1" ]];then
    cd "$TSHTLIB/.."
    TESTS=($(find . -type f -name '*.tsht' -not -path '*/.tsht/*'))
else
    while [[ -n "$1" ]];do
        if [[ ! -e "$1" ]];then
            usage 
            echo "!! No such file: '$1' !!"
            exit 1
        fi
        TESTS+=("$1")
        shift
    done
fi

export TEST_PLAN=0
export TEST_IDX=0
export TEST_FAILED=0
export PATH=$(readlink "$(dirname "$0")"/..):$PATH
total_failed=0
for t in "${TESTS[@]}";do
    echo "# Testing $t"
    (
        source "$TSHTLIB/tsht-core.sh"
        cd "$(dirname $t)"
        source "$(basename $t)"
        if [[ "$TEST_PLAN" == 0 ]];then
            echo "1..$TEST_IDX"
        else
            equals "$TEST_PLAN" "$TEST_IDX" "Planned number of tests"
        fi
        if [[ "$TEST_FAILED" != 0 ]];then
            exit "$TEST_FAILED"
        fi
    )
    total_failed=$((total_failed + $?))
done
exit $total_failed
