# tsv2bio.awk - script to take a list of student names and create
# HTML for the biographies / anecdotes page of the St. Maurice website.
# This is to create a mockup; once I like the mockup, I'll probably 
# write a more sophisticated Python script to create the final page directly
# from the Google spreadsheet. 
# Mark Riordan   2023-08-08
# awk -f /Users/mrr/Documents/GitHub/miscscripts/stmaurice/tsv2bio.awk studentnames.tsv >web/partial.html
# Input: Tab-separated lines like:
# Marisa	Paparelli	Farhat
# or
# Mark	Riordan	
BEGIN {
    FS = "\t"
}
{
    firstname = $1
    shortfirst = firstname
    idx = index(shortfirst, " ")
    if(idx > 0) shortfirst = substr(shortfirst, 1, idx-1)
    lastname = $2
    extraname = $3
    origname = firstname " " lastname
    fullname = origname
    if(length(extraname > 0)) {
        fullname = fullname " " extraname
    }
    photoname = shortfirst lastname ".jpg"
    divname = shortfirst lastname
    bio = "At one point, there was a fish tank in the corridor near the bathrooms. Some genius - I don't know who - posed the question: would it be possible to use the fish tank to get a painful electric shock? Several of us proceeded to find out by making a chain of kids holding hands, linking the fish tank (with its electric water pump) to a drinking fountain (with its ground to neutral). I didn't think it was a great idea, but I participated anyway. We found that the answer was Yes."
    if(useTable) {
        print "  <tr>"
        print "    <td class='stuname'>" fullname "</td>"
        print "    <td><a href='images/vintage/" photoname "'><img src=\"images/vintage/" photoname "\" height='200'></a></td>"
        print "    <td></td>"
        print "    <td class='stubio'>" bio "</td>" 
        print "  </tr>"
    } else {
        print "<div id='" divname "'>"
        print "  <table>"
        print "    <tr><td class='stuname noborder'>" fullname "</td>"
        print "    <td class='noborder'><a href='images/vintage/" photoname "'><img src=\"images/vintage/" photoname "\" height='200'></a></td>"
        print "    <td class='noborder'><a href='images/recent/" photoname "'><img src=\"images/recent/" photoname "\" height='200'></a></td></tr>"
        print "  </table>"
        print "  <p>" bio "</p>"
        print "  <hr/>"
        print "</div>"
    } 
}
