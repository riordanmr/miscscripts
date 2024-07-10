# extractfromwordlist.awk - script to extract 5-letter words
# from a longer list of words.
# The input is a file from https://wortschatz.uni-leipzig.de/en/download/English
# whose lines look like:
# 169	He	806
# The 3 fields are tab separated. Only field 2 is of interest.
# We extract only words that:
# - Are exactly 5 characters long
# - Contain only lowercase letters
#
# This is for a program to emulate the NY Times game Wordle.
# Mark Riordan  2023-12-06
# 
# I'm using this file: ~/Downloads/eng_news_2020_30K/eng_news_2020_30K-words.txt
# This word list is supposedly sorted in descending order of word
# frequency, which is what I want, because I want to favor common words
# over obscure ones.  Note that unfortunately, 
# this dataset has some extremely obscure or non-extant words mixed
# in with relatively common words, possibly the result of typos.
#
# There are two modes of usage:
# awk -f ~/Documents/GitHub/miscscripts/extractfromwordlist.awk ~/Downloads/eng_news_2020_100K/eng_news_2020_100K-words.txt >words5char.txt
# awk -f ~/Documents/GitHub/miscscripts/extractfromwordlist.awk ~/Downloads/eng_news_2020_1M/eng_news_2020_1M-words.txt >words5char.txt
# This creates an output file with 5-char words. This particular file contains 3046 5-letter words.
#
# awk -f ~/Documents/GitHub/miscscripts/extractfromwordlist.awk -v source=1 words5char.txt >words5char.go
# This creates a Go source file with the words. You can edit words5char.txt between the first
# and second type of usage.

BEGIN {
    FS = "\t"
    if(source) {
        print "package main"
        print "// This list of known words comes from https://wortschatz.uni-leipzig.de/en/download/English"
        print "// It was converted from its original format by extractfromwordlist.awk."
        print "var AllWords = []string {"
    }
}
{
    word = $2
    if(source) word = $1
    if(length(word)==5) {
        if(match(word,/[a-z][a-z][a-z][a-z][a-z]/)) {
            count++
            if(source) {
                if(length(out)>70) {
                    print out
                    out = ""
                }
                out = out "\"" word "\", " 
            } else {
                print word
            }
        }
    }
}

END {
    if(source) {
        if(length(out)>0) print out
        print "}"
    }
    print count " words" >"/dev/tty"
}
