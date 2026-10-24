# trimtokens.awk - inputs CSV file and outputs the same lines
# with each token space-trimmed.
# MRR and GitHub Copilot  2026-10-24
# awk -f ~/Documents/GitHub/miscscripts/trimtokens.awk namechange.csv
BEGIN { FS=OFS="," }
{
  for(i=1;i<=NF;i++) {
    gsub(/^ +| +$/, "", $i)
  }
  print
}
