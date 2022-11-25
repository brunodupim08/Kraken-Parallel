#Read me
#log_path must be informed before starting octopus.
#new_log must be called before starting octopus
#no_log must be informed before starting octopus.
#verbose must be informed before starting octopus.
#fixed_command_input must be informed before starting octopus.
#list_of_files_input must be informed before starting octopus.
#limit_parallel must be informed before starting octopus.

function usage(){
    cat /opt/Kraken-Parallel/usage.txt
    echo -e "\n"
    exit 0
}
function version(){
    echo "
    #=================#
    # Kraken-Parallel #
    #=================#

    Version: $version
    Author: Bruno Dupim
    Project: https://github.com/brunodupim08/Kraken-Parallel.git
    "
    exit 0
}
function error_1(){    #usage error.
	echo '
	Parameter error !!!
	usage:
		kp [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
		
	Try "kp --help" for more options.
	'
	exit 1
}
function error_2(){     #usage sudo in [FIXED-COMMAND].
    echo '
    Do not use sudo on [FIXED-COMMAND]
    Run sudo kp [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
    Try "kp --help" for more options.
    '
    exit 2
}
function error_3(){     #command conflict.
    echo '
    Parameter error !!!
    Do not use --no-log with --new-log and --log-path.
    Try "kp --help" for more options.
    '
    exit 3
}
function create_log(){
    export subshell_command     #Shows the subshell command.
    export dir_log="${log_path}/Kraken-Parallel-${USER}/${file_input##*/}-log"
    export file_log="${dir_log}/line-${index_line}.log"

    if [[ "$no_log" = true ]]; then
        if [[ "verbose" = true ]]; then
            subshell_output="echo -e "{Line:$index_line / Command: $subshell_command\n$task}\n""
        else
            subshell_output="echo -e "{Line:$index_line / Command: $subshell_command\n$task}\n" 2>&1 /dev/null"
        fi
    else
        #Tests if the log folder exists, if it doesn't exist it creates it.
        if [[ ! -d "$dir_log" ]]; then
            mkdir -p -m 760 "${dir_log}"
        fi
        #Test if the log is verbose
        if [[ "$verbose" = true ]]; then
            subshell_output="echo -e "{Line:$index_line / Command: $subshell_command\n$task}\n" | tee -a $file_log"
        else
            subshell_output='echo -e "{Line:$index_line / Command: $subshell_command\n$task}\n" >> $file_log'
        fi

    fi
}
function progress(){     #Display.
    echo -ne "\\r[ $total_lines / $index_line ][ Max: $limit_parallel | Actives: $active_parallel ]"
}
function total_lines(){
    export total_lines          #Shows the total lines of file.

    total_lines=$(wc --lines < $file_input)
    ((total_lines++))
}
function active_tentacles(){
    export active_parallel      #Shows the total of commands running in the background.
    
    #It counts the number of PIDS in the background more the current one.
    jobs=($(jobs -r -p))
    active_parallel="${#jobs[@]}"
}
function subshell(){      #Verbose mode.
    ((index_line++))
    (
        task=$($subshell_command 2>&1)
        $subshell_output
    ) &
}
function tentacles(){
    export index_line           #Shows the index of line current.
    export line_input           #Shows the line current.
    export file_input           #Shows the file current.
    export subshell_command     #Shows the subshell command.

    #options null test.
    if [[ ! -n $fixed_command_input && "${list_of_files_input[@]}" ]]; then
        error_1
    fi
    #sudo test.
    if (echo -e "$fixed_command_input" | grep -w 'sudo' && true);then
        error_2
    fi
    #Test if the process will be silent.
    if [[ "$verbose" = true ]]; then
        progress=""
    else
        progress="progress"
    fi
    #Start program with all passed parameters.
    for file_input in "${list_of_files_input[@]}"; do
        index_line=0
        total_lines

        #Test if new_log is true or false.
        if [[ "$new_log" = true && "$no_log" = false ]]; then
            echo -e "[ $(date) | File: $file_input | Total lines: $total_lines ]\n" > $file_log
        elif [[ "$new_log" = false && "$no_log" = false ]]; then
            echo -e "[ $(date) | File: $file_input | Total lines: $total_lines ]\n" >> $file_log
        else
            error_3
        fi
        echo -e "\n{ $fixed_command_input } { $file_input }\n"
        #Read the lines of the current file one by one and start.
        while IFS= read -r line_input; do
            subshell_command="$fixed_command_input $line_input"
            create_log
            #Run.
            while true; do
                active_tentacles
                $progress
                #Wait all the parallel commands finish and finish.
                [[ "$index_line" -eq "$total_lines" && "$active_parallel" -eq "0" ]] && break;
                #Starts with the parallel limit 0.
                if [[ "$index_line" -lt "$total_lines" && "0" -eq "$limit_parallel" ]]; then
                    subshell
                    [[ "$total_lines" -ne "$index_line" ]] && break;
                #Starts with parallel limit.
                elif [[ "$index_line" -lt "$total_lines" && "$active_parallel" -lt "$limit_parallel" ]]; then
                    subshell
                    [[ "$total_lines" -ne "$index_line" ]] && break;
                fi
                sleep 0.5s
            done
        done < "$file_input"
        echo -e "    Concluded !!!"
    done
    #A completion alert sounds and exits.
    echo -e "\n     # Logs created in path $file_log_path/Kraken-Parallel-$USER.\n\a"
    exit 0
}