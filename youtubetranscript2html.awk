# youtubetranscript2html.awk - script to convert a copied/pasted
# YouTube transcript to a simple HTML file.
# Input looks like:
# 4:00
# you have now maybe to pass something
# 4:01
# maybe to merge on the highway something
#
# output looks like:
# <html>
# ...
# <body>
# <p>
# you have now maybe to pass something
# maybe to merge on the highway something
# </p>
# </body>
# </html>
#
# Usage: awk -f ~/Documents/GitHub/miscscripts/youtubetranscript2html.awk ~/Documents/Motormouth2023GV60Review.txt >~/Documents/Motormouth2023GV60Review.html
# MRR  2025-01-22

BEGIN {
    print "<html>"
    
    print "<head>"
    print "    <style>"
    print "        body {"
    print "            font-family: PT Serif;"
    print "            font-size: 125%;"
    print "        }"
    print "        p {"
    print "             max-width: 35em;"
    print "             /* text-align: justify; */"
    print "        }"
    print "        h2 {"
    print "            font-family: sans-serif;"
    print "            font-size: 125%;"
    print "        }"
    print "    </style>"
    print "</head>"

    print "<body>"
    print "<!-- Generated by youtubetranscript2html.awk -->"
    print "<p>"
}

{
    if (!($0 ~ /^[0-9]/)) {
        # Not a timestamp.
        if( $0 !~ /^$/) {
            # Not a blank line.
            if($0 ~ /^ /) {
                # Line starts with a space, so it is a section header.
                print "</p>"
                print "<h2>" $0 "</h2>"
                print "<p>"
            }  else {
                # Regular line.
                print $0
            }
        }
    }
}

END {
    print "</p>"
    print "</body>"
    print "</html>"
}
