# PocketBook-Sync-KoReader-progress-with-PB-Library
Small .sh script to update PocketBook library with current KoReader book progress. It's more of an aproximation. I wanted the library to be somewhat up to date with what I'm reading. Syncs *LAST PAGE* read. Meaning if you leave KoReader on Page 30 and run the app, it will sync page 29.

***TESTED ON POCKETBOOK ERA, LATEST FIRMWARE***

A shell script that will take your most recently opend KoReader book and insert or update a record to the PocketBook library. At the end it prints a summary of the Book title, id, current page, and total number of pages and wether a update or insert happened. It will also output an error if one occurs

How it works:
  1. Open the KoReader statistics.sqlite3 database and find the most recently updated book
  2. Get the total pages ,current page and, book title from the KoReader statistics.sqlite3 database with greatest last open time
  3. Find the book title in the explorer-3.db database
  4. Get the ID from the matching book title from the explorer3.db database
  5. Find if a record exists in the books_settings table with the bookid in the explorer-3.db database
  6. If no record, insert a record for this
  7. If record is found, update the current record

To install:
  1. Copy the updateCurrentPage.app to the /applications/ folder of your PocketBook
 
To use:
  1. Start device
  2. Go to applications
  3. Scroll to find @currentPageUpdate
  4. Press @currentPageUpdate

To-do:
Add ability to sync all book progress
Add ability to detect current page = total pages and mark as complete
Add this to KoReader as an automated process(On page refresh, every x minutes, on standy, etc.)
Add ability to sync pages going back. Example: On page 30, go back to 26, 29 is still displayed as last read page.
