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
# Note: this dataset results in only 2179 words; I may want to switch
# to the larger dataset from the same place.
BEGIN {
    FS = "\t"
}
{
    word = $2
    if(length(word)==5) {
        if(match(word,/[a-z][a-z][a-z][a-z][a-z]/)) {
            print word
        }
    }
}
