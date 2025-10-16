#!/bin/bash

# This script identifies processes with high resource usage and formats the output
# as a Markdown table. It uses a robust and highly compatible method to parse ps output.

PROCESS_DATA=$(ps -eo %cpu,%mem,comm,args -o comm=,args= | sed 's/COMMAND_NAME=//' | sed 's/FULL_ARGS=//' | awk '
BEGIN {
    FS = "@@@";
    printf "| Icon |  CPU  |  RAM  | Card | Process            | Identifier                  |\n";
    printf "|:----:|:-----:|:-----:|:----:|:-------------------|:----------------------------|\n";
}
{
    line = $1;
    # Extract CPU
    sub(/^[ ]*/, "", line);
    cpu_end = index(line, " ");
    cpu_val = substr(line, 1, cpu_end - 1);
    line = substr(line, cpu_end + 1);
    
    # Extract MEM
    sub(/^[ ]*/, "", line);
    mem_end = index(line, " ");
    mem_val = substr(line, 1, mem_end - 1);
    process_name = substr(line, mem_end + 1);

    full_args = $2;
    soft_id = "";

    if ((process_name ~ /node$/ || process_name ~ /python[0-9.]*$/ || process_name ~ /ruby[0-9.]*$/)) {
        split(full_args, args_array, " ");
        for (i in args_array) {
            if (substr(args_array[i], 1, 1) != "-") {
                soft_id = args_array[i];
                break;
            }
        }
    }
    
    gsub(/^.*\//, "", process_name);
    gsub(/^.*\//, "", soft_id);

    key = process_name "@@@" soft_id;

    cpu[key] += cpu_val;
    mem[key] += mem_val;
    count[key]++;
}
END {
    for (key in cpu) {
        if (cpu[key] > 10 || mem[key] > 10) {
            split(key, parts, "@@@");
            process_name = parts[1];
            soft_id = parts[2];

            # Truncate long names to prevent table layout breaking
            if (length(process_name) > 18) process_name = substr(process_name, 1, 15) "...";
            if (length(soft_id) > 27) soft_id = substr(soft_id, 1, 24) "...";

            if (cpu[key] > 10 && mem[key] > 10) { icon="🔥"; } 
            else if (cpu[key] > 10) { icon="🧠"; } 
            else { icon="🐟"; }

            card_str = (count[key] > 1) ? sprintf("%2dx", count[key]) : "";

            printf "| %s  | %5.1f%% | %5.1f%% | %4s | %-18s | %-27s |\n", icon, cpu[key], mem[key], card_str, process_name, soft_id;
        }
    }
}')

if command -v glow &> /dev/null; then
    echo -e "$PROCESS_DATA" | glow
else
    echo -e "$PROCESS_DATA"
fi
