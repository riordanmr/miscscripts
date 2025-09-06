# poolfillsum.awk - script to sum the amount of water added to the pool
# based on the time spent filling and the fill rate in inches per hour.
# Sample input:
# 2025-05-31 19:22 2.125 started filling = 0.87 inches/day
# 2025-05-31 20:31 3.2 stopped filling 
#
# 2025-08-07 Added water for 1.4 hours. 
#
# 2025-08-12 Added water for 40 minutes. And I've been charging, using, and cleaning the Aiper every day since getting it. 
#
# 2025-08-22 Added water for 40 minutes.  
#
# Mark Riordan and GitHub Copilot 2025-09-05
# Usage: awk -f ~/Documents/GitHub/miscscripts/poolfillsum.awk poolfill2.txt

BEGIN {
    ST_BEG = 1
    ST_IN_RANGE = 2
    state = ST_BEG
}
{
    line = $0
    if(NF==0) {
        state = ST_BEG
        next
    }
    if(state == ST_BEG) {
        if(line ~ /started/) {
            time_start = $2
            state = ST_IN_RANGE
        } else if(line ~ /Added water/) {
            # Extract time duration
            if (match($0, /Added water for [0-9.]+ hours/)) {
                # Extract the number from hours
                split($0, words, " ")
                for (i = 1; i <= length(words); i++) {
                    if (words[i] == "for" && i+1 <= length(words)) {
                        hours = words[i+1]
                        total_hours += hours
                        break
                    }
                }
            } else if (match($0, /Added water for [0-9.]+ minutes/)) {
                # Extract the number from minutes
                split($0, words, " ")
                for (i = 1; i <= length(words); i++) {
                    if (words[i] == "for" && i+1 <= length(words)) {
                        minutes = words[i+1]
                        hours = minutes / 60
                        total_hours += hours
                        break
                    }
                }
            } else {
                print "Could not parse time duration in line: " line > "/dev/stderr"
            }
            print hours " hours added from line: " line
        } else {
            print "Unrecognized line: " line > "/dev/stderr"
        }
    } else if(state == ST_IN_RANGE) {
        if(line ~ /stopped/) {
            time_stop = $2
            # Calculate time difference in hours
            split(time_start, t1_parts, ":")
            time1_decimal = t1_parts[1] + t1_parts[2]/60
            
            split(time_stop, t2_parts, ":")
            time2_decimal = t2_parts[1] + t2_parts[2]/60
            
            # Handle case where time_stop is on the next day (crosses midnight)
            if (time2_decimal < time1_decimal) {
                time2_decimal += 24
            }
            
            time_diff = time2_decimal - time1_decimal
            if(time_diff > 0) {
                total_hours += time_diff
                state = ST_BEG
                print time_diff " hours added from filling from " time_start " to " time_stop
            } else {
                print "Error: Invalid time range in line: " line > "/dev/stderr"
                state = ST_BEG
            }
        } else {
            print "Expected 'stopped' line but got: " line > "/dev/stderr"
        }
    }
}

END {
    print "Total hours of filling: " total_hours
    fill_rate = 0.896 # inches per hour
    total_inches = total_hours * fill_rate
    print "Total inches added to pool: " total_inches
}
