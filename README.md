# Kraken-Parallel
Allows you to run a command or multiple scripts in parallel.

To start without installing use:

    ./kp
 or
    
    bash kp

.

    usage:
            kp [OPTION] [FIXED-COMMAND] [FILE-LIST-COMMAND]
    
                kp -c 'wget -q -x' -f urls.txt

                kp -m 1000 -c 'wget -q -x' -f ~/urls/file-01.txt
                
                kp -c 'wget' -f file-01.txt file-02.txt file-03.txt
            
            kp [OPTION] [FILE-LIST-COMMAND]

                kp -f command-list.txt
                
                kp -f command-list1.txt command-list2.txt


    -m|--max-parallel)      limit parallel.
                            Limits the maximum number of commands in the background.
                            By default the limit is 10 commands.
                            If the value is 0, it will be illimited and can lock your system if you have a very large list of commands.
    
    -c)                     Fixed Command
                            Start command with options.

    -f)                     File Path for Script
                            Search and read the script file.
