#!/usr/bin/awk -f

# AWK script to calculate inches per hour from time and measurement data
# Input format: time1 inches1 time2 inches2
# Example: 19:22 2.125 20:31 3.2
# 
# Mark Riordan and Github Copilot  2025-09-05

{
    # Parse the input fields
    time1 = $1
    inches1 = $2
    time2 = $3
    inches2 = $4
    
    # Convert times from HH:MM format to decimal hours
    split(time1, t1_parts, ":")
    time1_decimal = t1_parts[1] + t1_parts[2]/60
    
    split(time2, t2_parts, ":")
    time2_decimal = t2_parts[1] + t2_parts[2]/60
    
    # Handle case where time2 is on the next day (crosses midnight)
    if (time2_decimal < time1_decimal) {
        time2_decimal += 24
    }
    
    # Calculate time difference in hours
    time_diff = time2_decimal - time1_decimal
    
    # Calculate inches difference
    inches_diff = inches2 - inches1
    
    # Calculate rate (inches per hour)
    if (time_diff > 0) {
        rate = inches_diff / time_diff
        printf "From %s to %s: %.3f inches in %.2f hours = %.3f inches/hour\n", 
               time1, time2, inches_diff, time_diff, rate
    } else {
        print "Error: Invalid time range"
    }
}
