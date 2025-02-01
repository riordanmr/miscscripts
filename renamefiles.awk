# renamefiles.awk - script to generate "mv" commands to rename
# files with alphabetically increasing names.
# Sample input:
#   2272523732342318378.jpg
#   3653129442473911752.jpg
# Sample output:
#   mv 2272523732342318378.jpg damage01.jpg
#   mv 3653129442473911752.jpg damage02.jpg
# Usage: ls -tr1 *.jpg | awk -f /Users/mrr/Documents/GitHub/miscscripts/renamefiles.awk
{
    printf("mv %s damage%02d.jpg\n", $0, ++i);
}
