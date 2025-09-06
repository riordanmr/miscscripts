# Create an HTML table from textual input.
# Sample input:
# 2016
# Water softener
# 2017
# Irrigation system
#
# Mark Riordan (and GitHub Copilot)  16 Dec 2025.
# Usage: awk -f /Users/mrr/Documents/GitHub/miscscripts/txt2table.awk ~/tmp/updates.txt >output.html
BEGIN {
    print "<table border=\"1\">"
    print "<tr><th>Year</th><th>Item</th></tr>"
}

{
    if ($0 ~ /^20/) {
        year = $0
        getline
        item = $0
        print "<tr><td>" year "</td><td>" item "</td></tr>"
    }
}

END {
    print "</table>"
}
