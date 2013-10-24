@echo off

ECHO Copying the manuals... 
ECHO Copying the manuals... >> %logFile%

set manualSource="\\Axsource\SourceSafe\DOCS\ControlPoint%DocVer%\Install Docs"
set manualDestination="C:\SharepointDev\Install\ControlPoint"
set ReadmeSource="C:\SharepointDev\Docs"

rem copy all .pdf files to SharepointDev
ECHO Starting the .pdf manuals... 
ECHO Starting the .pdf manuals... >> %logFile%
xcopy %manualSource%\*.pdf %manualDestination%
ECHO Finished the .pdf manuals 
ECHO Finished the .pdf manuals >> %logFile%

rem copy all .zip files to SharepointDev
ECHO Starting the .zip manuals... 
ECHO Starting the .zip manuals... >> %logFile%
xcopy %manualSource%\*.zip %manualDestination%
ECHO Finished the .zip manuals 
ECHO Finished the .zip manuals >> %logFile%

rem copy all .doc files to SharepointDev (Used for MSOCAF kit)
ECHO Starting the .doc manuals... 
ECHO Starting the .doc manuals... >> %logFile%
xcopy %manualSource%\*.doc %manualDestination%
ECHO Finished the .doc manuals 
ECHO Finished the .doc manuals >> %logFile%

rem copy all Readme.htm file to ControlPoint
ECHO Copy Readme*.htm ... 
ECHO Copy Readme*.htm ... >> %logFile%
xcopy %ReadmeSource%\readme*.htm %manualDestination%
ECHO Finished copying Readme.htm manuals 
ECHO Finished copying Readme.htm >> %logFile%

ECHO Finished Copying the manuals 
ECHO Finished Copying the manuals >> %logFile%