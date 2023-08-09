WEBDIR=/Users/mrr/Sites/stmaurice
STORIESFILE=web/stories.html
# This creation of the stories page is a temporary mockup.
cp bios-skel.html $STORIESFILE
awk -f /Users/mrr/Documents/GitHub/miscscripts/stmaurice/tsv2bio.awk studentnames.tsv >>$STORIESFILE
cat bios-skel-end.html >>$STORIESFILE
cp $STORIESFILE $WEBDIR/
cp web/index.html $WEBDIR/
cp web/stmaurice.css $WEBDIR/
cp web/status2023.html $WEBDIR/
