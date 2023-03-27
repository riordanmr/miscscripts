# convbsdates.awk - Script to convert dates.
# Input is shorthand dates like "4,17".
# Output is full date strings like "2022-04-17".
# The purpose is to allow me to enter many dates in an abbreviated
# format, then later fill in the full date string.
# This is for the Sedona Bookstore daily sales spreadsheet.
#
# Mark Riordan   2023-03-09
#
# awk -f convbsdates.awk <j

BEGIN {
    FS = ","
}

{
    if(NF==2) {
        month = $1
        day = $2
        print sprintf("%-4.4d-%-2.2d-%-2.2d", 2022, month, day)
    } else if(0==NF) {
        print ""
    } else {
        print "Unexpected input! NF=" NF
    }
}
