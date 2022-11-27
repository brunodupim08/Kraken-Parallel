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
    case "${1}" in
        --version) 
            version
        ;;
        -h|--help) 
            usage
        ;;
        -m|--max-parallel) 
            max_parallel=${2}
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
            log_path_on=true
            log_path=${2}
            shift
        ;;
        -c|--fixed-command) 
            fixed_command_input=${2}
            shift
        ;;
        -f|--files) 
            while true; do
                if [[ ! -d "${2}" && -e "${2}" ]]; then
                    list_of_files_input[${indf}]=${2}
                    ((indf++))
                else
                    break
                fi
                shift
            done
        ;;
        *)
            error_1
        ;;
    esac
    shift
done
test_options