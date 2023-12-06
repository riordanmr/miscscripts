# counttsvphotos.awk - script to read data copied from a spreadsheet
# and calculate how many photos there are of each person in the
# St. Maurice Grade School reunion.
# Mark Riordan  2023-08-28
# awk -f counttsvphotos.awk photos.tsv | sort -t$'\t' -k2n
#
# Input lines contain tab-separated fields and look like:
# y       ./Denise/IMG_4445.heic  Katherine,Steve,Irene
# Only lines starting with y are considered.
BEGIN {
    FS = "\t"
}

/^y/{
    # Create aryNames as an array of all the CSV names in field 3.
    nNames = split($3,aryNames,",")
    # Iterate through the names, incrementing the count for each.
    for (i in aryNames) {
        name = aryNames[i]
        aryNameToCount[name]++
    }
}

END {
    for(name in aryNameToCount) {
        print name "\t" aryNameToCount[name]
    }
}
