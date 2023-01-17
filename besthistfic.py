# besthistfic.py - script to create an HTML Table from a web page containing
# a list of recommended books.
# The web page is https://www.shortform.com/best-books/genre/best-historical-fiction-books-of-all-time
# but we use a processed version of it (Safari's View Source, which prettifies it).
# 
# For each recommended book, there are several sections, in this order:
# The title is in a section like this:
#                                                             <h2 class="display-4 mb-0 mt--2">
#                                                                <a href="/best-books/book/all-the-light-we-cannot-see-book-reviews-anthony-doerr">All the Light We Cannot See</a>
# The author is in a section like this:
#                                                                 <span class="d-block d-md-inline">Anthony Doerr</span>
# The description is in a section like this:
#                                                             <div class="sf-html-text__full" style="display: none;">
#                                                                <span>
#                                                                    <i>
#                                                                        An alternate cover for this ISBN can be found 
#                                                                        <a href="https://www.goodreads.com/book/show/25210408-all-the-light-we-cannot-see" rel="nofollow">here</a>
#                                                                    </i>
#                                                                    <br>
#                                                                    <br>
#                                                                    From the highly acclaimed, multiple award-winning Anthony Doerr, the stunningly beautiful instant 
#                                                                    <i>New York Times</i>
#                                                                     bestseller about a blind French girl and a German boy whose paths collide in occupied France as both try to survive the devastation of World War II.
#                                                                    <br>
#                                                                    <br>
#                                                                    Marie-Laure lives in Paris near the Museum of Natural History, where her father works. When she is twelve, the Nazis occupy Paris and father and daughter flee to the walled citadel of Saint-Malo, where Marie-Laure’s reclusive great uncle lives in a tall house by the sea. With them they carry what might be the museum’s most valuable and dangerous jewel.
#                                                                    <br>
#                                                                    <br>
#                                                                    In a mining town in Germany, Werner Pfennig, an orphan, grows up with his younger sister, enchanted by a crude radio they find that brings them news and stories from places they have never seen or imagined. Werner becomes an expert at building and fixing these crucial new instruments and is enlisted to use his talent to track down the resistance. Deftly interweaving the lives of Marie-Laure and Werner, Doerr illuminates the ways, against all odds, people try to be good to one another.
#                                                                </span>
# Actually, most books also have a shorter description, which would be preferable
# for my purposes, but unfortunately some books lack a short description.
#
# Initially developed with https://www.online-ide.com; then completed with command-line python3.
#
# Input complete web page is from besthistfic.html.
# HTML table output is to besthistab.html.
# Debug to stdout.
#
# Mark Riordan  16 Jan 2023

from enum import Enum
import re

States = Enum('States', 'ST_BEGIN ST_NEXT_LINE_IS_TITLE ST_IN_DESC')
DescStates = Enum('DescStates', "D_BEGIN D_LOOK_FOR_END_ALT")

def summarize_desc(full_desc):
    desc_state = DescStates.D_BEGIN
    desc = ""
    for line in full_desc:
        print("sumloop: '"+ line + "'")
        if line=="<span>" or line=="<i>" or line=="</i>":
            continue
        if desc_state == DescStates.D_BEGIN:
            if "alternate cover" in line.lower():
                desc_state = DescStates.D_LOOK_FOR_END_ALT
            elif line=="<br>" or line=="<p>":
                if desc != "":
                    break
            else:
                desc = desc + line + " "

        elif desc_state == DescStates.D_LOOK_FOR_END_ALT:
            if line=="<br>":
                desc_state = DescStates.D_BEGIN
    desc = desc.replace("<b>","")
    desc = desc.replace("</b>","")
    return desc

def main():
    regexCaptureText = r"\>(.+)\<"
    file1 = open('besthistfic.html', 'r')
    fileout = open('besthisttab.html', 'w')
    fileout.write("<!DOCTYPE html>\n")
    fileout.write("<html>\n")
    fileout.write("<head>\n")
    fileout.write("<meta charset=\"UTF-8\">\n")
    fileout.write("</head>\n")
    fileout.write("<body>\n")
    fileout.write("<table border='1'>\n")
    state = States.ST_BEGIN
    author = ""
    title = ""
    while True:
        # Get next line from file
        line = file1.readline()
  
        # if line is empty, end of file is reached
        if not line:
            break
        
        if state==States.ST_BEGIN:
            if '<h2 class="display-4 mb-0 mt--2">' in line:
                state = States.ST_NEXT_LINE_IS_TITLE
            elif '<span class="d-block d-md-inline">' in line:
                result = re.search(regexCaptureText,line)
                author = result.group(1)
            elif '<div class="sf-html-text__full"' in line:
                state = States.ST_IN_DESC
                list_desc = []
        elif state==States.ST_NEXT_LINE_IS_TITLE:
            result = re.search(regexCaptureText,line)
            title = result.group(1)
            print('title="' + title + '"')
            state = States.ST_BEGIN
        elif state==States.ST_IN_DESC:
            if "</span>" in line:
                #print(author + "|" + title + "|" + desc)
                desc = summarize_desc(list_desc)
                fileout.write("<tr>\n")
                fileout.write("  <td>"+title+"</td>\n")
                fileout.write("  <td>" + author + "</td>\n")
                fileout.write("  <td>" + desc + "</td>\n")
                fileout.write("</tr>\n")
                print('desc=' + desc)
                author = ""
                title = ""
                list_desc = []
                state = States.ST_BEGIN
            else:
                list_desc.append(line.strip())
            pass
  
    fileout.write("</table>\n")
    fileout.write("</body>\n")
    fileout.write("</html>\n")
    file1.close()
    fileout.close()

main()
