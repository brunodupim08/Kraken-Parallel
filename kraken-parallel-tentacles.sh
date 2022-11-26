#Read me
#log_path must be informed before starting octopus.
#new_log must be called before starting octopus
#no_log must be informed before starting octopus.
#verbose must be informed before starting octopus.
#fixed_command_input must be informed before starting octopus.
#list_of_files_input must be informed before starting octopus.
#max_parallel must be informed before starting octopus.

#================= functions information =================#
function usage(){
    echo "
    usage:
            kraken-parallel [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
    
                kraken-parallel -c 'wget -x' -f urls.txt

                kraken-parallel -m 1000 -c 'wget -c -x' -f ~/urls/file-01.txt
                
                kraken-parallel -c 'wget' -f file-01.txt file-02.txt file-03.txt

    Note: 
            Kraken-Parallel will force -y at the end of all commands
            to have no confirmation prompts.

    -c|--fixed-command)     Fixed Command.
                            Start command with options.

    -f|--files)             File Path for Script
                            Search and read the script file.

    --version)              Show version.

    -m|--max-parallel)      Limit parallel.
                            Limits the maximum number of commands in the background.
                            By default the limit is 10 commands.
                            If the value is 0, it will be illimited and can lock your
                            system if you have a very large list of commands.
    
    -v|--verbose)           Verbose mode.

    --no-log)               Not create log.

    --new-log)              New log file.
                            Overwrite previous log.

    --log-path)             Path to log file.

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
function log_alert(){
    echo -e "
    # Logs created in path ${log_path}/Kraken-Parallel-${USER}
    "
    alert_sound
    exit 0
}
#================= functions errors messages =================#
function error_1(){    #usage error.
	echo "
	Parameter error !!!
	usage:
		kp [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
		
	Try "kp --help" for more options.
	"
    alert_sound
	exit 1
}
function error_2(){     #usage sudo in [FIXED-COMMAND].
    echo "
    Do not use sudo on [FIXED-COMMAND] or [FILE-LIST-COMMAND]
    Run sudo kp [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
    Try "kp --help" for more options.
    "
    alert_sound
    exit 2
}
function error_3(){     #command conflict.
    echo "
    Parameter error !!!
    Do not use --no-log with --new-log and --log-path.
    Try "kp --help" for more options.
    "
    alert_sound
    exit 3
}
function error_4(){     #max-limit error
    echo "Error 4 !!!
    --max-limit accepts only integers greater than or equal to 0.
    "
    alert_sound
    exit 4
}
function error_5(){     #directory conflict.
    echo -e "Error 5 !!!
    Unable to create directory ${dir_log}
    Make sure you have permissions for this directory.
    "
    alert_sound
    exit 5
}
function error_13(){
    echo "Error 13 !!!
    Internal error.
    "
    alert_sound
    exit 13
}
#================= functions test =================#
function test_options(){
    export subshell     #Shows the subshell command.
    export progress     #Shows the progress command.

    #options null test.
    if [[ -z $fixed_command_input && "${list_of_files_input[@]}" ]]; then
        error_1
    #--no-log with --new-log and --log-path.
    elif [[ "$no_log" = true && "$new_log" = true ]]; then
        error_3
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

    #Test if the process will be silent.
    if [[ "$verbose" = true ]]; then
        progress=""
    else
        progress="progress"
    fi

    #sudo test.
    if (echo -e "$fixed_command_input" | grep -w 'sudo' && true);then
        error_2
    else
        echo "Test files"
        for file_input in "${list_of_files_input[@]}"; do
            if (cat "$file_input" | grep -w 'sudo' && true); then
                error_2
            fi
        done
    fi
    #If none of the tests fail, it runs the program.
    tentacles
}
#================= functions log =================#
function log_options(){
    export dir_log="${log_path}/Kraken-Parallel-${USER}/${file_input##*/}-log"  #directory log.
    export log_alert

    #Show command end file input.
    echo -e "\n{ $fixed_command_input } { $file_input }\n"
    if [[ "$no_log" = false ]]; then
        #Tests if the log folder exists, if it doesn't exist it creates it.
        if [[ ! -d "$dir_log" ]]; then
            mkdir -p -m 760 "${dir_log}" 2> /dev/null || error_5
        fi
        #Test if the log is verbose
        if [[ "$verbose" = true ]]; then
            subshell="log_verbose"
        else
            subshell="log_silent"
        fi
        if [[ "$no_log" = false ]]; then
            log_alert="log_alert"
        fi
    elif [[ "$no_log" = true ]]; then
        #Test is verbose
        if [[ "$verbose" = true ]]; then
            subshell="no_log_verbose"
        else
            subshell="no_log"
        fi
    else
        error_13
    fi
}
function no_log(){
    (
    task=$($subshell_command 2> /dev/null)
    ) &
}
function no_log_verbose(){
    (
    task=$($subshell_command 2>&1)
    sleep 0,1s
    echo -e "[ $(date) ]\nLine:$index_line\n$task\n"
    ) &
}
function log_verbose(){
    (
    task=$($subshell_command 2>&1)
    sleep 0,1s
    echo -e "[ $(date) ]\nLine:$index_line\n$task\n" | tee -a $file_log
    ) &
}
function log_silent(){
    (
    task=$($subshell_command 2>&1)
    sleep 0,1s
    echo -e "[ $(date) ]\nLine:$index_line\n$task\n" >> $file_log
    ) &
}
function progress(){     #Display.
    echo -ne "\\r[ $total_lines / $index_line ][ Max: $max_parallel | Actives: $active_parallel ]"
}
#================= functions process =================#
function active_tentacles(){
    export active_parallel      #Shows the total of commands running in the background.
    
    #It counts the number of PIDS in the background more the current one.
    jobs=($(jobs -r -p))
    active_parallel="${#jobs[@]}"
}
function info_file_input(){
    export total_lines          #Shows the total lines of file.
    export parallel=true        #Shows if the commands running in the background and continue loop.
    export index_line=0         #Shows the index of line current.

    total_lines=$(wc --lines < $file_input)
    ((total_lines++))
}
function tentacles(){
    export line_input           #Shows the line current.
    export file_input           #Shows the file current.
    export subshell_command     #Shows the subshell command.

    #Start program with all passed parameters.
    for file_input in "${list_of_files_input[@]}"; do
        info_file_input
        log_options
        #Read the lines of the current file one by one and start.
        while IFS= read -r line_input || [[ ! "$parallel" = false ]]; do
            #Jump if the row is null.
            [[ -z "$line_input" && "$index_line" -gt "$total_lines" ]] && continue;
            subshell_command="$fixed_command_input $line_input"
            file_log="${dir_log}/line-$index_line.log"
            #Run subshell in the background.
            while true; do
                active_tentacles
                #Starts with the parallel limit 0.
                if [[ "$index_line" -lt "$total_lines" && "$max_parallel" -eq "0" ]]; then
                    $progress
                    $subshell
                    ((index_line++))
                    break
                #Starts with parallel limit.
                elif [[ "$index_line" -lt "$total_lines" && "$active_parallel" -le "$max_parallel" ]]; then
                    $progress
                    $subshell
                    ((index_line++))
                    break
                #Wait all the parallel commands finish and finish.
                elif [[ "$index_line" -ge "$total_lines" && "$active_parallel" -eq "0" ]]; then
                    $progress
                    parallel=false
                    break
                else
                    $progress
                fi
            done
        done < "$file_input"
        concluded_alert
    done
    #A completion alert sounds and exits.
    alert_sound
    $log_alert
    exit 0
}
#================= End code ================#