set -e

errorMsg=""
currentPlaceInCode=""

insertPbBookSettingsRec () {
  currentTimeStamp=$(date +%s)
  sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "INSERT INTO BOOKS_SETTINGS (BOOKID,PROFILEID,CPAGE,NPAGE,OPENTIME) VALUES (\""$pbBookID"\",1,\""$currentPageNum"\",\""$totalPageCoun
  sqlite3 echo ".quit"
}

updatePbBookSettingsRec () {
  sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "UPDATE BOOKS_SETTINGS SET CPAGE =\""$currentPageNum"\",NPAGE=\""$totalPageCount"\" WHERE BOOKID=\""$pbBookID"\";" || currentPlaceInC
  sqlite3 echo ".quit"
}

checkError (){
  if ! [ $? -eq 0 ]; then
    echo "Error detected"
    dialog 1 "" "Error detected at $currentPlaceInCode."
    sqlite3 echo ".quit"
    exit
  fi
}

koReaderBookID=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT ID FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN) FROM BOOK);") || currentPlaceInCode="Get

totalPageCount=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT TOTAL_PAGES FROM PAGE_STAT_DATA WHERE START_TIME=(SELECT MAX(START_TIME) FROM PAGE_STAT_DATA

currentPageNum=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT PAGE FROM PAGE_STAT_DATA WHERE START_TIME=(SELECT MAX(START_TIME) FROM PAGE_STAT_DATA WHERE

currentBookTitle=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT TITLE FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN)FROM BOOK);") || currentPlaceInCode=

pbBookID=$(sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "SELECT ID FROM BOOKS_IMPL WHERE UPPER(TITLE)=UPPER(\""$currentBookTitle"\");") || currentPlaceInCode="Getting pocketbook bo

recordInPbBookSettings=$(sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "SELECT BOOKID FROM BOOKS_SETTINGS WHERE BOOKID = \""$pbBookID"\";") || currentPlaceInCode="Getting pocvketboo

if [ "$recordInPbBookSettings" =  "" ];
then
  currentPlaceInCode="Inserting record to PocketBook Settings table"
  dialog 1 "" "Inserted record for Book Title: $currentBookTitle, Book ID: $pbBookID, Current Page: $currentPageNum, Of Total Pages $totalPageCount"
else
  currentPlaceInCode="Updating value in PocketBook Book Settings Table"
  dialog 1 "" "Updated record for Book Title: $currentBookTitle, Book ID: $pbBookID, Current Page: $currentPageNum, Of Total Pages $totalPageCount"
fi
exit
