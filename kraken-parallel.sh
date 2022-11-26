#!/usr/bin/env bash

source kraken-parallel-tentacles.sh

version="v1.0.0"
log_path="/tmp"
new_log=false
no_log=false
verbose=false
max_parallel=20
null_lines=false

#Option.
[[ "${#}" -eq "0" ]] && error_1
indf=0
while [[ "${#}" -ne "0" ]]; do
    if [[ -z "${1}" ]]; then
        shift
    fi
    case "${1}" in
        --version) 
            version
        ;;
        -h|--help) 
            usage
        ;;
        -m|--max-parallel) 
            shift
            max_parallel=${1}
            shift
        ;;
        -v|--verbose) 
            verbose=true
            shift
        ;;
        --new-log)
            new_log=true
            shift
        ;;
        --force-y)
            no_dialog=true
            shift
        ;;
        --null-lines)
            null_lines=true
            shift
        ;;
        --no-log) 
            no_log=true
            shift
        ;;
        --log-path) 
            shift
            log_path_on=true
            log_path=${1}
            shift
        ;;
        -c|--fixed-command) 
            shift
            fixed_command_input=${1}
            shift
        ;;
        -f|--files) 
            shift
            while [[ -e "${1}" ]]; do
                if [[ ! -d "${1}" ]]; then
                    list_of_files_input[${indf}]=${1}
                    ((indf++))
                fi
                shift
            done
            shift
        ;;
        *)
            error_1
        ;;
    esac
done
test_options