@Echo ON
ECHO Making project directories and files writable... 
ECHO Making project directories and files writable... >> %logFile%

Rem  We will use the SPVER variable for now.
if "%SPVER%" == "2013" set HiveNum=15
if "%SPVER%" == "2010" set HiveNum=14
if "%SPVER%" == "2007" set HiveNum=12

cd %spDevDir%
attrib *.* -R /S

cd "%axcelerHive%"
attrib *.* -R /S

ECHO Finished making project directories and files writable... 
ECHO Finished making project directories and files writable... >> %logFile%