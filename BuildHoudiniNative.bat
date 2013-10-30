@echo on

REM Arg 1 and 2 are mandatory.

if "%2"=="" goto arg_required

rem Clear the cpver setting for all v.next builds.
set cpver=
set cpBranch=
set GetFromLabel=
set PURE=Pure
set Obfuscate=NO

Rem Set Documentation version to 5.0  (Leave it blank for now)
set DocVer=5.1

rem Arg 2 is for sp2007 or sp2010 build. (2007) or (2010)
set spver=%2

if "%spver%" == "2010" set MSOCAFKit=Shell


rem arg 3 (label) may contain spaces, i.e. quoted strings. Remove the quotes.
set arg3=%3
for /f "useback tokens=*" %%a in ('%arg3%') do set arg3=%%~a

Rem if arg3 is not blank, it is a label name off the ControlPointDev branch.
if Not "%arg3%" == "" set GetFromLabel=%arg3%

cd C:\Controlpoint_build
Call "C:\ControlPoint_build\ExecuteBuild.bat" TFS apoon 0507.2010 20100507 Houdini_%spver%_Native %1_N  $/SharePointDev 2010

Rem Clear the "PURE" and "MsocafKit" variables.
set PURE=
set MSOCAFKit=

Rem Backup the Smart Assembly mapping database (database.mdb)
if "%2"=="2010" set SaDb="C:\ProgramData\Red Gate\SmartAssembly\Database.mdb"
if "%2"=="2007" set SaDb="C:\Program Files\Red Gate\SmartAssembly 6\Database.mdb"

xcopy /y %SaDb% \\axstore\Development\Builds\ControlPoint\Houdini_%spver%_Native\SA_Map_Database\*.*

goto end

:arg_required
echo Please supplied arg 1 = (nightly or build date), arg 2 = (2007 or 2010)

:end