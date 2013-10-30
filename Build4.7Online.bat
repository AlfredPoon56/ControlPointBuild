@echo off

REM Arg 1 and 2 are mandatory.

if "%2"=="" goto arg_required

rem Clear the cpver setting for all v.next builds.
set cpver=
set cpBranch=NeroOnline%2
set GetFromLabel=

Rem Set Documentation version to 5.0. This is really the 4.7 Help Docs.
set DocVer=4.7

rem set global variable for a no obfuscation build.
rem set Obfuscate=NO

rem spver hard coded to 2010
set spver=2010

rem arg 3 (label) may contain spaces, i.e. quoted strings. Remove the quotes.
set arg3=%3
for /f "useback tokens=*" %%a in ('%arg3%') do set arg3=%%~a

Rem if arg3 is not blank, it is a label name off the Hosted branch.
if Not "%arg3%" == "" set GetFromLabel=%arg3%

cd C:\Controlpoint_build
Call "C:\ControlPoint_build\ExecuteHostedBuild.bat" %cpBranch% apoon 0507.2010 20100507 CP4.7_Online%2 %1  $/SharePointDev 2010

goto end

:arg_required
echo Please supplied arg 1 = (nightly or build date), arg 2 = (T(trunk) or C(Cust branch))

:end