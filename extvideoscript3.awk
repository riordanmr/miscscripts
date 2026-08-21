# extvideoscript3.awk - given a script for a video, extract the
# portions of the script for different speakers and output them to separate files.
#
# Sample input:
# SCENE 1 — CLAIRE, SOLO SHOT (Static frame. Neutral background. CLAIRE speaks directly to camera.)
# 
# CLAIRE: For a long time, I thought I only had one feeling. Happy, angry, ashamed, scared — it all came out the same way. I cried.
#
# I'd cry when I was furious. I'd cry when something good happened. My sponsor called it "bundling." Every feeling gets wrapped into one big knot, and you can't tell what's actually inside it anymore.
# 
# SCENE 2 — BOB, SOLO SHOT (Different static frame, same visual language — simple background, direct address.)
#
# BOB: I didn't bundle mine. Mine just went numb. Somebody would ask, "How does that make you feel?" and I'd genuinely have nothing. Not "I don't want to say." Nothing there to find.

# Usage: awk -f ~/Documents/GitHub/miscscripts/extvideoscript3.awk df-script.txt
# Mark Riordan  20-AUG-2026

BEGIN {
    outfile = ""
}

function startswith(str, prefix) {
    return substr(str, 1, length(prefix)) == prefix
}

function ends_with_one_of(str, suffixes) {
    lastch = substr(str, length(str), 1)
    return index(suffixes, lastch) > 0
}

function print_to_file(line, outfile) {
    if(length(outfile) > 0) {
        if(outfile in open_files) {
            print line >> outfile
        } else {
            open_files[outfile] = 1
            print line > outfile
        }
    }
}

{
    line = $0
    if(startswith(line, "SCENE")) {
        # Ignore scene titles.
        print "Ignoring scene title: " line > "/dev/stderr"
    } else if(match(line, /^[A-Z]+:/)) {
        # This line starts with a speaker name.
        speaker = substr(line, 1, RLENGTH-1) 
        outfile = speaker ".txt"
        #print "Line starts with speaker title; speaker=" speaker > "/dev/stderr"
        print_to_file("...", outfile)
        speech = substr(line, RLENGTH+2)
        print_to_file(speech, outfile)
    } else {
        # This line is a spoken line.
        print_to_file(line, outfile)
    }
}
