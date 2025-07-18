# linktohtml.py - script to convert the HTML version of a Google Doc
# and write a copy of it that makes certain changes.
# Changes:
# - Change link:x:y: to <a href="y">x</a> 
# - Remove class="x" and style="x" attributes
# - Several other changes
#
# Usage: 
# Do a Copy operation of the full HTML from the Google Doc and paste it into the file 548elcamrepairs.html. 
# Run the script with the command:
# python3 ~/Documents/GitHub/miscscripts/linktohtml.py ~/Documents/548elcamrepairs.html >~/Sites/miscweb/548elcamino/repairs.html
#
# Mark Riordan 2025-01-30

import re
import sys

def replace_links(line):
    # Regular expression to match link:x:y pattern
    pattern = r'link:([^:]+):([a-zA-Z0-9\-_\.]+):'
    # Replace the pattern with <a href="y">x</a>
    return re.sub(pattern, r'<a href="miscdocs/\2">\1</a>', line)

def remove_class_attributes(line):
    # Regular expression to match class="x" pattern
    pattern = r'class="[a-zA-Z0-9\-_\.]+"'
    # Replace the pattern with an empty string
    result = re.sub(pattern, '', line)
    return result

def remove_style_attributes(line):
    # Regular expression to match style="x" pattern
    pattern = r'style="[a-zA-Z0-9\-_\.; :#]+"'
    # Replace the pattern with an empty string
    return re.sub(pattern, '', line)

def contains(line, pattern):
    return pattern in line

def process_file(input_file):
    html = ''
    copying = True
    with open(input_file, 'r') as infile:
        for line in infile:
            pattern ='<title></title>'
            if contains(line, pattern):
                html += '  <!-- Generated by python3 ~/Documents/GitHub/miscscripts/linktohtml.py ~/Documents/548elcamrepairs.html >~/Sites/miscweb/548elcamino/repairs.html -->\n'
                line = re.sub(pattern, r'<title>Repairs</title>', line)
                html += '  <link rel="stylesheet" href="elcam.css">\n'
            new_line = line    
            if contains(new_line, '<meta name="Generator" content="Cocoa HTML Writer">'):
                continue
            if contains(new_line, '<meta name="CocoaVersion" content="2575.3">'):
                continue
            if contains(new_line, '</body>'):
                load_nav = """
<script>
    document.addEventListener("DOMContentLoaded", function() {
        fetch('nav.html')
            .then(response => response.text())
            .then(data => {
                document.getElementById('nav-placeholder').innerHTML = data;
            });
    });
</script>
"""
                html += load_nav
            # Remove class attributes in the current line
            new_line = remove_class_attributes(new_line)
            # Remove style attributes in the current line
            new_line = remove_style_attributes(new_line)
            #print("Tried to remove style attributes")
            new_line = new_line.replace('<span >', '')
            new_line = new_line.replace('</span>', '')
            # Replace links in the current line
            new_line = replace_links(new_line)
            if contains(new_line, '<style type="text/css">'):
                copying = False
            if copying:
                html += new_line
            if contains(new_line, '<body>'):
                html += '  <div id="nav-placeholder"></div>\n'
            if contains(new_line, '</style>'):
                copying = True
        # Write the processed HTML to the output file
        sys.stdout.write(html)

def main():
    input_file = '548elcamrepairs.html'
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    process_file(input_file)

main()
