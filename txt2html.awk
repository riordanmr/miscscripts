# txt2html.awk - script to convert text to HTML.
# Simply adds <p> and </p> to regions of text delimited
# by blank lines.
# Also, if a line ends with a hyphen, it is concatenated
# with the next line, with the hyphen removed.
# Usage: awk -f /Users/mrr/Documents/GitHub/miscscripts/txt2html.awk blameless.txt >blameless.html
BEGIN {
    print "<!DOCTYPE html>"
    print "<html>"
    print "<head>"
    print "  <meta charset=\"UTF-8\">"
    print "</head>"
    print "<body>"
    print "<p>"
}
{
    line = $0
    if(every) {
        print "<p>" line "</p>"
    } else if(0==length(line)) {
        if(length(prevline) > 0) {
            print prevline
            prevline = ""
        }
        if(NR > 1) {
            print "</p>"
        }
        print "<p>"
    } else {
        if(bContinue) {
            line = prevline line
            prevline = ""
            bContinue = 0
        }
        if(substr(line, length(line), 1) == "-") {
            bContinue = 1
            prevline = substr(line, 1, length(line)-1)
        } else {
            print line
            prevline = ""
        }
    }
}
END {
    print "</p>"
    print "</body>"
    print "</html>"
}
