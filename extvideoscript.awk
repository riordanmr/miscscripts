# extvideoscript.awk - given a script for a video, extract the
# portions of the script for different speakers and output them to separate files.
#
# Sample input:
# Childhood
# ELLIS
# What was fun like in your family?
# (Donna laughs softly.)
# DONNA
# Fun?
# That's almost a strange question.
#
# Usage: awk -f ~/Documents/GitHub/miscscripts/extvideoscript.awk scriptall.txt
# Mark Riordan  03-AUG-2026

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
    if(toupper(line) == line) {
        # This line is a speaker name.
        speaker = line
        outfile = speaker ".txt"
        print_to_file("...", outfile)
    } else if (startswith(line, "(")) {
        # Ignore stage directions
        print "Ignoring stage direction: " line > "/dev/stderr"
    } else {
        if(NR == 1 && !ends_with_one_of(line, ".?!")) {
            # ignore section title.
            print "Ignoring section title: " line > "/dev/stderr"
        } else {
            print_to_file(line, outfile)
        }
    }
}
