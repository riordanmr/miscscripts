# extvideoscript.awk - given a script for a video, extract the
# portions of the script for different speakers and output them to separate files.
#
# Sample input:
# Scene 1 — Marianne
# MARIANNE:
# Many adult children become disconnected from their bodies without realizing it.
# We may function normally. We work, have relationships, and take care of our responsibilities. But inside, we may feel numb or disconnected from what is happening in our own bodies.
# 
# Scene 2 — Suwanna
# SUWANNA:
#
# Usage: awk -f ~/Documents/GitHub/miscscripts/extvideoscript2.awk scriptall.txt
# Mark Riordan  14-AUG-2026

BEGIN {

}

function startswith(str, prefix) {
    return substr(str, 1, length(prefix)) == prefix
}

function ends_with_one_of(str, suffixes) {
    lastch = substr(str, length(str), 1)
    return index(suffixes, lastch) > 0
}

function print_to_file(line, outfile) {
    if(outfile in open_files) {
        print line >> outfile
    } else {
        open_files[outfile] = 1
        print line > outfile
    }
}

{
    line = $0
    if(startswith(line, "Scene")) {
        # Ignore scene titles.
        print "Ignoring scene title: " line > "/dev/stderr"
    } else if(toupper(line) == line) {
        # This line is a speaker name.
        speaker = line
        if(ends_with_one_of(speaker, ":")) {
            # Remove the trailing colon if present
            speaker = substr(speaker, 1, length(speaker) - 1)
        }
        outfile = speaker ".txt"
        print_to_file("...", outfile)
    } else if (startswith(line, "(")) {
        # Ignore stage directions
        print "Ignoring stage direction: " line > "/dev/stderr"
    } else {
        # This line is a spoken line.
        print_to_file(line, outfile)
    }
}
