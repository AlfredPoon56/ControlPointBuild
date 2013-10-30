@echo on

REM Arg 1 and 2 are mandatory.

if "%2"=="" goto arg_required

rem Clear the cpver setting for all v.next builds.
set cpver=
set cpBranch=CPV5.2
set GetFromLabel=

Rem Set Documentation version to 5.2  (Leave it blank for now)
set DocVer=5.2

rem Arg 2 is for sp2007, sp2010, or sp2013 build. (2007), (2010), or (2013)
set spver=%2

rem arg 3 (label) may contain spaces, i.e. quoted strings. Remove the quotes.
set arg3=%3
for /f "useback tokens=*" %%a in ('%arg3%') do set arg3=%%~a

Rem if arg3 is not blank, it is a label name off the ControlPointDev (trunk) branch.
if Not "%arg3%" == "" set GetFromLabel=%arg3%

set useVS=2010
Rem Use VS2012 for sp2013 builds
if "%spver%"=="2013" (
  set useVS=2012
  rem set global variable for a no obfuscation build.
  Rem set Obfuscate=NO
)
if "%spver%"=="2007" (
  rem set global variable for a no obfuscation build.
  rem set Obfuscate=NO
)

cd C:\Controlpoint_build
Call "C:\ControlPoint_build\ExecuteBuild.bat" TFS apoon 0507.2010 20100507 BlackStone_%spver% %1  $/SharePointDev %useVS%

Rem Backup the Smart Assembly mapping database (database.mdb)
set SaDb="C:\ProgramData\Red Gate\SmartAssembly\Database.mdb"
if "%2"=="2007" set SaDb="C:\Program Files\Red Gate\SmartAssembly 6\Database.mdb"

xcopy /y %SaDb% \\axstore\Development\Builds\ControlPoint\SA_Map_Database_%spver%\*.*

goto end

:arg_required
echo Please supplied arg 1 = (nightly or build date), arg 2 = (2007, 2010, or 2013)

:end