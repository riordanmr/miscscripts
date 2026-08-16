#!/usr/bin/env python3
# Script to rename Venmo statement files.  
# E.g. VenmoStatement_August_2025.csv -> VenmoStatement_2025_08.csv
#
# Written by Github Copilot under the direction of Mark Riordan  2025-08-24

import re
import os

def generate_mv_commands(filenames):
    """Generate Unix mv commands to rename Venmo statement files"""
    
    # Month name to number mapping
    months = {
        'January': '01', 'February': '02', 'March': '03', 'April': '04',
        'May': '05', 'June': '06', 'July': '07', 'August': '08',
        'September': '09', 'October': '10', 'November': '11', 'December': '12'
    }
    
    # Pattern to match VenmoStatement files
    pattern = r'VenmoStatement_(\w+)_(\d{4})\.csv'
    
    mv_commands = []
    
    for filename in filenames:
        match = re.match(pattern, filename.strip())
        if match:
            month_name = match.group(1)
            year = match.group(2)
            
            if month_name in months:
                month_num = months[month_name]
                new_filename = f"VenmoStatement_{year}_{month_num}.csv"
                mv_command = f"mv '{filename}' '{new_filename}'"
                mv_commands.append(mv_command)
                print(mv_command)
            else:
                print(f"Warning: Unknown month '{month_name}' in file '{filename}'")
        else:
            print(f"Warning: File '{filename}' doesn't match expected pattern")
    
    return mv_commands

def main():
    # Option 1: Read filenames from command line arguments
    import sys
    if len(sys.argv) > 1:
        filenames = sys.argv[1:]
        print("# Generated mv commands:")
        generate_mv_commands(filenames)
        return
    
    # Option 2: Read from current directory
    print("# Scanning current directory for VenmoStatement files...")
    current_files = [f for f in os.listdir('.') if f.startswith('VenmoStatement_') and f.endswith('.csv')]
    
    if current_files:
        print("# Found files:")
        for f in current_files:
            print(f"#   {f}")
        print("\n# Generated mv commands:")
        generate_mv_commands(current_files)
    else:
        print("# No VenmoStatement files found in current directory")
        print("# Usage examples:")
        print("#   python3 rename_venmo.py VenmoStatement_August_2025.csv VenmoStatement_July_2025.csv")
        print("#   python3 rename_venmo.py VenmoStatement_*.csv")
        
        # Option 3: Use your example data
        print("\n# Example with your sample files:")
        sample_files = [
            "VenmoStatement_August_2025.csv",
            "VenmoStatement_July_2025.csv", 
            "VenmoStatement_June_2025.csv",
            "VenmoStatement_May_2025.csv",
            "VenmoStatement_April_2025.csv"
        ]
        generate_mv_commands(sample_files)

if __name__ == "__main__":
    main()