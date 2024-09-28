# calcpropane.awk - script to summarize propane usage.
# Usage: awk -f ~/Documents/GitHub/miscscripts/calcpropane.awk ~/Downloads/PropaneLevels.tsv
# Input: PropaneLevels.tsv - tab-separated values of propane usage, such as:
# e.g.:
# 2021-03-01      82      Filled today.  254.9 gal @ 3.159 + fees and taxes = $908.73     

BEGIN {
    FS = "\t"
}

# Function to calculate the fractional number of years between two dates
function years_between(date1, date2) {
    split(date1, d1, "-")
    split(date2, d2, "-")
    
    year1 = d1[1]
    year2 = d2[1]
    
    month1 = d1[2]
    month2 = d2[2]
    
    day1 = d1[3]
    day2 = d2[3]
    
    # Calculate the difference in years
    year_diff = year2 - year1
    
    # Calculate the difference in months and days
    month_diff = month2 - month1
    day_diff = day2 - day1
    
    # Adjust the year difference based on months and days
    fractional_year = year_diff + (month_diff / 12) + (day_diff / 365.25)
    
    return fractional_year
}

/Filled today/ {
    #print $0
    date = $1
    if(startdate == "") {
        startdate = date
        next
    }

    gallons = 0
    cost = 0

    # Split the last field to extract gallons and cost.
    numfields = split($3, a, " ")
    for(j = 1; j <= numfields; j++) {
        if(a[j] == "gal") {
            gallons = a[j - 1]
        }
        if(substr(a[j],1,1) == "$") {
            # This is a dollar amount. Tweak it to remove the $ and any trailing period.
            cost = substr(a[j], 2)
            if(substr(cost, length(cost), 1) == ".") {
                cost = substr(cost, 1, length(cost) - 1)
            }
            gsub(",", "", cost)
        }
    }
    if(0==(0+gallons) || 0==(0+cost)) {
        print "Error: gallons or cost not found in line", $0
        next
    }
    nFilled++
    totGallons += gallons
    totCost += cost
    print date "\t" gallons "\t" cost
}

END {
    fractional_years = years_between(startdate, date)
    print "Filled", nFilled, "times between", startdate, "and", date
    print "Total gallons used:", totGallons
    print "Total cost:", totCost
    print "Average cost per gallon:", totCost / totGallons
    print "Average gallons per fill:", totGallons / nFilled
    print "Number of years (fractional):", fractional_years
    print "Average gallons per year:", totGallons / fractional_years
    print "Average cost per year:", totCost / fractional_years
    print "Average number of fills per year:", nFilled / fractional_years
}
