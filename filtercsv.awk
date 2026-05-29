# filtercsv.awk - Filter CSV rows by inclusive date range on column 1.
#
# Required variables:
#   -v startdate=YYYY-MM-DD
#   -v enddate=YYYY-MM-DD
#
# Usage:
#   awk -v startdate=2026-05-01 -v enddate=2026-05-31 -f filtercsv.awk input.csv
# 
# Mark Riordan (and GitHub Copilot) 2026-05-28

BEGIN {
    if (startdate == "" || enddate == "") {
        print "filtercsv.awk: missing required -v startdate=YYYY-MM-DD and/or -v enddate=YYYY-MM-DD" > "/dev/stderr"
        exit 1
    }

    if (startdate !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ || enddate !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) {
        print "filtercsv.awk: startdate/enddate must be YYYY-MM-DD" > "/dev/stderr"
        exit 1
    }

    if (startdate > enddate) {
        print "filtercsv.awk: startdate must be <= enddate" > "/dev/stderr"
        exit 1
    }
}

# Parse one CSV line into arr[1..n]. Supports quoted fields and escaped quotes.
function parse_csv_line(line, arr,    i, c, in_quote, field, n, nextc) {
    delete arr
    in_quote = 0
    field = ""
    n = 0

    for (i = 1; i <= length(line); i++) {
        c = substr(line, i, 1)

        if (in_quote) {
            if (c == "\"") {
                nextc = substr(line, i + 1, 1)
                if (nextc == "\"") {
                    field = field "\""
                    i++
                } else {
                    in_quote = 0
                }
            } else {
                field = field c
            }
        } else {
            if (c == ",") {
                arr[++n] = field
                field = ""
            } else if (c == "\"") {
                in_quote = 1
            } else {
                field = field c
            }
        }
    }

    arr[++n] = field
    return n
}

NR == 1 {
    # Preserve header.
    print
    next
}

{
    sub(/\r$/, "", $0)
    n = parse_csv_line($0, row)
    date = (n >= 1 ? row[1] : "")

    if (date >= startdate && date <= enddate) {
        print
    }
}
