#!/bin/sh

SH_IVTOOL=/mnt/ext1/system/bin/sh_ivtool.app
dirOfKoReaderDB=/mnt/ext1/applications/koreader/settings/statistics.sqlite3
dirOfPbBooksDB=/mnt/ext1/system/explorer-3/explorer-3.db

insertPbBookSettingsRec () {
  currentTimeStamp=$(date +%s)
  sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "INSERT INTO BOOKS_SETTINGS (BOOKID,PROFILEID,CPAGE,NPAGE,OPENTIME) VALUES (\""$pbBookID"\",1,\""$currentPageNum"\",\""$totalPageCount"\",\""$currentTimeStamp"\");"
  echo "Inserted record into PocketBook Book Settings Table for Book ID $pbBookID"
}

updatePbBookSettingsRec () {
  sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "BEGIN TRANSACTION; UPDATE BOOKS_SETTINGS SET CPAGE =\""$currentPageNum"\",NPAGE=\""$totalPageCount"\" WHERE BOOKID=\""$pbBookID"\"; COMMIT;"
  echo "Updated record in PocketBook Book Settings Table for Book ID $pbBookID"
}

totalPageCount=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT PAGES FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN) FROM BOOK);")
echo $totalPageCount


currentPageNum=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT TOTAL_READ_PAGES FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN) FROM BOOK);")
echo $currentPageNum


currentBookTitle=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT TITLE FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN)FROM BOOK);")
echo $currentBookTitle

#if [ "$currentPageNum" -eq  "0" ];
#then
 # echo "No need to update. current page is 0"
 # exit
#fi

pbBookID=$(sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "SELECT ID FROM BOOKS_IMPL WHERE UPPER(TITLE)=UPPER(\""$currentBookTitle"\");")
echo "Found book title in PocketBook DB. ID: $pbBookID"


recordInPbBookSettings=$(sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "SELECT BOOKID FROM BOOKS_SETTINGS WHERE BOOKID = \""$pbBookID"\";")
echo $recordInPbBookSettings

if [ "$recordInPbBookSettings" =  "" ];
then
  echo "No value in PocketBook Book Settings Table"
  insertPbBookSettingsRec
  $SH_IVTOOL -s "Inserted record for Book Title: $currentBookTitle, Book ID: $pbBookID, Current Page: $currentPageNum, Of Total Pages $totalPageCount"
else
  echo "Found value in PocketBook Book Settings Table"
  updatePbBookSettingsRec
  $SH_IVTOOL -s "Updated record for Book Title: $currentBookTitle, Book ID: $pbBookID, Current Page: $currentPageNum, Of Total Pages $totalPageCount"
fi


