#!/usr/bin/env bash

version="2.0"
max_parallel="10"
log=false
log_path="/tmp/Kraken-Parallel/${USER}"

function logo(){
    echo -e "\033[1;96m
    oooo   oooo                       oooo                                  
     888  o88   oo oooooo   ooooooo    888  ooooo ooooooooo8 oo oooooo      
     888888      888    888 ooooo888   888o888   888oooooo8   888   888     
     888  88o    888      888    888   8888 88o  888          888   888     
    o888o o888o o888o      88ooo88 8o o888o o888o  88oooo888 o888o o888o    

    oooooooooo                                  o888  o888             o888 
     888    888 ooooooo   oo oooooo   ooooooo    888   888  ooooooooo8  888 
     888oooo88  ooooo888   888    888 ooooo888   888   888 888oooooo8   888 
    888      888    888   888      888    888   888   888 888          888 
    o888o      88ooo88 8o o888o      88ooo88 8o o888o o888o  88oooo888 o888o
    \033[0m"
}

function version(){
    local version="\033[1;94mv$version\033[0m"
    local author="\033[1;94mBruno Dupim\033[0m"
    local project="\033[1;94mhttps://github.com/brunodupim08/Kraken-Parallel.git\033[0m"
 
    echo -e "\033[1;94m
    #=================#
    # Kraken-Parallel #
    #=================#
    \033[0m
    Version: $version
    Author:  $author
    Project: $project
    "
}

function usage(){
    #information
    echo "
    usage:
            kraken-parallel [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
                    
                kraken-parallel -ly -m 100 -c 'wget' -f file-01.txt file-02.txt file-03.txt

    Note: 
            If the command or program requires "-y" confirmation, use --force-y.
            Do not use sudo within the file.


    -c)                     Fixed Command.
                            Start command with options.

    -f)                     File Path for Script
                            Search and read the script file.

    -v)                     Show version.

    -m)                     Limit parallel.
                            Limits the maximum number of commands in the background.
                            By default the limit is 10 commands.
                            If the value is 0, it will be illimited and can lock your
                            system if you have a very large list of commands.

    -y)                     Kraken-Parallel will force -y at the end of all commands
                            to have no confirmation prompts.
                            Some programs and commands cannot contain -y at the end
                            Be Careful !!!

    -l)                     Create log in /tmp/Kraken-Parallel/${USER}.

    -L)                     Create a log in a new path.
    
    "
}

function progress() {
    # progress "$file" "$total_lines" "$index_line" "$active_parallel"
    local file="$1"
    local total_lines="$2"
    local index_line="$3"
    local active_parallel="$4"
    local percent=$(( ((index_line - active_parallel) * 100) / total_lines ))

    # Set ANSI formatting codes directly in local variables using tput
    local red="\033[1;31m"
    local bi_blue="\033[1;94m"
    local bi_yellow="\033[1;93m"
    local reset="\033[0m"

    # Colors
    local open_bracket="${bi_yellow}[${reset}"
    local close_bracket="${bi_yellow}]${reset}"
    local slash="${bi_yellow}/${reset}"

    tput sc  # Save cursor position
    printf "    ${open_bracket}${bi_blue}File:${reset} %s ${close_bracket}  ${open_bracket}${bi_blue}Total:${reset} %d "${slash}" %d ${close_bracket}  ${open_bracket}${bi_blue}Max:${reset} %d "${slash}" %d ${bi_blue}Actives${reset} ${close_bracket}  ${open_bracket}${bi_blue}Progress:${reset} %d%% ${close_bracket}" \
    "$(basename "$file")"  "$index_line" "$total_lines" "$active_parallel" "$max_parallel" "$percent"
    tput rc  # Restore cursor position
}

function run_tentacle(){
    # run_tentacle "$command" "$log" "$file" "$index_line"
    local command="$1"
    local log="$2"
    local file="$3"
    local index_line="$4"

    if [[ $log == false ]]; then
        (
            $command > /dev/null 2>&1
        ) &
    else
        local date=$(date +"%Y-%m-%d_%H:%M:%S")
        local log_file="$log_path/$file-Line_$index_line.log"

        if [[ ! -d "$log_path" ]]; then
            mkdir -p -m 700 "$log_path" > /dev/null || { echo -e "Unable to create the directory $log_path"; exit 1; }
        fi
        (
            echo -e "[ "$command" ]\n" >> "$log_file"
            $command >> "$log_file" 2>&1 
            echo -e "\n[ "$date" ]\n" >> "$log_file"
        ) &
    fi
}

function main() {
    # main "$@"
    if [ $# -eq 0 ]; then
        usage; exit 0
    else
        while getopts ":hlvyc:f:m:L:" opt; do
            case $opt in
                h)
                    usage; exit 0
                    ;;
                c)  
                    fixed_command="${OPTARG}"
                    if [[ "$fixed_command" == *sudo* ]]; then
                        echo "Do not use sudo on -c option."; exit 1
                    fi
                    local c=true
                    ;;
                f)
                    local files=("$OPTARG")
                    while [[ $OPTIND -le $# && ${!OPTIND} != -* ]]; do
                        files+=("${!OPTIND}")
                        ((OPTIND++))
                    done
                    for file in "${files[@]}"; do
                        if [[ ! -e "$file" ]] || [[ ! -r "$file" ]]; then
                            echo -e "The file $file does not exist or does not have read permission."; exit 1
                        elif grep -w 'sudo' "$file" > /dev/null; then
                            echo -e "The $file file has sudo, do not use sudo within the file."; exit 1
                        fi
                    done
                    local f=true
                    ;;
                l)
                    log=true
                    ;;
                m)
                    if [[ $OPTARG =~ ^[0-9]+$ ]] ; then
                        max_parallel="$OPTARG"
                    else
                        echo "Please enter a valid integer for the -m option."; exit 1
                    fi
                    ;;
                v)
                    version; exit 0
                    ;;
                y)
                    local y="-y"
                    ;;
                L)
                    log=true
                    log_path="${OPTARG}"
                    if [[ ! -d "$log_path" ]] ; then
                        echo -e " $log_path it is not a directory."; exit 1
                    fi
                    ;;
                \?)
                    # Code to be executed in case of unknown option
                    echo "Invalid option: -$OPTARG"; exit 1
                    ;;
                :)
                    # Code to be executed in case of missing argument for an option
                    echo "Option -$OPTARG requires an argument."; exit 1
                    ;;
            esac
        done
        if ! [[ $c == true && $f == true ]]; then
            echo "Options -c and -f are mandatory."; exit 1
        else
            # Hide the cursor
            tput civis
            logo
            echo "    STARTED ..."
            for file in "${files[@]}"; do
                # Total lines in file
                local total_lines=$(awk 'NF{p=NR} END{print p}' "$file")
                local index_line="0"
                
                # Read line and Index line increment
                while IFS= read -r line; do
                    ((index_line++))
                    # Skip null lines
                    if [[ -z "$line" ]]; then
                        continue
                    else
                        local command="$fixed_command $line $y"
                        # Get the PIDs of background processes, excluding the script's PID
                        local active_parallel=$(jobs -r | wc -l)
                        # Start with parallelism limit equal to 0.
                        if [[ "$max_parallel" -eq "0" ]]; then
                            progress "$file" "$total_lines" "$index_line" "$active_parallel"
                            run_tentacle "$command" "$log" "$file" "$index_line"
                        else
                            while true; do
                                # Get the PIDs of background processes, excluding the script's PID
                                local active_parallel=$(jobs -r | wc -l)
                                progress "$file" "$total_lines" "$index_line" "$active_parallel"
                                if [[ $active_parallel -lt $max_parallel ]]; then
                                    run_tentacle "$command" "$log" "$file" "$index_line"
                                    break
                                else
                                    sleep 1s
                                fi
                            done
                        fi
                    fi
                done <<< "$(cat $file; echo "")" # Open file
                while true; do
                    # Get the PIDs of background processes, excluding the script's PID
                    local active_parallel=$(jobs -r | wc -l)                                       
                    progress "$file" "$total_lines" "$index_line" "$active_parallel"
                    if [[ $active_parallel -eq "0" ]]; then
                        printf "\r\033[K $fixed_command $file    Concluded!\n"
                        break
                    else
                        sleep 3s
                    fi
                done
            done
            # Show the cursor
            tput cnorm
        fi
    fi
}

trap 'echo -e "\n\n"; tput cnorm; exit' INT TERM

# Check if the script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Call the main function only when executed directly
    main "$@"
fi
