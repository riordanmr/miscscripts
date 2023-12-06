# extractfontnames.awk - Extract the name of fonts from the output of
# fc-list -b >fc-list.txt
# Note: I also tried this:
# system_profiler -xml SPFontsDataType
# but it was more difficult to get the actual font names from this list.
#
# awk -f extractfontnames.awk fc-list.txt | sort | uniq >fontnames.txt
# MRR  2023-09-18
#
# Update: This seems to work:
# fc-list : family | sort -f
{
    line = $0
    # Look for font names in lines like:
    # 	family: "Noto Sans Phoenician"(s)
    if(match(line,"family: \"")) {
        rest = substr(line, RSTART+RLENGTH)
        idx = index(rest,"\"")
        if(idx > 0) {
            fontname = substr(rest,1,idx-1)
            print fontname
        } else {
            print "** Error: rest=" rest
        }
    }
}
