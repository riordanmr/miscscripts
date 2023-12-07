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
# Usage:
# awk -f ~/Documents/GitHub/miscscripts/extractfromwordlist.awk ~/Downloads/eng_news_2020_30K/eng_news_2020_30K-words.txt
# This word list is supposedly sorted in descending order of word
# frequency, which is what I want, because I want to favor common words
# over obscure ones.
# Note: this dataset results in only 2179 words; I may want to switch
# to the larger dataset from the same place.  Note that unfortunately, 
# that dataset has some extremely obscure or non-extant words mixed
# in with relatively common words, possibly the result of typos.
# awk -f ~/Documents/GitHub/miscscripts/extractfromwordlist.awk ~/Downloads/eng_news_2020_100K/eng_news_2020_100K-words.txt
# This one contains 3046 5-letter words.
BEGIN {
    FS = "\t"
}
{
    word = $2
    if(length(word)==5) {
        if(match(word,/[a-z][a-z][a-z][a-z][a-z]/)) {
            count++
            if(length(out)>70) {
                print out
                out = ""
            }
            out = out "\"" word "\", " 
        }
    }
}

END {
    if(length(out)>0) print out
    print count " words" >"/dev/tty"
}
