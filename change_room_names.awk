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
# Also, replace any token that starts with a mapped key followed by a space 
# with "@@" plus the rest of the token. mfloorplan will later expand it.
#
# Usage:
# awk -f ~/Documents/GitHub/miscscripts/change_room_names.awk namechange.csv bikeshop1.csv
#
# Mark Riordan and GitHub Copilot  2026-10-23  

BEGIN {
    FS = OFS = ","    # CSV parsing
}

# FNR==NR is true only while reading the first file (namechange.csv);
# this is portable, unlike gawk's ARGIND.
FNR == NR {
    if (NF == 2) {
        map[$1] = $2
    }
    next
}

# Process the data file
{
    # Pass through blank or comment lines unchanged
    if ($0 ~ /^[[:space:]]*$/ || $0 ~ /^#/) {
        print $0
        next
    }
    for (i = 1; i <= NF; i++) {
        # Exact match
        if ($i in map) {
            $i = map[$i]
        } else {
            # Prefix match: field must start with key + space
            for (k in map) {
                plen = length(k)
                # Is field at least one char longer than key, key at start, then space?
                if (length($i) > plen && substr($i, 1, plen) == k && substr($i, plen+1, 1) == " ") {
                    # In that case, replace the token with the special sequence
                    # that mfloorplan will expand to the room name.
                    $i = "@@" substr($i, plen+1)
                    break
                }
            }
        }
    }
    print
}
