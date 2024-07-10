# plus2html.awk - script to convert an OCRed text file to HTML.
# This is specific to a particular document:
# THE PLUS SYSTEMS PROGRAMMING LANGUAGE
# Mark Riordan, 10-JUL-2024
# Usage: awk -f /Users/mrr/Documents/GitHub/miscscripts/plus2html.awk /Users/mrr/Downloads/PLUS-CIPS-1984.ocr.txt >/Users/mrr/Downloads/PLUS-programming.html

BEGIN {
    print "<!DOCTYPE html>"
    print "<html>"
    print "<head>"
    print "<meta charset=\"UTF-8\">"
    print "<!-- Generated by MRR's plus2html.awk -->"
    print "<title>The PLUS Systems Programming Language</title>"
    print "<style>"
    print "body {font-family: PT Serif, Lora, serif;}"
    print "</style>"
    print "</head>"
    print "<body>"
    print "<h1>THE PLUS SYSTEMS PROGRAMMING LANGUAGE</h1>"

    bInCodeBlock = 0

    codeSpacingText = "   "
}

function startsWith(line, searchFor) {
    return substr(line, 1, length(searchFor)) == searchFor
}

function trim(line) {
    sub(/^[ \t]+/, "", line)
    sub(/[ \t]+$/, "", line)
    return line
}

function wrap(line) {
    # Define the maximum line length
    max_length = 72
    # Initialize an empty string to hold the wrapped text
    wrapped_text = ""
    # Initialize a variable to hold the current line being constructed
    current_line = ""

    # Split the input line into words based on spaces
    n = split(line, words, " ")

    # Iterate through each word
    for (i = 1; i <= n; i++) {
        # Check if adding the next word exceeds the max line length
        if (length(current_line) + length(words[i]) <= max_length) {
            # If it doesn't exceed, add the word to the current line
            # Check if the current line is empty to avoid adding an unnecessary space at the beginning
            if (current_line != "") {
                current_line = current_line " " words[i]
            } else {
                current_line = words[i]
            }
        } else {
            # If it exceeds, add the current line to the wrapped text and start a new line with the current word
            wrapped_text = wrapped_text current_line "\n"
            current_line = words[i]
        }
    }
    # Add the last line to the wrapped text
    wrapped_text = wrapped_text current_line

    # Return the wrapped text
    return wrapped_text
}

{
    gsub(/&/, "&amp;")
    gsub(/</, "&lt;")
    gsub(/>/, "&gt;")
    #gsub(/"/, "&quot;")
    #gsub(/'/, "&#39;")

    line = $0

    if(startsWith(line, "!h2")) {
        sub(/^!h2 /, "", line)
        print "<h2>" line "</h2>"
    } else if(startsWith(line, "!h3")) {
        sub(/^!h3 /, "", line)
        print "<h3>" line "</h3>"
    } else if(startsWith(line, "!cb")) {
        # Begin code block
        bInCodeBlock = 1
        out = "<pre><code>"
        sub(/^!cb /, "", line)
        out = out codeSpacingText trim(line)
        print out
    } else if(startsWith(line, "!ce")) {
        # End code block
        bInCodeBlock = 0
        out = "</code></pre>"
        print out
    } else if(bInCodeBlock) {
        out = codeSpacingText trim(line)
        print out
    } else {
        print "<p>" wrap(trim(line)) "</p>"
    }
}

END {
    print "</body>"
    print "</html>"
}
