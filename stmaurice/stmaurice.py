# Read the St Maurice Grade 1970 School Classmates Google Sheet
# and create a web page that resembles that sheet.
# Mark Riordan  2023-03-05.
# Based on the sample at https://developers.google.com/sheets/api/quickstart/python
#
# python3 stmaurice.py

from __future__ import print_function

import os.path

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ['https://www.googleapis.com/auth/spreadsheets.readonly']

# The ID and range of a sample spreadsheet.
SPREADSHEET_ID = '1gU0CHEUy6zemJGO_7JpD7vuUIRKsT1l5FsZ_wzE8jZ8'
RANGE_NAME = 'A1:D'

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

def main():
    creds = login()
    values = get_spreadsheet(creds)
    if not values:
        print('No data found.')
        return
    #print("Number of values: ", len(values))
    #print("Print of values:")
    print(values)

    for irow in range(0,len(values)):
        row = values[irow]
        out = ""
        for cell in row:
            out = out + "\t" + cell
        print(out)
        #print(values[irow][0],values[irow][3])
        #print(row.__dir__())
        #print("Count of row ",row.count())
        # Print columns A and D, which correspond to indices 0 and 3.
        #print('%s, %s' % (row[0], row[3]))

main()