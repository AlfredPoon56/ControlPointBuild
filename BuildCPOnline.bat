@echo off

REM Arg 1 and 2 are mandatory.

if "%2"=="" goto arg_required
if /I "%2"=="VNext" goto Start
if /I "%2"=="BlackStone" goto Start
if /I "%2"=="Bess" goto Start

goto arg_required

:Start
set KitLocation=%2
set DocVer=5.2
 
rem Clear the cpver setting for all v.next builds.
set cpver=
set cpBranch=%2Online
if /I "%2"=="VNext" set cpBranch=VNextOnline
if /I "%2"=="BlackStone" set cpBranch=BlackStoneOnline
if /I "%2"=="Bess" set cpBranch=BessOnline
set GetFromLabel=

Rem Set Documentation version to 5.1  (Leave it blank for now)

if /I "%2"=="Copperfield" set DocVer=5.0

rem spver hard coded to 2013
set spver=2013

rem arg 3 (label) may contain spaces, i.e. quoted strings. Remove the quotes.
set arg3=%3
for /f "useback tokens=*" %%a in ('%arg3%') do set arg3=%%~a

Rem if arg3 is not blank, it is a label name off the Hosted branch.
if Not "%arg3%" == "" set GetFromLabel=%arg3%

set useVS=2010
Rem Use VS2012 for sp2013 builds
if "%spver%"=="2013" (
  set useVS=2012
  rem set global variable for a no obfuscation build.
  rem set Obfuscate=NO
)

cd C:\Controlpoint_build
Call "C:\ControlPoint_build\ExecuteHostedBuild.bat" Online %2 0507.2010 20100507 %KitLocation%_%spver%-Online %1_OL  $/SharePointDev %useVS%

goto end

:arg_required
echo Please supplied arg 1 = (nightly or build date), arg 2 = (Bess or BlackStone)

:end