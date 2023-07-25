# txt2html.awk - script to convert text to HTML.
# Simply adds <p> and </p> to regions of text delimited
# by blank lines.
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
        if(NR > 1) {
            print "</p>"
        }
        print "<p>"
    } else {
        print line
    }
}
END {
    print "</p>"
    print "</body>"
    print "</html>"
}
