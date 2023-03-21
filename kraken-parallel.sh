#!/usr/bin/env bash

#Read me
#version must be informed before starting octopus.
#fixed_command_input must be informed before starting octopus.
#list_of_files_input must be informed before starting octopus.
#log_path must be informed before starting octopus.
#new_log must be called before starting octopus.
#no_log must be informed before starting octopus.
#verbose must be informed before starting octopus.
#max_parallel must be informed before starting octopus.
#null_lines must be notified before starting octopus.

version="v1.1.0"
log_path="/tmp"
new_log=false
no_log=false
verbose=false
max_parallel=50
null_lines=false


trap 'echo ""; exit' INT TERM
#================= functions information =================#
function usage(){
    echo "
    usage:
            kraken-parallel [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
    
                kraken-parallel -c 'wget -x' -f urls.txt

                kraken-parallel -m 1000 -c 'wget -c -x' -f ~/urls/file-01.txt
                
                kraken-parallel -c 'wget' -f file-01.txt file-02.txt file-03.txt

    Note: 
            If the command or program requires "-y" confirmation, use --force-y.


    -c|--fixed-command)     Fixed Command.
                            Start command with options.

    -f|--files)             File Path for Script
                            Search and read the script file.

    --version)              Show version.

    -m|--max-parallel)      Limit parallel.
                            Limits the maximum number of commands in the background.
                            By default the limit is 50 commands.
                            If the value is 0, it will be illimited and can lock your
                            system if you have a very large list of commands.
    
    -v|--verbose)           Verbose run_mode.

    --force-y)              Kraken-Parallel will force -y at the end of all commands
                            to have no confirmation prompts.
                            Some programs and commands cannot contain -y at the end
                            Be Careful !!!

    --no-log)               Not create log.

    --new-log)              New log file.
                            Overwrite previous log.

    --log-path)             Path to log file.

    --null-lines)           Not ignore null lines.
                            By default, null lines will be ignored.

    "
    exit 0
}
function version(){
    echo -e "
    #=================#
    # Kraken-Parallel #
    #=================#

    Version: $version
    Author: Bruno Dupim
    Project: https://github.com/brunodupim08/Kraken-Parallel.git
    "
    exit 0
}
#================= functions alerts =================#
function alert_sound(){
    echo -e "\a"
}
function concluded_alert(){
    echo "  Concluded !!!
    "
    alert_sound
}
#================= functions errors messages =================#
function error_1(){    #usage error.
	echo "
	Parameter error !!!
	usage:

		kraken-parallel [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
		
	Try "kraken-parallel -h or --help" for more options.
	"
    alert_sound
	exit 1
}
function error_2(){     #usage sudo in [FIXED-COMMAND].
    echo "
    Do not use sudo on [FIXED-COMMAND] or [FILE-LIST-COMMAND]

        Run sudo kraken-parallel [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]

    Try "kraken-parallel -h or --help" for more options.
    "
    alert_sound
    exit 2
}
function error_3(){     #command conflict.
    echo "
    Parameter error !!!

        Do not use --no-log with --new-log and --log-path.

    Try "kraken-parallel -h or --help" for more options.
    "
    alert_sound
    exit 3
}
function error_4(){     #max-limit error
    echo "Error 4 !!!

        --max-limit accepts only integers greater than or equal to 0.

    Try "kraken-parallel -h or --help" for more options.
    "
    alert_sound
    exit 4
}
function error_5(){     #directory conflict.
    echo -e "Error 5 !!!

        Unable to create directory ${dir_log}

    Make sure you have permissions for this directory.
    Try "kraken-parallel -h or --help" for more options.
    "
    alert_sound
    exit 5
}
function error_6(){     #directory conflict.
    echo -e "Error 6 !!!

        " $log_path " it is not a directory.

    Try "kraken-parallel -h or --help" for more options.
    "
    alert_sound
    exit 6
}
#================= functions test =================#
function test_options(){
    export progress         #Shows the progress command.
    export run_mode         #run_mode "silent", "verbose", "no_log_verbose" or "silent_no_log"    

    #options null test.
    if [[ -z $fixed_command_input || -z "${list_of_files_input[@]}" ]]; then
        error_1
    #--no-log with --new-log and --log-path.
    elif [[ "$no_log" = true && "$new_log" = true || "$no_log" = true && "$log_path_on" = true ]]; then
        error_3
    #test options null log-path.
    elif [[ -z "$log_path" || ! -d "$log_path" ]]; then
        error_6
    fi

    #Test max_parallel
    if [[ -n "$max_parallel" ]]; then
        re='^[0-9]+$'
        if [[ ! $max_parallel =~ $re ]]; then
            error_4
        elif [[ "$max_parallel" -lt "0" ]]; then
            error_4
        fi
    else
        error_4
    fi

    #Force -y.
    if [[ "$no_dialog" = true ]]; then
        force_y="-y"
    else
        force_y=""
    fi
    
    #sudo test.
    if (echo -e "$fixed_command_input" | grep -w 'sudo' && true);then
        error_2
    else
        echo -ne "\n\rTest files ..."
        for file_input in "${list_of_files_input[@]}"; do
            if (cat "$file_input" | grep -w 'sudo' && true); then
                error_2
            fi
        done
        concluded_alert
    fi
    #If none of the tests fail, it runs the program.
    tentacles
}
#================= run_mode =================#
function run_mode(){
    export dir_log="${log_path}/Kraken-Parallel-${USER}/${file_input##*/}-log"      #directory log.
    export log_file="${dir_log}/line-${index_line}.log"                             #file log

    # "silent", "verbose", "no_log_verbose" or "silent_no_log"
    if [[ "$no_log" == true && "$verbose" == false ]]; then
        run_mode="no_log_silent"
        progress="progress"
    elif [[ "$no_log" == true && "$verbose" == true ]]; then
        run_mode="no_log_verbose"
        progress=""
    else
        #Tests if the log folder exists, if it doesn't exist it creates it.
        if [[ ! -d "$dir_log" ]]; then
            mkdir -p -m 760 "${dir_log}" > /dev/null || error_5
        # Check if new_log variable is true
        elif [[ "$new_log" == true ]]; then
            # Clear existing log file
            log_file="${dir_log}/new-log-${index_line}.log"
            > "$log_file" 
        fi

        if [[ "$verbose" == true ]]; then
            run_mode="verbose"
            progress=""
        else
            run_mode="silent"
            progress="progress"
        fi
    fi
}
function no_log_silent(){
    (
    task=$($subshell_command 2> /dev/null)
    ) &
}
function no_log_verbose(){
    (
    task=$($subshell_command 2>&1)
    sleep 1s
    echo -e "[ $(date) ]\nLine:$index_line\n$task\n"
    ) &
}
function verbose(){
    (
    task=$($subshell_command 2>&1)
    sleep 1s
    echo -e "[ $(date) ]\nLine:$index_line\n$task\n" | tee -a "${dir_log}/line-$index_line.log"
    ) &
}
function silent(){
    (
    task=$($subshell_command 2>&1)
    echo -e "[ $(date) ]\nLine:$index_line\n$task\n" >> "${dir_log}/line-$index_line.log"
    ) &
}
#================= Processing =================#
function progress(){     #Display.
    printf "  [Total: \033[1m%s\033[0m / \033[1;32m%s\033[0m] [Max: \033[1m%s\033[0m / \033[1;32m%s\033[0m Actives] \r" "$total_lines" "$index_line" "$max_parallel" "$active_parallel"
}
#================= functions process =================#
function active_tentacles(){
    export active_parallel      #Shows the total of commands running in the background.
    
    #It counts the number of PIDS in the background more the current one.
    local jobs=($(jobs -r -p))
    active_parallel="${#jobs[@]}"
}
function tentacles(){
    export line_input           #Shows the line current.
    export file_input           #Shows the file current.
    export subshell_command     #Shows the subshell command.
    export index_line           #Shows the index of line current.
    export total_lines          #Shows the total lines of file.

    for file_input in "${list_of_files_input[@]}"; do #Start program with all passed parameters.
        
        index_line=0
        echo -e "$file_input"
        total_lines=$(wc --lines < $file_input)
        run_mode

        while IFS= read -r line_input; do #Read the lines of the current file one by one and start.
            ((index_line++))
            [[ -z "$line_input" && "$null_lines" == "false" ]] && continue;        # null lines shift
            subshell_command="$fixed_command_input $line_input $force_y"
            active_tentacles
            if [[ "$max_parallel" -eq "0" ]]; then  #Starts with the parallel limit 0.
                $run_mode
            else                                    #Starts with parallel limit.
                while [[ "$active_parallel" -ge "$max_parallel" ]]; do
                    wait -n
                    active_tentacles
                    $progress
                done
                $run_mode
            fi
            $progress
        done < "$file_input"
        while [[ "$active_parallel" -ne "0" ]]; do
            wait -n
            active_tentacles
            $progress
        done
        active_parallel=0
    done
    #A completion alert sounds and exits.
    alert_sound
    exit 0
}
#================= Option =================#
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
        ;;
        --new-log)
            new_log=true
        ;;
        --force-y)
            no_dialog=true
        ;;
        --null-lines)
            null_lines=true
        ;;
        --no-log) 
            no_log=true
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