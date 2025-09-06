# tsv2email.awk - Create list of email addresses from TSV input
# Input is TSV lines like:
# Firstname	Ignore  Ignore	Email	Lastname
# Tom	Scheuher		Tscheuher@yahoo.com	Scheuher
# Usage: awk -f tsv2email.awk studentswithemail.tsv >studentswithemail.txt
# Mark Riordan  2025-07-14
BEGIN {
    FS = "\t";  # Set field separator to tab
}

{
    if(list != "") {
        list = list ", "  # Append separator if list is not empty
    }
    pemail = $1 " " $5 " <" $4 ">"  # Format email address
    list = list pemail  # Append formatted email to the list
}
END {
    print list
}
