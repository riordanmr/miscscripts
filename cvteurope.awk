# cvteurope.awk - Convert credit-card CSV to a shared Europe-format CSV.
#
# Current supported sources:
#   -v src=fidelity   (Fidelity VISA export format)
#   -v src=uwcu       (UWCU export format)
#
# Usage:
#   awk -v src=fidelity -f cvteurope.awk input.csv > output.csv
#
# awk -f ~/Documents/GitHub/miscscripts/cvteurope.awk -v src=fidelity 2026-05FidelityVISA.csv >2026europefidelity.csv
# awk -f ~/Documents/GitHub/miscscripts/cvteurope.awk -v src=uwcu 2026-05UWCU.csv >2026europeuwcu.csv
#
# Mark Riordan (and GitHub Copilot) 2026-05-28

BEGIN {
    if (src == "") {
        print "cvteurope.awk: missing required -v src=<value>" > "/dev/stderr"
        exit 1
    }

    if (src != "fidelity" && src != "uwcu") {
        print "cvteurope.awk: unsupported src=\"" src "\" (expected \"fidelity\" or \"uwcu\")" > "/dev/stderr"
        exit 1
    }

    print "date,amount_shared,currency_shared,amount_mark,currency_mark,amount_tam,currency_tam,description,inst_description,notes"
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

# Quote a field for CSV output.
function csv_quote(s,    t) {
    t = s
    gsub(/\"/, "\"\"", t)
    return "\"" t "\""
}

function to_iso_date(s,    part, mm, dd, yyyy) {
    split(s, part, "/")
    if (length(part) == 3) {
        mm = part[1] + 0
        dd = part[2] + 0
        yyyy = part[3] + 0
        return sprintf("%04d-%02d-%02d", yyyy, mm, dd)
    }
    return s
}

function normalize_and_invert_amount(s,    t, neg) {
    t = s
    gsub(/\r/, "", t)
    gsub(/[ $,]/, "", t)

    neg = 0
    if (t ~ /^\(.*\)$/) {
        neg = 1
        sub(/^\(/, "", t)
        sub(/\)$/, "", t)
    }

    if (t == "") return ""

    if (neg) t = "-" t

    return sprintf("%.2f", -(t + 0))
}

NR == 1 {
    sub(/\r$/, "", $0)
    n = parse_csv_line($0, hdr)

    if (src == "fidelity") {
        for (i = 1; i <= n; i++) {
            if (hdr[i] == "Date") idx_date = i
            else if (hdr[i] == "Amount") idx_amount = i
            else if(hdr[i] == "Name") idx_inst_description = i
        }
    } else if(src == "uwcu") {
        for (i = 1; i <= n; i++) {
            if (hdr[i] == "AccountNumber") idx_acct = i
            else if (hdr[i] == "Posted Date") idx_posted_date = i
            else if (hdr[i] == "Amount") idx_amount = i
            else if (hdr[i] == "Description") idx_inst_description = i
        }
    }

    if (src == "fidelity") {
        if (!idx_date || !idx_amount || !idx_inst_description) {
            print "cvteurope.awk: fidelity header missing required columns (Date, Amount, Name)" > "/dev/stderr"
            exit 1
        }
    } else if(src == "uwcu") {
        if (!idx_acct || !idx_posted_date || !idx_amount || !idx_inst_description) {
            print "cvteurope.awk: uwcu header missing required columns (AccountNumber, Posted Date, Amount, Description)" > "/dev/stderr"
            exit 1
        }
    }

    next
}

{
    sub(/\r$/, "", $0)
    n = parse_csv_line($0, row)

    date = ""
    amount_shared = ""
    amount_mark = ""
    amount_tam = ""
    description = ""
    inst_description = ""

    if(src == "fidelity") {
        date = (idx_date <= n ? row[idx_date] : "")
        amount_mark = (idx_amount <= n ? normalize_and_invert_amount(row[idx_amount]) : "")
        inst_description = (idx_inst_description <= n ? row[idx_inst_description] : "")
    } else if(src == "uwcu") {
        acct = (idx_acct <= n ? row[idx_acct] : "")
        date = (idx_posted_date <= n ? to_iso_date(row[idx_posted_date]) : "")
        inst_description = (idx_inst_description <= n ? row[idx_inst_description] : "")
        amt = (idx_amount <= n ? normalize_and_invert_amount(row[idx_amount]) : "")

        if (acct == "0098828601") {
            amount_shared = amt
        } else if (acct == "0098828604") {
            amount_mark = amt
        }
    }

    print csv_quote(date) "," \
          csv_quote(amount_shared) "," \
          csv_quote("u") "," \
          csv_quote(amount_mark) "," \
          csv_quote("u") "," \
          csv_quote(amount_tam) "," \
          csv_quote("u") "," \
          csv_quote(description) "," \
          csv_quote(inst_description) "," \
          csv_quote("")
}