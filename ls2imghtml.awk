# ls2imghtml.awk - script to create HTLM to display images from a list of files.
# Mark Riordan - 2024-10-08
# Usage: ls dining | awk -f ~/Documents/GitHub/miscscripts/ls2imghtml.awk > img.html
# Input: list of image files, one per line
# Output: HTML to display images 
BEGIN {
    # print "<html>"
    # print "<head>"
    # print "<title>Images</title>"
    # print "</head>"
    # print "<body>"
}
{
    print "<img src=\"" $0 "\">"
}
END {
    # print "</body>"
    # print "</html>"
}
