# email2csv.awk - script to convert a list of email addresses
# copied from a Google Sheet to CSV format suitable for pasting
# into GMail.
# Mark Riordan  2024-04-22
# Usage: awk -f /Users/mrr/Documents/GitHub/miscscripts/email2csv.awk bookdealers.txt 
{
    # Remove leading and trailing whitespace
    gsub(/^[ \t]+|[ \t]+$/, "")
    # Replace any internal whitespace with a comma
    gsub(/[ \t]+/, ",")
    # Print the result
    if(length($0) > 0) print
}
