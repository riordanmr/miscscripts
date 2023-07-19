# RemoveSvgImage.awk - Special-purpose script to remove an image object
# from an svg file.  This is for tracing bitmap images as SVG files,
# as created by InkScape.
# Skip sections like this:
#     <image
#       ...
#     style="stroke-width:7.55905512;stroke-miterlimit:4;stroke-dasharray:none" />
# Mark Riordan  5 July 2023
# awk -f RemoveSvgImage.awk <WindowDiagram-TamsArea.svg >WindowDiagram-TamsAreaNI.svg
BEGIN {
    # Get the current date and time in order to fill in the current date/time
    # in the script.
    "date \"+%Y-%m-%d %H:%M:%S\"" | getline datetime
}
{
    line = $0
    if(!skipping) {
        if(index(line, "<image")>0) {
            skipping = 1
        } else {
            # Replace !datetime! with the current date and time.
            sub(/!datetime!/, datetime, line)
            print line
        }
    } else if(index(line, "/>") > 0) {
        skipping = 0
    }
}
