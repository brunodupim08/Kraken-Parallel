#!/usr/bin/env bash

version="2.0"
max_parallel="50"
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
                       .                                  .                               
                       c                                 .,             .,                
                        ;.              ......         .,,.   ..,;::cccl;                 
                         .::;'..    .;cllllllll:,.  .,:,....;clll:;'                      
               ...'...     .':ccc.'cllllllllllllll;.cc.  .clll;'.                         
                    ',::,.    'l;;lclllllllllll:.ll'lc  'llll.              .......       
                       .cl;    l:;l.:llllllllll: ll;:l. llll'           .':loc            
   .                    .loc..c;:oc.coooooooooool;lo:;c.oooo,         'coo:.              
    ;                    :oo:;::oocoooooooooooooooooo'l;coool.      ,loo:.                
    ,o:,,,:cclcc;'.      looo'c;oooooooooooooooooool,cll,loooo;.  .looo,.                 
     .ooooooooooooo:.   ,oooc,l;.ooo,cooooooooc,ol,   'll;:ooooo;.looo;                   
              ':odddo'.:oooo,l;  .;oo,:oooooo;,l,';;,.  llc;loooooc:lo                    
                .cdcc:ooool;cc  ;,..:o':oooo:,c.;;,coo   ooo::loooooc,                    
                ..:looooo::oo. ::.c,.lo.cool.oc;':c.lo   ooooo':oddddo,                   
                .cdddddl,looo'  :'OKxd'c;od;o,c0lNl.    'oooo::d;dddddd'                  
                cdddddo;;ooool.   :oox. :odo'.lkl.    .:ooooc;dd,ddddddo                  
               .dddddd;do;loooo,.   ;ddl:ddd:ddd;  .,cooooo::dd:lddddddd                  
               ,dddddd;dddc:cooool:,.odddddddddd'dccccllcccldd:lddddddd,                  
               .dddddd;xxxxxocccccc;:dddlddoodddo:ldxdoodxxoccdddddddd;                   
                odddddlcxxxxxxxxxdccdddd:dd:ddddddoccllllcclddddddddd    ..           ,   
         ...    .ddddddlcloddollclddddddoxdoxxxxxdxxxxxxxxxxxxxxxxd..'cdxxxxdc;'...,cd    
     .;coxxxdl.  .dxxxxxxdlllldxxdoxxxxxxxxxxxxxoclxxxxxxxxxxxxxo;.'oxxxxxxddxxxxxxxo     
           .xxx,   :xxxxxxxxxxxxd:lxxxxxxxxxxxxx.oxxxxxxxxxxxo:' .lxxxx;                  
             cxxc   .:oxxxxxxxc,.cxxxxxxxxxxxxxxc..,;::::;,..  .cxxxxo                    
              :xxd;     ',,'.. 'oxxxxxxxxxxxxxxxxxl;'.......,:oxxxxx,                     
               xxxxdc'.    .':dxxxxxxxd:,.:dxxxxxxxxxxxxxxxxxxxxxxx.                      
                dxxxxxxxoodxxxxxxxxxd,     .:xxxxxxxxxxxxxxxxxxxxx.                       
                  oxxxxxxxxkxkxxxxd:..       .;coxkkkkkkkkkkkkkd                          
                    :lxkkkkkkkkdl;..           ...';:cloooo;                              
                          .,'.                                                   
    \033[0m"
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


    -c)                     Fixed Command.
                            Start command with options.

    -f)                     File Path for Script
                            Search and read the script file.

    -v)                     Show version.

    -m)                     Limit parallel.
                            Limits the maximum number of commands in the background.
                            By default the limit is 50 commands.
                            If the value is 0, it will be illimited and can lock your
                            system if you have a very large list of commands.

    -y)                     Kraken-Parallel will force -y at the end of all commands
                            to have no confirmation prompts.
                            Some programs and commands cannot contain -y at the end
                            Be Careful !!!

    -l)                     Not create log.

    "
}

function progress() {
    # progress "$file" "$total_lines" "$index_line" "$active_parallel"
    local file="$1"
    local total_lines="$2"
    local index_line="$3"
    local active_parallel="$4"
    local percent=$(( ((index_line - active_parallel) * 100) / total_lines ))
    
    # Definir códigos de formatação ANSI diretamente nas variáveis locais usando tput
    local red="\033[1;31m"
    local bi_blue="\033[1;94m"
    local bi_yellow="\033[1;93m"
    local reset="\033[0m"
    
    # Cores
    local open_bracket="${bi_yellow}[${reset}"
    local close_bracket="${bi_yellow}]${reset}"
    local slash="${bi_yellow}/${reset}"
    
    tput sc  # Salvar posição do cursor
    printf "    ${open_bracket}${bi_blue}File:${reset} %s ${close_bracket}  ${open_bracket}${bi_blue}Total:${reset} %d "${slash}" %d ${close_bracket}  ${open_bracket}${bi_blue}Max:${reset} %d "${slash}" %d ${bi_blue}Actives${reset} ${close_bracket}  ${open_bracket}${bi_blue}Progresso:${reset} %d%% ${close_bracket}" \
    "$(basename "$file")"  "$index_line" "$total_lines" "$active_parallel" "$max_parallel" "$percent"
    tput rc  # Restaurar posição do cursor
}

function run_tentacle(){
    # run_tentacle "$command" "$log" "$file" "$index_line"
    local command="$1"
    local log="$2"
    local file="$3"
    local index_line="$4"

    if [[ $log == false ]]; then
        (
            $command 2> /dev/null
        ) &
    else
        local date=$(date +"%Y-%m-%d_%H:%M:%S")
        local log_file="$log_path/$file-Line_$index_line.log"

        if [[ ! -d "$log_path" ]]; then
            mkdir -p -m 700 "$log_path" > /dev/null || echo -e "Unable to create directory $log_path"; exit 1
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
                            echo -e "O arquivo $file não existe ou não tem permissão de leitura."; exit 1
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
                        echo "Por favor, digite um número inteiro válido na opção -m."; exit 1
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
                    echo "Opção inválida: -$OPTARG"; exit 1                                        # Código a ser executado em caso de opção desconhecida
                    ;;
                :)
                    echo "A opção -$OPTARG requer um argumento."; exit 1                           # Código a ser executado em caso de opção faltando argumento
                    ;;
            esac
        done
        if ! [[ $c == true && $f == true ]]; then
            echo "As opções -c e -f são obrigatórias."; exit 1
        else
            tput civis                                                                             # Esconder o cursor
            logo
            echo "    STARTED ..."
            for file in "${files[@]}"; do
                local total_lines=$(awk 'NF{p=NR} END{print p}' "$file")                           # Total lines in file
                local index_line="0"                                                               # Index line
                
                while IFS= read -r line; do                                                        # Read line and Index line increment
                    ((index_line++))
                    if [[ -z "$line" ]]; then                                                      # Skip null lines
                        continue
                    else
                        local command="$fixed_command $line $y"
                        local active_parallel=$(jobs -r | wc -l)                                   # Obtém os PIDs dos processos em execução em segundo plano, excluindo o PID do script
                        if [[ "$max_parallel" -eq "0" ]]; then                                     # Start with parallelism limit equal to 0.
                            progress "$file" "$total_lines" "$index_line" "$active_parallel"
                            run_tentacle "$command" "$log" "$file" "$index_line"
                        else
                            while true; do
                                local active_parallel=$(jobs -r | wc -l)                           # Obtém os PIDs dos processos em execução em segundo plano, excluindo o PID do script
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
                done <<< "$(cat $file; echo "")"                                                   # Open file
                while true; do
                    local active_parallel=$(jobs -r | wc -l)                                       # Obtém os PIDs dos processos em execução em segundo plano, excluindo o PID do script
                    progress "$file" "$total_lines" "$index_line" "$active_parallel"
                    if [[ $active_parallel -eq "0" ]]; then
                        printf "\r\033[K $fixed_command $file    Concluded!\n"
                        break
                    else
                        sleep 3s
                    fi
                done
            done
            tput cnorm                                                                             # Mostrar o cursor
        fi
    fi
}

trap 'echo -e "\n\n"; tput cnorm; exit' INT TERM

# Check if the script is being executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Call the main function only when executed directly
    main "$@"
fi
