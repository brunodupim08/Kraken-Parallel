#Read me
#script must be informed before starting octopus.
#fixed_command_input must be informed before starting octopus.
#list_of_files_input must be informed before starting octopus.
#limit_parallel must be informed before starting octopus.


function log(){
   echo -e "$(date)\nFile: $file_input\n" > op-log-$file.txt
}

function progress_silent(){ #Display
    echo -ne "\\r[ $total_lines / $index_line ][ Tentacles: $limit_parallel / $active_parallel ]"
}

function active_tentacles(){
    export active_parallel      #Shows the total of commands running in the background.
    
    #It counts the number of PIDS in the background more the current one.
    jobs=($(jobs -p)) #-1
    active_parallel="$((${#jobs[@]}-1))"
}

function script_verbose(){
    ((index_line++))
    $({ $fixed_command_input $line_input;} || { 2>> op-log-$file.txt; echo -e "line $index_line error!!!\n\n" >> op-log-$file.txt;}) &
}
function script_silent(){
    ((index_line++))
    $({ $fixed_command_input $line_input 2> /dev/null ;} || { 2>> op-log-$file.txt; echo -e "line $index_line error!!!\n\n" >> op-log-$file.txt;}) &
}

function tentacles(){
    export total_lines          #Shows the total lines of file.
    export index_line           #Shows the index of line current.
    export line_input           #Shows the line current.
    export file_input           #Shows the file current.
    export file=0
    

    for file_input in "${list_of_files_input[@]}"; do
        ((file++))
        total_lines=$(wc --lines < $file_input)
        index_line=0
        log
        echo -e "\n$fixed_command_input $file_input"
        if [[ "$script" = "script_silent" ]]; then
            progress="progress_silent"
        else
            progress=""
        fi
        while IFS= read -r line_input; do
            #Ignore null lines
            [[ -n "$line_input" ]] && shift;
            #Run
            while true; do
                active_tentacles
                $progress
                #Wait all the parallel commands finish and finish.
                [[ "$index_line" -eq "$total_lines" && "$active_parallel" -eq "0" ]] && break;
                #Starts with the parallel limit 0.
                if [[ "$index_line" -lt "$total_lines" && "0" -eq "$limit_parallel" ]]; then
                    $script
                    [[ "$total_lines" -ne "$index_line" ]] && break;
                #Starts with parallel limit
                elif [[ "$index_line" -lt "$total_lines" && "$active_parallel" -lt "$limit_parallel" ]]; then
                    $script
                    [[ "$total_lines" -ne "$index_line" ]] && break;
                fi
                sleep 0.5s
            done
        done < "$file_input"
        echo -e "    Concluded !!!" &
    done
    exit 0
}