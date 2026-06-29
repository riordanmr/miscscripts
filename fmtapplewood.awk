# fmtapplewood.awk - script to format text from the Applewood
# neighborhood spreadsheet. 
# Input consists of TSV lines like:
# Brooks	Bob	drbnme@gmail.com	608-833-9241	6941
# Brooks	Mary	drbnme2@gmail.com	608-833-9241	6941
#
# Output consists of collapsed and reformatted lines containing a subset
# of the information. In particular, email addresses are omitted.
# The goal is to compact the info so it can be printed all on one page.
#
# Mark Riordan  25-28 June 2026 and Qwen 3.6.
#
# awk -f /Users/mrr/Documents/GitHub/miscscripts/fmtapplewood.awk applewood-by-addr.tsv
#
# Here's the prompt I used to Qwen 3.6:
# write an AWK script to read a file containing names, phone numbers, 
# and street addresses, and output a digested version of the information. 
# The input file is in TSV format and consists of lines with the fields: 
# lastname, firstname, email, phone, housenumber. The file is already sorted by 
# housenumber.
# Although there may be multiple persons per housenumber, output only 1 line 
# per housenumber. On that output line, Include the first name of each person. 
# If there are multiple people in the same house with the same last name, 
# mention their lastname only one, separating first names with "/". 
# If there are different lastnames in the house, include firstname lastname for each 
# person, separated by ",". If there are different phone numbers, place the phone 
# number in parentheses after each person's name, otherwise place the phone number 
# after all names.
# (I gave sample input and expected output to illustrate the formatting rules.)

# BEGIN {
#     FS = "\t"
# }

# {
#     lastname = $1
#     firstname = $2
#     email = $3
#     phone = $4
#     housenum = $5


# }

#!/usr/bin/awk -f
BEGIN { FS = OFS = "\t"; cnt = 0; prev_house = "" }

{
    # Remove trailing carriage returns (Windows line endings) and trim whitespace
    gsub(/\r$/, "", $0)
    gsub(/^[ \t]+|[ \t]+$/, "", $1)
    gsub(/^[ \t]+|[ \t]+$/, "", $2)
    gsub(/^[ \t]+|[ \t]+$/, "", $4)
    gsub(/^[ \t]+|[ \t]+$/, "", $5)

    # Normalize missing or placeholder phone numbers to empty string
    if ($4 == "" || $4 == "no-phone") $4 = ""

    house = $5
    
    # When house number changes, process and print the buffered records
    if (house != prev_house && prev_house != "") {
        process(prev_house, cnt)
        delete lasts; delete firsts; delete phones
        cnt = 0
    }

    prev_house = house
    cnt++
    lasts[cnt] = $1
    firsts[cnt] = $2
    phones[cnt] = $4
}

END { if (cnt > 0) process(prev_house, cnt) }

function process(hnum, n,    i, same_last, common_phone, out_str) {
    # 1. Check if all lastnames in this house are identical
    same_last = 1
    for (i = 2; i <= n; i++) {
        if (lasts[i] != lasts[1]) same_last = 0
    }

    # 2. Determine phone consistency (ignore empty phones)
    common_phone = ""
    for (i = 1; i <= n; i++) {
        if (phones[i] == "") continue
        if (common_phone == "") common_phone = phones[i]
        else if (phones[i] != common_phone) { common_phone = "DIFFERENT"; break }
    }

    out_str = hnum

    if (same_last) {
        # Rule: Same lastname -> firstname1/firstname2... lastname [phone]
        out_str = out_str " "
        for (i = 1; i <= n; i++) {
            if (i > 1) out_str = out_str "/"
            out_str = out_str firsts[i]
        }
        out_str = out_str " " lasts[1]

        if (common_phone != "" && common_phone != "DIFFERENT") {
            out_str = out_str " " common_phone
        } else if (common_phone == "DIFFERENT") {
            # Phones differ -> append (phone) after each firstname, then lastname
            out_str = hnum " "
            for (i = 1; i <= n; i++) {
                if (i > 1) out_str = out_str "/"
                out_str = out_str firsts[i]
                if (phones[i] != "") out_str = out_str " (" phones[i] ")"
            }
            out_str = out_str " " lasts[1]
        }
    } else {
        # Rule: Different lastnames -> firstname lastname, separated by ,
        out_str = out_str " "
        for (i = 1; i <= n; i++) {
            if (i > 1) out_str = out_str ", "
            out_str = out_str firsts[i] " " lasts[i]
            if (phones[i] != "") out_str = out_str " (" phones[i] ")"
        }
    }

    print out_str
}
