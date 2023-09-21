# points2svg.awk - script to take an input file containing X,Y coordinates
# of traced images (from recordpoints.html) and output SVG files.
# The input file contains multiple batches of points, one per line,
# separated by a line containing "----", like this:
#
# 410,124
# 438,118
# ----
# 391,203
# 422,174
# 552,220
# 551,229
# ----
# A batch containing 2 points represents a circle. The first point is
# the center, and the second is an arbitrary point on the circle.
# A batch containing more than 2 points represents a polygon. The 
# last point of the polygon is implied to be a duplicate of the first point.
#
# Usage: awk -f points2svg.awk runner-points.txt 
#
# Mark Riordan 2023-09-20

function makeSVG(filename) {
    print "<svg width=\"" width "\" height=\"" height "\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">" >filename
    for(ipath=1; ipath<=nBatches; ipath++) {
        path = ""
        pointsInThisBatch = aryPointsInBatch[ipath]
        if(pointsInThisBatch==2) {
            # Draw a circle with center at point 1 and radius computed from
            # the point on the circle at point 2.
            split(aryPoints[ipath ":" 1], aryCenter, ",")
            split(aryPoints[ipath ":" 2], aryPointOnCircle, ",")
            # Compute radius.
            # Use cheap hack that I know the point on the circle is on the same Y
            # as the center point.
            radius = aryPoints[ipath ":" 2] - aryPoints[ipath ":" 1]
            circle = "  <circle cx=\"" aryCenter[1] "\" cy=\"" aryCenter[2] "\" r=\"" radius "\" fill=\"black\"/>"
            print circle >>filename
        } else {
            # Create a path like this:
            # <path d="M150 0 L75 200 L225 200 Z" />
            for(ipoint=1; ipoint<=pointsInThisBatch; ipoint++) {
                if(ipoint==1) {
                    path = "M" aryPoints[ipath ":" ipoint] " "
                } else {
                    path = path "L" aryPoints[ipath ":" ipoint] " "
                }
            }
            path = path "Z"
            # Replace , with " " because SVG uses points with X and Y separated by spaces.
            gsub(/,/, " ", path)
            print "  <path d=\"" path "\"/>" >>filename
        }

    }
    print "</svg>" >>filename
    close(filename)
}

BEGIN {
    FS = ","
}
{
    line = $0
    if(line=="----") {
        aryPointsInBatch[nBatches] = nPointsInBatch
        nPointsInBatch = 0
    } else if(NF==2) {
        if(0==nPointsInBatch) {
            nBatches++
        }
        nPointsInBatch++
        aryPoints[nBatches ":" nPointsInBatch] = line
    } else if(length(line)>0) {
        print "Error on line " NR ": " line
    }
}

END {
    # Find the range of values for X and Y.
    xMin = 9999
    yMin = 9999
    for(idx in aryPoints) {
        split(aryPoints[idx],aryPoint,",")
        # Convert to numeric
        x = aryPoint[1] + 0
        y = aryPoint[2] + 0
        if(x > xMax) xMax = x
        if(x < xMin) xMin = x
        if(y > yMax) yMax = y
        if(y < yMin) yMin = y
    }
    print "x: " xMin " " xMax "; y: " yMin " " yMax
    width = 1.2 * (xMax - xMin + 1)
    height = 1.4 * (yMax - yMin + 1)

    makeSVG("runner1.svg")
}
