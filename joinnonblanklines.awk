# joinnonblanklines.awk - script to join lines from input into long lines,
# but we start a new line when a blank line is encountered.
# For converting text files to HTML; the next step is to run txt2html.awk
#
# Mark Riordan  2023-05-19

function stripline(line) {
   while(length(line) > 0 && substr(line, length(line), 1)==" ") {
      line = substr(line, 1, length(line)-1)
   }
   return line
}

{
   line = stripline($0)
   if(length(line)>0) {
      if(length(prevline)>0) {
         prevline = prevline " " line
      } else {
         prevline = line
      }
   } else {
      print prevline
      prevline = ""
   }
}

END {
   print prevline
}
