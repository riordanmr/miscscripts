# addmedicare.awk - add up Medicare payments as scraped from
# https://www.medicare.gov/my/premiums/history
# One month looks like:
# Post date
# 12/21/2023
# Payment method
# Medicare Easy Pay
# Applied to Part B	$174.70
# Applied to Part A	$0.00
# Applied to Part D IRMAA	$0.00
# Total amount posted	$174.70
#
# awk -f ~/Documents/GitHub/miscscripts/addmedicare.awk ~/Documents/Finances/2023Medicare.txt
#
# MRR  2023-03-01 
function stripdollar(val) {
  if(substr(val,1,1)=="$") {
    val = substr(val,2)
  }
  return val
}
/\/20/ {
  date = $1
}
/Applied to Part D/ {
  monthlydollars = $(NF)
  print date "\t" stripdollar(monthlydollars)
}

