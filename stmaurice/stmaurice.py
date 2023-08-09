# Read the St Maurice Grade 1970 School Classmates Google Sheet
# and create a web page that resembles that sheet.
# The design of the web page is based on a template input HTML file. 
# Mark Riordan  2023-03-05.
# Based on the Google Sheets API sample at 
# https://developers.google.com/sheets/api/quickstart/python
#
# Usage: python3 stmaurice.py
#
# The spreadsheet consists of:
# - A line of explanatory text, to be copied to the web page verbatim.
# - A blank line
# - A line of column headers, like this (converted to CSV):
#   First,Last,Other Name,Status,Email,Mobile,Surv,Ann,Likely?,Notes
# - Lines of classmate info, like this (converted to CSV):
#   Mark,Riordan,,Interested,riordan@rocketmail.com,608-338-9281,r,y,Very likely,
#   For the Surv column, r=responded to survey.
#   For the Ann column, y=responded to announcement of the reunion date.
#   For the Likely? column, which applies only if Status==Interested, a textual
#       description of whether they are likely to attend.  For our purposes, the
#       interesting values are Likely and Very likely, with other values treated
#       as Can't make it.

from __future__ import print_function

import os.path

# Get the following prerequisities via:
# pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from datetime import datetime

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly',
          'https://www.googleapis.com/auth/drive.metadata.readonly']

# The ID and range of the spreadsheet.
SPREADSHEET_ID = '1gU0CHEUy6zemJGO_7JpD7vuUIRKsT1l5FsZ_wzE8jZ8'
# This is the columns we want from the spreadsheet.  Behind this range
# are values that we don't want to publish on a web page.
RANGE_NAME = 'A1:E'
NCOLS_TO_OUTPUT = 4

fileOut = None
fileTemplate = None
# Dictionary containing the count of students with each status.
# Index: text of status (such as 'Interested'); value: count of students with that status.
totals = {}
# Dict of legal statuses, sorted in the order in which we
# want to print them out.  Originally I just iterated through
# "totals", but the order didn't make sense.
# Index: text of status; value: CSS class for that status.
dict_statuses = {"Will attend" : "interested", "Awaiting reply" : "waiting", 
                 "Not contacted" : "notcontacted", "Can't find" : "cantfind", 
                 "Can't make it": "cantmakeit", "Deceased" : "deceased"}
dict_statuses = {"Will attend" : "interested", 
                 "Awaiting reply" : "waiting", 
                 "Not contacted" : "notcontacted", 
                 "No reply" : "noreply",
                 "Can't find" : "cantfind", 
                 "Can't make it": "cantmakeit", 
                 "Deceased" : "deceased"}

for status in dict_statuses:
    totals[status] = 0

# Authenticate to Google Sheets / Google Drive.
def login():
    # Start by logging in, based on either cached credentials, or the
    # file credentials.json, which would have been downloaded from the
    # Google API Console.
    creds = None
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    # If there are no (valid) credentials available, let the user log in.
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        # Save the credentials for the next run
        with open('token.json', 'w') as token:
            print("Writing token.json")
            token.write(creds.to_json())
    return creds

# Return a list consisting of the rows in the spreadsheet.
def get_spreadsheet(creds):
    try:
        service = build('sheets', 'v4', credentials=creds)

        # Call the Sheets API
        sheet = service.spreadsheets()
        result = sheet.values().get(spreadsheetId=SPREADSHEET_ID,
                                    range=RANGE_NAME).execute()
        values = result.get('values', [])
    except HttpError as err:
        print(err)
    return values

# Return the last modified date/time of the Google spreadsheet.
# We have to use the Google Drive API (not Sheets API) to do this.
def get_last_modified(creds):
    driveservice = build('drive', 'v3', credentials=creds)
    metadata = driveservice.files().get(fileId=SPREADSHEET_ID, fields='modifiedTime').execute()
    lastmod = metadata['modifiedTime']
    # lastmod now looks like: 2023-03-07T03:32:09.788Z
    #                         0123456789a123456789b123
    lastmodtext = lastmod[:10] + " " + lastmod[11:19] + " GMT"
    return lastmodtext

# Return a textual representation of the current date and time.
def get_current_stamp():
    now = datetime.now()
    stamp = now.strftime("%Y-%m-%d %H:%M:%S")
    return stamp

# Write a line to our output file.
def write_html_line(line):
    print(line, file=fileOut)

# Copy the beginning of the template file up until the "end template header" line.
# The copy goes to our HTML output file.
def copy_template_header():
    global fileTemplate
    for line in fileTemplate:
        line = line.rstrip()
        if "end template header" in line:
            break
        else:
            write_html_line(line)

# Copy the trailer portion of the template file to our HTML output file.
def copy_template_trailer():
    global fileTemplate
    bCopying = False
    for line in fileTemplate:
        line = line.rstrip()
        if bCopying:
            write_html_line(line)
        elif "beg template trailer" in line:
            bCopying = True

# Increment the count of students with this status.
def increment_count(status):
    global totals
    if not (status in totals):
        totals[status] = 0
    totals[status] += 1

# Given a row from the spreadsheet, render it in HTML and write the
# HTML to the output file.
def write_cells_html(row):
    myclass = "error"
    if len(row) >= 4:
        # Determine the CSS class for this status.
        status = row[3]
        if "Can't find" in status:
            myclass = 'cantfind'
            increment_count("Can't find")
        elif status == "Deceased":
            myclass = 'deceased'
            increment_count(status)
        elif status == "Interested":
            likely = row[4]
            if likely == "Likely" or likely == "Very likely":
                status = "Will attend"
                myclass = 'interested'
            else:
                status = "Can't make it"
                myclass = 'cantmakeit'
            increment_count(status)
        elif status == "Awaiting reply":
            myclass = 'waiting'
            increment_count(status)
        elif status == "No reply":
            myclass = 'noreply'
            increment_count(status)            
        elif status == "Can't make it":
            myclass = 'cantmakeit'
            increment_count(status)
        elif status == "" or status == None:
            myclass = 'notcontacted'
            increment_count("Not contacted")
        else:
            myclass = 'error'
        row[3] = status
    else:
        # Insufficient columns means there is no status, 
        # which means not contacted.
        myclass = "notcontacted"
        increment_count("Not contacted")

    write_html_line('  <tr class="' + myclass + '">')
    for irow in range(0, NCOLS_TO_OUTPUT):
        contents = ""
        if irow < len(row):
            contents = row[irow]
        write_html_line('    <td>' + contents + '</td>')
    write_html_line('  </tr>')

# Write an HTML row giving the total number of students for a given status.
def write_one_total(label, myclass, count):
    write_html_line('  <tr>')
    write_html_line('    <td class="' + myclass +'">' + label + '</td>')
    write_html_line('    <td class="numright">' + str(count) + '</td>')
    write_html_line('  </tr>')

# Write an HTML row giving the total number of students for a given status.
def write_total_for_status(status, myclass):
    global totals
    write_one_total(status, myclass, totals[status])

# Write an HTML table with a row for each status, and the number
# of students with that status.
def write_totals():
    global totals, dict_statuses
    write_html_line('<h2>Totals</h2>')
    write_html_line('<table class="studenttable">')

    for status in dict_statuses:
        write_total_for_status(status, dict_statuses[status])
    # Check that the statuses we encountered in the spreadsheet
    # are all accounted for in the official list of possible statuses
    # in dict_statuses.
    for status in totals:
        if not status in dict_statuses:
            print("Missing status: " + status)
    write_html_line('</table>')
    
# Create an HTML table with a row for each student.
def make_table(creds, values):
    copy_template_header()

    for irow in range(0,len(values)):
        row = values[irow]
        if 0 == irow:
            # Special-case the first row, which is text to put at
            # the beginning of the HTML file.
            out = '<p>' + row[0] + '</p>'
            write_html_line(out)
            write_html_line('<table class="studenttable">')
            write_html_line('<thead class="header1">')
        elif 2==irow:
            # Special case the third row, which is column headers.
            write_html_line('  <tr>')
            for icol in range(0, NCOLS_TO_OUTPUT):
                write_html_line('    <td>' + row[icol] + '</td>')
            write_html_line('  </tr>')
            write_html_line('</thead>')
            write_html_line('<tbody>')
        elif irow > 2:
            # Rows beyond the third one are simply converted to
            # HTML rows.
            write_cells_html(row)

    write_html_line('</tbody>')
    write_html_line('</table>')

    # Create a second table with the number of students with
    # each status. 
    write_totals()

    # Refer people to our Facebook group.
    write_html_line('<p>If you have any other information on classmates, please <a href="mailto:riordan@rocketmail.com">contact us</a>. </p>')
    # write_html_line('For more information, see <a href="https://www.facebook.com/groups/952796345722090">our Facebook group</a>.</p>')
    write_html_line('<p>Here\'s the <a href="images/StMaurice1969-1970b.jpg">1969-1970 class picture</a>.</p>')
    write_html_line('<p><cite>Last updated ' + get_last_modified(creds) + '</cite></p>')
    copy_template_trailer()

def main():
    global fileTemplate, fileOut
    # Authenticate to Google.
    creds = login()

    # Fetch rows from the Google Sheets spreadsheet.
    values = get_spreadsheet(creds)
    if not values:
        print('No data found.')
        return
    
    # Open the HTML output file.
    fileOut = open("web/status2023.html", "w")
    # Open the HTML template input file.
    fileTemplate = open("stmsample.html", "r")

    # Convert the spreadsheet rows to HTML.
    make_table(creds, values)

main()
