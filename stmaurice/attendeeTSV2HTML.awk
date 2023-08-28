# attendeeTSV2HTML.awk - script to create a human-readable list of
# attendees of the class reunion.
# Input is a tab-separated file containing lines like:
# Bryan	Bagdady	
#   or 
# Louann	Cyr	Bobrovetski 
# If 3 names, middle name is maiden name.
# awk -f attendeeTSV2HTML.awk attendees.tsv >attendees.html
# Mark Riordan 2023-08-27

BEGIN {
    FS = "\t"
    print "<html><head>"
    print "<style>"
    print "body {font-family: Verdana; font-size: 24pt; margin: 40pt;}"
    print ".lead {font-family: Verdana; font-size: 14pt;}"
    print ".footnote {font-family: Verdana; font-size: 12pt; font-style: italic;}"
    print "</style>"
    print "<body>"
    print "<p class='lead'>This photo album depicts the classmates who attended the August 2023 "
    print "reunion of the 1970 graduating class of St. Maurice Grade School in Livonia, MI - plus some"
    print "bonus photos at the end."
    print "</p>"
    print "<p class='lead'>Here's a key to the names used in the captions:"
    print "</p>"
    print "<table>"
}

{
    first = $1
    last = $2
    extra = $3
    if(length(extra)==0) {
        full = first " " last
    } else {
        full = first " (" last ") " extra
    }
    print "<tr>"
    print "<td>" first "</td>" "<td> &nbsp;=&nbsp; </td>" "<td>" full "</td>"
    print "</tr>"
}

END {
    print "</table>"
    #print "<p class='footnote'>Sorted by original last name</p>"
    print "</body>"
    print "</html>"
}
