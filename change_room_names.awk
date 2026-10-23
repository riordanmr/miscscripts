# change_room_names.awk - script to alter the contents of a CSV
# file, mapping room names.
# This is an AWK script to read a file like bikeshop1.csv and 
# write a similar file in which certain tokens have been replaced.
#
# The input file should be parsed into comma-separated tokens, 
# except that blank lines and lines starting with # should be 
# passed through without change.
#
# A separate file, namechange.csv, should first be read. It contains lines like:
# 
# A0,A1
# A1,A2
# A1.5,A3
#
# This means that all input tokens exactly matching "A0" should be 
# rewritten as "A1". Similarly with "A1" mapped to "A2", etc.
#
# For each CSV input line, write a CSV output line with the token mapping done.
#
# Usage:
# awk -f ~/Documents/GitHub/miscscripts/change_room_names.awk namechange.csv bikeshop1.csv
#
# Mark Riordan and GitHub Copilot  2026-10-23  

BEGIN {
    FS = OFS = ","    # CSV parsing
    # First file (namechange.csv) will be read with ARGIND==1
}

# Read replacements file
ARGIND == 1 && NF == 2 {
    map[$1] = $2
    next
}

# Process data file
ARGIND > 1 {
    # Pass through blank or comment lines
    if ($0 ~ /^[[:space:]]*$/ || $0 ~ /^#/) {
        print $0
        next
    }
    # Replace tokens according to map
    for (i = 1; i <= NF; i++) {
        if ($i in map) $i = map[$i]
    }
    print
}