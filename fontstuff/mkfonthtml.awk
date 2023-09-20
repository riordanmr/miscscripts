# mkfonthtml.awk - create HTML to show font specimens, given an input file
# containing font names.
# MRR  2023-09-18
#
# awk -f mkfonthtml.awk fontnames.txt >fonts.html
BEGIN {
    print "<html>"
    print "<head>"
    print "    <title>macOS fonts</title>"
    print "    <meta charset=\"UTF-8\">"
    print "<style>"
    print "  p {margin: 1px;}"
    print "</style>"
    print "</head>"
    print "<body>"
}

{
    fontname = $0
    bShow = 1
    if(substr(fontname,1,1)==".") {
        # font names beginning with . seem to be ignored by HTML.
        bShow = 0
    } else if(substr(fontname,1,9)=="Noto Sans") {
        # Allow only one Noto Sans - there are so many of them
        bShow = 0
        if(fontname == "Noto Sans Gothic") {
            bShow = 1
        }
    }
    if(bShow) {
        print "<p style='font-family: " fontname "'>McKee Park - Saturday - 15th Annual - Home Run - McKee Park - Memorial Walk - " fontname "</p>" 
    }
}

END {
    print "</body>"
    print "</html>"
}
