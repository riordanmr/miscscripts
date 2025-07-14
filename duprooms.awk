# duprooms.awk - script to massage a column of a spreadsheet
# sample input:
#---
# Front of house
# 
# Patio
# 
# 
#--- Sample output:
# Front of house
# Front of house
# Patio
# Patio
# Patio
#---
# MRR 2025-06-17
# Usage: awk -f /Users/mrr/Documents/GitHub/miscscripts/duprooms.awk  ~/tmp/applewoodrooms.txt > ~/tmp/applewoodroomsdup.txt

{
    # If the line is not empty, print it and store it in 'last'
    if (NF > 0) {
        print $0
        last = $0
    } else {
        # If the line is empty, print the last non-empty line
        print last
    }
}



