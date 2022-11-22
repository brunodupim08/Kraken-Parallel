#Read me
#tmp_log must be informed before starting octopus.
#script must be informed before starting octopus.
#fixed_command_input must be informed before starting octopus.
#list_of_files_input must be informed before starting octopus.
#limit_parallel must be informed before starting octopus.

function log(){
    name_file="banana"

    echo -e "++++++++++++++++++++++++++++\n$(date)\nFile: $file_input\nTotal lines: $total_lines\n++++++++++++++++++++++++++++\n" >> $tmp_log/$name_file.txt
}

function progress_silent(){     #Display.
    echo -ne "\\r[ $total_lines / $index_line ][ Max: $limit_parallel | Actives: $active_parallel ]"
}

function active_tentacles(){
    export active_parallel      #Shows the total of commands running in the background.
    
    #It counts the number of PIDS in the background more the current one.
    jobs=($(jobs -r -p))
    active_parallel="${#jobs[@]}"
}

function script_verbose(){      #Verbose mode.
    ((index_line++))
    echo -e "Line:$index_line\nCommand: $fixed_command_input $line_input\n$($fixed_command_input $line_input 2>&1)\n" | tee -a $tmp_log/$name_file.txt &
}
function script_silent(){       #Silence mode.
    ((index_line++))
    echo -e "Line:$index_line\nCommand: $fixed_command_input $line_input\n$($fixed_command_input $line_input 2>&1)\n" >> $tmp_log/$name_file.txt &
}

function tentacles(){
    export total_lines          #Shows the total lines of file.
    export index_line           #Shows the index of line current.
    export line_input           #Shows the line current.
    export file_input           #Shows the file current.

    #Test if the process will be silent.
    if [[ "$script" = "script_silent" ]]; then
        progress="progress_silent"
    else
        progress=""
    fi
    #Tests if the log folder exists, if it doesn't exist it creates it.
    if [[ ! -d "$tmp_log" ]]; then
        mkdir -p $tmp_log
    fi
    #Start program with all passed parameters.
    for file_input in "${list_of_files_input[@]}"; do
        index_line=0
        total_lines=$(wc --lines < $file_input)
        log
        echo -e "\n$fixed_command_input $file_input"
        #Read the lines of the current file one by one and start.
        while IFS= read -r line_input; do
            #Run.
            while true; do
                active_tentacles
                $progress
                #Wait all the parallel commands finish and finish.
                [[ "$index_line" -eq "$total_lines" && "$active_parallel" -eq "0" ]] && break;
                #Starts with the parallel limit 0.
                if [[ "$index_line" -lt "$total_lines" && "0" -eq "$limit_parallel" ]]; then
                    $script
                    [[ "$total_lines" -ne "$index_line" ]] && break;
                #Starts with parallel limit.
                elif [[ "$index_line" -lt "$total_lines" && "$active_parallel" -lt "$limit_parallel" ]]; then
                    $script
                    [[ "$total_lines" -ne "$index_line" ]] && break;
                fi
                sleep 0.5s
            done
        done < "$file_input"
        echo -e "    Concluded !!!"
    done
    #A completion alert sounds and exits.
    echo -e "\n     # Logs created in path $tmp_log.\n\a"
    exit 0
}