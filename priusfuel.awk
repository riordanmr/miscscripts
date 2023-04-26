# priusfuel.awk - read the Pruis Fuel CSV file (normally found 
# in the Apple Notes app as Pruis Fuel) and report
# the average MPG per year.
# Mark Riordan   2023-04-26
# awk -f priusfuel.awk /Users/mrr/Documents/PruisFuel.csv

BEGIN {
    FS = ","
}

{
    # Typical line:
    # 2020-11-15,122111,9.89,2.259,4.379,Flagstaff 
    # The last field is a comment and is optional
    line = $0
    date = $1
    odometer = $2 + 0
    dollars = $3
    pergallon = $4
    gallons = $5
    comment = $6

    year = substr(date, 1, 4)

    err = ""
    if(odometer != 0 && odometer < prev_odometer) {
        err = "Miles went backwards"
    } else if((prev_odometer > 0) && (odometer - prev_odometer)>500000) {
        err = "Too big a gap in odometer readings"
    } else if(((0+year) < 2000) || (year > 2040)) {
        err = "Bad year"
    } else if(gallons <= 0.0 || gallons > 12) {
        err = "Bad gallons"
    }

    if(err != "") {
        print "Error on line " NR ": " err ": " line
    } else {
        # For the very first record, ignore the number of gallons.
        if(bAfterFirst) {
            gallons_this_year += gallons
        } else {
            bAfterFirst = 1 
        }
        if(year != prev_year) {
            if(prev_year != 0) {
                miles_this_year = odometer - odo_beg_year
                mpg_this_year = miles_this_year / gallons_this_year
                print prev_year "\t" mpg_this_year
                gallons_this_year = 0
            } else {
                # Special case of first record in the file.
            }
            odo_beg_year = odometer
        }
    }

    prev_date = date
    prev_year = year
    prev_odometer = odometer
}

END {
    if(gallons_this_year > 0) {
        # Perform the same calculations for this partial year at EOF.
        # The variables below should be unchanged since the last
        # record we read.
        miles_this_year = odometer - odo_beg_year
        mpg_this_year = miles_this_year / gallons_this_year
        print prev_year "\t" mpg_this_year
    }
}
