# cleanhtml.py is a Python script that reads an HTML file and 
# removes all style attributes from the tags.
# The script uses the BeautifulSoup library to parse the HTML content
# and remove the style attributes from the tags.
# The modified HTML content is then printed to the console.
#
# Usage: python3 ~/Documents/GitHub/miscscripts/cleanhtml.py
# MRR   2024-09-29

from bs4 import BeautifulSoup

# Read the contents of the file "j" into the variable html_content
with open("j", "r") as file:
    html_content = file.read()

soup = BeautifulSoup(html_content, 'html.parser')

# Remove all style attributes
for tag in soup.find_all(True):
    if 'style' in tag.attrs:
        del tag.attrs['style']
    if 'class' in tag.attrs:
        del tag.attrs['class']
    if 'id' in tag.attrs:
        del tag.attrs['id']
    if 'dir' in tag.attrs:
        del tag.attrs['dir']

# Print the modified HTML
print(soup.prettify())