#!/bin/bash

# Author: Matthew Shelley
# mjshelley.com

# Combined LLM Project Analyzer Script

# Function to print usage information
print_usage() {
    echo "Usage: $0 [options] [directory]"
    echo "Options:"
    echo "  -o OUTPUT_FILE : Name of the output file (default: llm_project_analysis.txt)"
    echo "  -f FILE_LIST   : Path to a file containing the list of main files to include (default: llm_main_files.txt)"
    echo "  -m MAX_SIZE    : Maximum total size in MB (default: unlimited)"
    echo "  -d MAX_DEPTH   : Maximum depth for directory traversal (default: unlimited)"
    echo "  -s SUBFOLDERS  : Comma-separated list of subfolders to include (default: none)"
    echo "  -i IGNORE_FILE : Path to a file containing additional files/directories to ignore"
    echo "  -a             : Include all files in subfolders (use with caution)"
    echo "  -h             : Display this help message"
}

# Default values
target_dir="."
output_file="llm_project_analysis.txt"
file_list="llm_main_files.txt"
max_size=0
max_depth=0
subfolders=""
ignore_file=""
include_all=false

# Parse command line options
while getopts ":o:f:m:d:s:i:ah" opt; do
    case $opt in
        o) output_file="$OPTARG" ;;
        f) file_list="$OPTARG" ;;
        m) max_size=$((OPTARG * 1024 * 1024)) ;; # Convert MB to bytes
        d) max_depth="$OPTARG" ;;
        s) subfolders="$OPTARG" ;;
        i) ignore_file="$OPTARG" ;;
        a) include_all=true ;;
        h) print_usage; exit 0 ;;
        \?) echo "Invalid option: -$OPTARG" >&2; print_usage; exit 1 ;;
    esac
done

# Remove the options from the positional parameters
shift $((OPTIND - 1))

# Check if a directory was provided
if [ $# -gt 0 ]; then
    target_dir="$1"
fi

# Ensure target_dir is an absolute path
target_dir=$(cd "$target_dir" && pwd)

# Set the full path for the output file
output_file="$target_dir/$output_file"

# Remove the output file if it already exists
if [ -f "$output_file" ]; then
    echo "Removing existing output file: $output_file"
    rm -f "$output_file"
fi

# Initialize total size counter
total_size=0

# Default ignore list (including new entries)
IGNORE_LIST="node_modules .git .DS_Store llm_project_analysis.txt llm_main_files.txt"

# Add additional files to ignore list from the ignore file
if [ -n "$ignore_file" ] && [ -f "$ignore_file" ]; then
    IGNORE_LIST="$IGNORE_LIST $(grep -v '^#' "$ignore_file" | tr '\n' ' ')"
fi

# Function to check if a file should be ignored
should_ignore() {
    local item="$1"
    # Always ignore "." and ".."
    if [[ "$item" == "." || "$item" == ".." ]]; then
        return 0
    fi
    for ignore in $IGNORE_LIST; do
        if [[ "$item" == "$ignore" || "$item" == *"$ignore"* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to get relative path
get_relative_path() {
    local full_path="$1"
    local base_path="$2"
    local rel_path="${full_path#$base_path/}"
    # Remove leading "./" if present
    echo "${rel_path#./}"
}

# Function to get canonical path
get_canonical_path() {
    local path="$1"
    cd "$(dirname "$path")" && echo "$(pwd)/$(basename "$path")"
}

# Function to print the tree structure
print_tree() {
    local dir="$1"
    local prefix="$2"
    local depth="$3"

    # Check if we've reached the maximum depth
    if [ "$max_depth" -ne 0 ] && [ "$depth" -gt "$max_depth" ]; then
        return
    fi

    # Get the list of files and directories, including hidden ones, sorted alphabetically
    local items=($(ls -1A "$dir" | sort))

    # Iterate through the items (files and directories)
    for i in "${!items[@]}"; do
        local item="${items[$i]}"
        local path="$dir/$item"
        
        # Skip ignored items (including "." and "..")
        if should_ignore "$item"; then
            continue
        fi

        # Print the current item
        echo "${prefix}${item}" >> "$output_file"

        # If it's a directory, recurse into it
        if [ -d "$path" ]; then
            local new_prefix

            # Determine the new prefix for the next level
            if [ $((i + 1)) -eq ${#items[@]} ]; then
                new_prefix="${prefix}    "
            else
                new_prefix="${prefix}│   "
            fi

            print_tree "$path" "$new_prefix" $((depth + 1))
        fi
    done
}

# Function to concatenate files
concatenate_files() {
    local base_dir="$1"
    local file="$2"

    # Get canonical path
    local canonical_path=$(get_canonical_path "$file")

    # Check if file has already been processed
    if [[ "$processed_files" =~ "$canonical_path" ]]; then
        return 0
    fi

    # Get relative path
    local rel_path=$(get_relative_path "$file" "$base_dir")

    # Get file size
    local file_size=$(stat -f%z "$file")
    
    # Check if adding this file would exceed the maximum size
    if [ $max_size -ne 0 ] && [ $((total_size + file_size)) -gt $max_size ]; then
        echo "Warning: Maximum size reached. Stopping file processing." >&2
        return 1
    fi

    # Add a separator with the file name
    echo -e "\n\n--- File: $rel_path ---\n" >> "$output_file"
    
    # Append the file content
    cat "$file" >> "$output_file"
    
    # Update total size
    total_size=$((total_size + file_size))

    # Mark file as processed
    processed_files="$processed_files $canonical_path"

    echo "Added: $rel_path"
    return 0
}

# Main script execution

# Generate directory structure
echo "Generating directory structure..."
echo -e "--- Project Directory Structure ---\n" >> "$output_file"
echo "." >> "$output_file"
print_tree "$target_dir" "├── " 1

# Initialize processed files list
processed_files=""

# Process main files
if [ -f "$target_dir/$file_list" ]; then
    echo -e "\n--- Main Project Files ---\n" >> "$output_file"
    while IFS= read -r file || [ -n "$file" ]; do
        # Skip empty lines and comments
        [[ -z "$file" || "$file" == \#* ]] && continue

        full_path="$target_dir/$file"
        if [ -f "$full_path" ]; then
            concatenate_files "$target_dir" "$full_path" || break
        else
            echo "Warning: File '$file' does not exist. Skipping." >&2
        fi
    done < "$target_dir/$file_list"
else
    echo "Warning: Main file list '$file_list' not found in the project root." >&2
fi

# Process subfolders if -a option is used or specific subfolders are provided
if $include_all || [ -n "$subfolders" ]; then
    if $include_all; then
        subfolder_list=$(find "$target_dir" -type d)
    else
        IFS=',' read -ra subfolder_array <<< "$subfolders"
        subfolder_list="${subfolder_array[*]}"
    fi

    for subfolder in $subfolder_list; do
        full_subfolder_path="$target_dir/$subfolder"
        if [ -d "$full_subfolder_path" ]; then
            echo -e "\n--- Files in $subfolder ---\n" >> "$output_file"
            find "$full_subfolder_path" -type f | while read -r file; do
                if ! should_ignore "$(basename "$file")"; then
                    concatenate_files "$target_dir" "$file" || break
                fi
            done
        else
            echo "Warning: Subfolder '$subfolder' does not exist. Skipping." >&2
        fi
    done
fi

echo "Project analysis completed. Output saved to $output_file"
echo "Total size: $((total_size / 1024)) KB"
