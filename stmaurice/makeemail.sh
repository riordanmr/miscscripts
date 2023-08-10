awk '{if(length($0)>0 && $0!="NA")print}' emailraw2.txt | awk '{if(length(mem)>0){mem = mem ","} mem = mem $0}END {print mem}' >emails.csv
