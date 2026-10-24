# truncate_at_space.awk - read a CSV file and write a new one where
# each CSV token is truncated at the first space (and the first space
# is also removed). For bike shop room IDs.
# awk -f ~/Documents/GitHub/miscscripts/truncate_at_space.awk namechange.csv
# MRR  2026-10-24
BEGIN { FS=OFS="," }
{
  for(i=1; i<=NF; i++) {
    sub(/ .*/, "", $i)
  }
  print
}
