# Read the St Maurice Grade 1970 School Classmates Google Sheet
# and create a web page that resembles that sheet.
# The design of the web page is based on a template input HTML file. 
# Mark Riordan  2023-03-05.
# Based on the sample at https://developers.google.com/sheets/api/quickstart/python
#
# Usage: python3 stmaurice.py

from __future__ import print_function

import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from datetime import datetime

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly',
          'https://www.googleapis.com/auth/drive.metadata.readonly']

# The ID and range of a sample spreadsheet.
SPREADSHEET_ID = '1gU0CHEUy6zemJGO_7JpD7vuUIRKsT1l5FsZ_wzE8jZ8'
# This is the columns we want from the spreadsheet.  Behind this range
# are values that we don't want to publish on a web page.
RANGE_NAME = 'A1:D'
NCOLS = 4

fileOut = None
fileTemplate = None

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

# Get a list consisting of the rows in the spreadsheet.
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

# This is meant to return the last modified date/time of the Google spreadsheet.
# We have to use the Google Drive API (not Sheets API) to do this.
# However, I am having a tough time getting the right permissions to 
# access the Google Drive API, so this currently isn't working. 
def get_last_modified(creds):
    driveservice = build('drive', 'v3', credentials=creds)
    metadata = driveservice.files().get(fileId=SPREADSHEET_ID, fields='modifiedTime').execute()
    print(metadata.__dir__)

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

def write_cells_html(row):
    myclass = "notcontacted"
    if len(row) >= 4:
        status = row[3]
        if status == "Can't find on Facebook":
            myclass = 'cantfind'
        elif status == "Deceased":
            myclass = 'deceased'
        elif status == "Interested":
            myclass = 'interested'
        elif status == "Awaiting reply":
            myclass = 'waiting'
        elif status == "Can't make it":
            myclass = 'cantmakeit'
        elif status == "":
            myclass = 'notcontacted'
        else:
            myclass = 'error'
    write_html_line('  <tr class="' + myclass + '">')
    for irow in range(0, NCOLS):
        contents = ""
        if irow < len(row):
            contents = row[irow]
        write_html_line('    <td>' + contents + '</td>')
    write_html_line('  </tr>')

def make_table(values):
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
            for cell in row:
                write_html_line('    <td>' + cell + '</td>')
            write_html_line('  </tr>')
            write_html_line('</thead>')
            write_html_line('<tbody>')
        elif irow > 2:
            # Rows beyond the third one are simply converted to
            # HTML rows.
            write_cells_html(row)


    write_html_line('</tbody>')
    write_html_line('</table>')
    write_html_line('<p><cite>Last updated ' + get_current_stamp() + '</cite></p>')
    copy_template_trailer()

def main():
    global fileTemplate, fileOut
    creds = login()
    # Disabled until I can figure out how to get permissions to obtain document stamp.
    #get_last_modified(creds)

    # Fetch rows from the Google Sheets spreadsheet.
    values = get_spreadsheet(creds)
    if not values:
        print('No data found.')
        return
    
    # Open the HTML output file.
    fileOut = open("index.html", "w")
    # Open the HTML template input file.
    fileTemplate = open("stmsample.html", "r")

    # Convert the spreadsheet rows to HTML.
    make_table(values)

main()
