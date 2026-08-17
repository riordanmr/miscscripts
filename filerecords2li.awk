# filerecords2li.awk - script to convert a list of file names 
# into an HTML list with links to the files.
# Mark Riordan and GitHub Copilot   16-AUG-2026 
# 
# Sample input:
# ACAFeelDifferentFromOtherPeople.mp4|ACA Feel Different From Other People|Video
# ACA Super-responsible p1.pdf|ACA Super-Responsible p1|PDF
# 
# Usage: awk -f ~/Documents/GitHub/miscscripts/filerecords2li.awk files.bsv > files.html
BEGIN { FS="\\|"; OFS="" }
{
    filename = $1
    label = $2
    type = $3

    # Trim spaces
    sub(/^[ \t]+/, "", filename); sub(/[ \t]+$/, "", filename)
    sub(/^[ \t]+/, "", label);    sub(/[ \t]+$/, "", label)
    sub(/^[ \t]+/, "", type);     sub(/[ \t]+$/, "", type)

    if (tolower(type) == "video") {
        # JavaScript will handle .playvid
        printf("<li>%s <a class=\"playvid\" data-src=\"%s\">%s</a></li>\n", label, filename, type)
    } else {
        printf("<li>%s <a href=\"%s\">%s</a></li>\n", label, filename, type)
    }
}
