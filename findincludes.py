
# findincludes.py - script to examine a bunch of C source files, and determine
# which files are included, and which macros are defined.
# Mark Riordan with help from GitHub CoPilot  2025-04-15
import os
import sys
import glob
import re

includes_set = set()  # Set to store unique include filenames that are included
defines_set = set()  # Set to store unique macros that are defined

def proc_line(line):
    #print(f"Processing line: {line}")
    # Search for #include directives in the line
    pattern = r'#include\s+"([^"]+)"'   
    match = re.search(pattern, line)
    
    # If a match is found, extract the filename
    if match:
        include_file = match.group(1)  # Return the captured group (the filename)
        if include_file not in includes_set:
            includes_set.add(include_file)
            proc_file(include_file)
        else:
            print(f"Already processed {include_file}")

    # Search for #define directives in the line
    define_pattern = r'#define\s+(\w+)'
    define_match = re.search(define_pattern, line)
    # If a match is found, extract the define name
    if define_match:
        define_name = define_match.group(1)
        if define_name not in defines_set:
            defines_set.add(define_name)
            print(f"Found define: {define_name}")
        else:
            print(f"Already processed define: {define_name}")
    

def proc_file(filename):
    print(f"Processing file {filename}")
    try:
        with open(filename, 'r') as file:
            print(f"Opened file {filename} successfully.") 
            for line in file:
                # Process each line 
                proc_line(line.strip())
        print(f"Done processing {filename}")
    except FileNotFoundError:
        print(f"Error: File '{filename}' not found.")
    except PermissionError:
        print(f"Error: Permission denied to access '{filename}'.")
    except Exception as e:
        print(f"Error: An unexpected error occurred while processing '{filename}': {e}")
    pass

def main():
    # Ensure the correct number of arguments
    # This didn't work because Python autoexpanded cmdline args.
    #if len(sys.argv) != 3:
    #    print("Usage: python script.py <directory> <filemask>")
    #    print(f"You gave {sys.argv} arguments.")
    #    sys.exit(1)

    # Get the directory and file mask from command-line arguments
    #directory = sys.argv[1]
    directory = "."
    #filemask = sys.argv[2]
    filemask = "*.r"

    try:
        # Change to the specified directory
        os.chdir(directory)
    except FileNotFoundError:
        print(f"Error: Directory '{directory}' not found.")
        sys.exit(1)
    except PermissionError:
        print(f"Error: Permission denied to access '{directory}'.")
        sys.exit(1)

    # List all files matching the file mask
    matching_files = glob.glob(filemask)
    if matching_files:
        print("Matching files:")
        for file in matching_files:
            proc_file(file)
    else:
        print(f"No files matching '{filemask}' found in '{directory}'.")

    print("")
    print("All include files:")
    sorted_includes = sorted(includes_set)
    for include_file in sorted_includes:
        print(include_file)

    print("")
    print("All defines:")
    sorted_defines = sorted(defines_set)
    for define_name in sorted_defines:
        print(define_name)

if __name__ == "__main__":
    main()
