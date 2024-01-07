# extractlibrarypulls.awk - script to read Mark's Activity Logs and
# extract records of how many items he pulled for holds on what dates.
# Input records look like:
# 2022-01-15  Processed 121 holds at the library.  More StarryAI images, as I have been doing almost every day since Jan 4.  Finished Ocean's 11 with Tam. 
# or 
# 2023-07-22  Pulled holds at library; 99 items. Lots of missing items. Tried to find white hairbrush and Tam’s Cribbage game, both missing since HomeExchange people left, plus they took a key, arrgh. Finished watching Top Gun: Maverick. Officially gave up on Julia; it doesn’t reasonably compile to executables. 
# Output looks like:
# 2023-07-2\t99
# Usage: awk -f /Users/mrr/Documents/GitHub/miscscripts/extractlibrarypulls.awk /Users/mrr/Documents/activitylog.txt >pulls.tsv
# Mark Riordan 06-JAN-2024
{
    line = $0
    # AWK doesn't seem to recognize \d for digits.
    if(match(line,/[0-9]+ (items|holds)/)) {
        date = substr(line,1,10)
        # We got a match. AWK doesn't implement match groups, so we are going to have 
        # to extract the count from the matched region.
        matched = substr(line,RSTART,RLENGTH)
        match(matched,/^[0-9]+/)
        count = substr(matched,RSTART,RLENGTH)
        print date "\t" count
    }
}
