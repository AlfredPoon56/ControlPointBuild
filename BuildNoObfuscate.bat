@echo on

REM Arg 1 and 2 are mandatory.

if "%2"=="" goto arg_required

rem Clear the cpver setting for all v.next builds.
set cpver=
set cpBranch=
set GetFromLabel=

rem set global variable for a no obfuscation build.
set Obfuscate=NO

rem Arg 2 is for sp2007 or sp2010 build. (2007) or (2010)
set spver=%2

rem arg 4 (label) may contain spaces, i.e. quoted strings. Remove the quotes.
set arg4=%4
for /f "useback tokens=*" %%a in ('%arg4%') do set arg4=%%~a

Rem validate arg 3 and arg 4, they both must have a value or both must be blanks.
if Not "%arg4%" == "" goto continue
Rem arg 4 is blank then arg 3 must be blank
if "%3" == "" goto continue
echo Arg 4 must be the word (label), (branch), or name of a label in the branch.
goto end 

:continue
Rem Arg 3 is for fetching from a specified label or branch.
Rem Arg 4 if = "branch" then 3 is a branch, = "label" then 3 is a label, if neither then is a label to the branch.
if "%arg4%" == "label" (
 set GetFromLabel=%3
) else (
 set cpBranch=%3
 set GetFromLabel=%arg4%
)
  
if "%GetFromLabel%" == "branch" set GetFromLabel=

cd C:\Controlpoint_build
Call "C:\ControlPoint_build\ExecuteBuild.bat" TFS apoon 0507.2010 20100507 Mason_%spver% %1  $/SharePointDev 2010

Rem Backup the Smart Assembly mapping database (database.mdb)
if "%2"=="2010" set SaDb="C:\ProgramData\Red Gate\SmartAssembly\Database.mdb"
if "%2"=="2007" set SaDb="C:\Program Files\Red Gate\SmartAssembly 6\Database.mdb"

xcopy /y %SaDb% \\axstore\Development\Builds\ControlPoint\Mason_%2\SA_Map_Database\*.*

goto end

:arg_required
echo Please supplied arg 1 = (nightly or build date), arg 2 = (2007 or 2010)

:end