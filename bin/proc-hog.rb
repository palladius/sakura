#!/usr/bin/env ruby

# proc-hog.rb (v2)
# A Ruby script to identify and display processes consuming high CPU or RAM.
# This version uses the reliable `ps aux` command.

processes = Hash.new { |h, k| h[k] = { cpu: 0.0, mem: 0.0, count: 0 } }

# Use `ps aux`, a standard and reliable format.
# USER PID %CPU %MEM VSZ RSS TT STAT STARTED TIME COMMAND
`ps aux`.each_line.with_index do |line, index|
  next if index == 0 # Skip header line

  parts = line.strip.split(/\s+/, 11)
  next unless parts.length >= 11

  cpu_val = parts[2].to_f
  mem_val = parts[3].to_f
  command_line = parts[10]

  # Extract the base command and its arguments
  command_parts = command_line.split(' ', 2)
  process_name = command_parts[0] || ""
  full_args = command_parts[1] || ""

  soft_id = ""

  # Heuristic to find a script name for common interpreters
  if process_name.match?(/node$|python[\d.]*$|ruby[\d.]*$/) && !full_args.empty?
    # Find the first argument that doesn't start with a '-'
    script = full_args.split(' ').find { |arg| !arg.start_with?('-') }
    soft_id = script || ""
  end

  # Clean paths from the names
  process_name.gsub!(/^.*\//, '')
  soft_id.gsub!(/^.*\//, '')

  # Don't show the script itself in the list
  next if process_name == 'proc-hog.rb'

  key = "#{process_name}@@@#{soft_id}"
  processes[key][:cpu] += cpu_val
  processes[key][:mem] += mem_val
  processes[key][:count] += 1
end

# --- Output Generation ---

markdown_output = []
markdown_output << "| Icon |  CPU  |  RAM  | Card | Process            | Identifier                  |"
markdown_output << "|:----:|:-----:|:-----:|:----:|:-------------------|:----------------------------|"

processes.each do |key, data|
  if data[:cpu] > 10 || data[:mem] > 10
    process_name, soft_id = key.split("@@@", 2)

    # Truncate long names
    process_name = process_name.length > 24 ? "#{process_name[0..20]}..." : process_name
    soft_id = soft_id.length > 21 ? "#{soft_id[0..17]}..." : soft_id

    icon = if data[:cpu] > 10 && data[:mem] > 10
             '🔥'
           elsif data[:cpu] > 10
             '🧠'
           else
             '🐟'
           end

    card_str = data[:count] > 1 ? format("%2dx", data[:count]) : ""

    markdown_output << format("| %s  | %5.1f%% | %5.1f%% | %4s | %-24s | %-21s |", 
                            icon, data[:cpu], data[:mem], card_str, process_name, soft_id)
  end
end

# --- Glow Integration ---

# Method to check if the glow command exists
def glow_exists?
  system("command -v glow > /dev/null")
end

# Check for glow and print the output
if glow_exists?
  IO.popen('glow', 'w') { |p| p.puts markdown_output.join("\n") }
else
  puts markdown_output.join("\n")
end