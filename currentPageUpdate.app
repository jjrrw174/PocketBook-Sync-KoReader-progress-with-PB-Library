#!/bin/sh

echo "Starting page update `date`" > currentPageUpdateLog.txt
errorMsg=""
currentPlaceInCode=""

insertPbBookSettingsRec () {
  echo "Inserting into PB Book Settings" >> currentPageUpdateLog.txt
  echo "INSERT INTO BOOKS_SETTINGS (BOOKID,PROFILEID,CPAGE,NPAGE,OPENTIME) VALUES ($pbBookID,1,$currentPageNum,$totalPageCount,$currentTimeStamp);" >> currentPageUpdateLog.txt
  currentTimeStamp=$(date +%s)
  sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "INSERT INTO BOOKS_SETTINGS (BOOKID,PROFILEID,CPAGE,NPAGE,OPENTIME) VALUES (\""$pbBookID"\",1,\""$currentPageNum"\",\""$totalPageCount"\",\""$currentTimeStamp"\");" 2>> currentPageUpdateLog.txt || currentPlaceInCode="Inserting PocketBook settings record" checkError
}

updatePbBookSettingsRec () {
  echo "Updating PB Book Settings record" >> currentPageUpdateLog.txt
  echo "UPDATE BOOKS_SETTINGS SET CPAGE =$currentPageNum,NPAGE=$totalPageCount WHERE BOOKID=$pbBookID;" >> currentPageUpdateLog.txt
  sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "UPDATE BOOKS_SETTINGS SET CPAGE =\""$currentPageNum"\",NPAGE=\""$totalPageCount"\" WHERE BOOKID=\""$pbBookID"\";" 2>> currentPageUpdateLog.txt || currentPlaceInCode="Updating PocketBook settings record" checkError
}

checkError (){
  exitScript=$1
  
  if [ $exitScript = "true" ]; then
    someKindOfError=$(tail -n 1 currentPageUpdateLog.txt)
    dialog 1 "" "Error detected at $currentPlaceInCode. Error is $someKindOfError" "OK"
    exit
  fi 

  if [ $? -eq 0 ]; then
    sqlError=$(tail -n 1 currentPageUpdateLog.txt)
    dialog 1 "" "Error detected at $currentPlaceInCode.Error is $sqlError" "OK"   
    exit
  fi
}


koReaderBookID=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT ID FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN) FROM BOOK);") 2>> currentPageUpdateLog.txt || currentPlaceInCode="Get KoReader book Id" checkError
echo "SELECT ID FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN) FROM BOOK);" >> currentPageUpdateLog.txt
echo "KoReader book id: $koReaderBookID" >> currentPageUpdateLog.txt

totalPageCount=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT TOTAL_PAGES FROM PAGE_STAT_DATA WHERE START_TIME=(SELECT MAX(START_TIME) FROM PAGE_STAT_DATA);") 2>> currentPageUpdateLog.txt || currentPlaceInCode="Getting total pages from KoReader" checkError
echo "SELECT TOTAL_PAGES FROM PAGE_STAT_DATA WHERE START_TIME=(SELECT MAX(START_TIME) FROM PAGE_STAT_DATA);" >> currentPageUpdateLog.txt
echo "KoReader Total Page Count: $totalPageCount" >> currentPageUpdateLog.txt

currentPageNum=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT PAGE FROM PAGE_STAT_DATA WHERE START_TIME=(SELECT MAX(START_TIME) FROM PAGE_STAT_DATA WHERE ID_BOOK=\""$koReaderBookID"\");") 2>> currentPageUpdateLog.txt || currentPlaceInCode="Getting current page from KoReader" checkError
echo "SELECT PAGE FROM PAGE_STAT_DATA WHERE START_TIME=(SELECT MAX(START_TIME) FROM PAGE_STAT_DATA WHERE ID_BOOK=$koReaderBookID" >> currentPageUpdateLog.txt
echo "KoReader Current Page Number $currentPageNum" >> currentPageUpdateLog.txt

currentBookTitle=$(sqlite3 /mnt/ext1/applications/koreader/settings/statistics.sqlite3 "SELECT TITLE FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN)FROM BOOK);") 2>>currentPageUpdateLog.txt || currentPlaceInCode="Getting current book title from KoReader" checkError
echo "SELECT TITLE FROM BOOK WHERE LAST_OPEN=(SELECT MAX(LAST_OPEN)FROM BOOK);" >> currentPageUpdateLog.txt
echo "KoReader Current Book Title $currentBookTitle" >> currentPageUpdateLog.txt

pbBookID=$(sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "SELECT ID FROM BOOKS_IMPL WHERE UPPER(TITLE)=UPPER('$currentBookTitle');") 2>> currentPageUpdateLog.txt || currentPlaceInCode="Getting pocketbook book ID" checkError 
echo "SELECT ID FROM BOOKS_IMPL WHERE UPPER(TITLE)=UPPER($currentBookTitle);" >> currentPageUpdateLog.txt
echo "PocketBook ID: $pbBookID" >> currentPageUpdateLog.txt

if [ -z "$pbBookID" ];
then
        echo "No Pocket Book ID found in books_impl" >> currentPageUpdateLog.txt
	currentPlaceInCode="No PocketBook ID found in books_impl"
	checkError true
fi

recordInPbBookSettings=$(sqlite3 /mnt/ext1/system/explorer-3/explorer-3.db "SELECT BOOKID FROM BOOKS_SETTINGS WHERE BOOKID = \""$pbBookID"\";") 2>> currentPageUpdateLog.txt || currentPlaceInCode="Getting pocketbook book settings record" checkError
echo "Record in PocketBook Settings Table: $recordInPbBookSettings" >> currentPageUpdateLog.txt

if [ "$recordInPbBookSettings" =  "" ];
then
  insertPbBookSettingsRec
  currentPlaceInCode="Inserting record to PocketBook Settings table"
  dialog 1 "" "Inserted record for Book Title: $currentBookTitle, Book ID: $pbBookID, Current Page: $currentPageNum, Of Total Pages $totalPageCount" "OK"
else
  updatePbBookSettingsRec
  currentPlaceInCode="Updating value in PocketBook Book Settings Table"
  dialog 1 "" "Updated record for Book Title: $currentBookTitle, Book ID: $pbBookID, Current Page: $currentPageNum, Of Total Pages $totalPageCount" "OK"
fi
