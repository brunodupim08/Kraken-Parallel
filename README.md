# Kraken-Parallel
Lets you run multiple commands in parallel.

Kraken-Parallel is an open source program written in Bash, which allows you to run multiple commands in parallel in multiple subshells.

This allows for greater use of cpu and cores to perform repetitive tasks with large amounts of commands.

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
                            By default the limit is 10 commands.
                            If the value is 0, it will be illimited and can lock your
                            system if you have a very large list of commands.
    
    -v|--verbose)           Verbose mode.

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