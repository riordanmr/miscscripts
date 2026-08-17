# mp4names2html.awk - script to convert a list of mp4 file names 
# into an HTML list with links to the files.
# Mark Riordan and GitHub Copilot   16-AUG-2026 
#
# awk -f ~/Documents/GitHub/miscscripts/mp4names2html.awk fileson60bits.txt > fileson60bits.html
{
    # Extract base name (label) and extension
    n = match($0, /\.[^\.]+$/)
    if (n > 0) {
        label = substr($0, 1, n-1)
        ext = tolower(substr($0, n+1))
    } else {
        label = $0
        ext = ""
    }

    if (ext == "mp4") {
        tag = "Video"
    } else if (ext == "pdf") {
        tag = "PDF"
    } else {
        tag = ext
    }

    printf("<li>%s <a href=\"%s\">%s</a></li>\n", label, $0, tag)
}
