@echo on

REM Arg 1 and 2 are mandatory. (Arg 1 = Kit name, Arg 3 = TFS branch to fetch the xlated resource files)

if "%3"=="" goto arg_required

rem Clear the cpver setting for all v.next builds.
set cpver=
set cpBranch=%3
set GetFromLabel=
set BuiltSources=V4.6_MR1_BuiltFromLabel

rem Arg 2 is for sp2007 or sp2010 build. (2007) or (2010)
set spver=%2

rem arg 4 Built sources directory.
if not "%4"=="" set BuiltSources=%4

Rem Arg 3 is for fetching from a released branch.
cd C:\Controlpoint_build
Call "C:\ControlPoint_build\ExecuteLanguageBuild.bat" TFS apoon %BuiltSources% 20100507 Mason_%spver% %1  $/SharePointDev 2010

goto end

:arg_required
echo Please supplied arg 1 = (nightly or build date), arg 2 = (2007 or 2010), arg 3 = (The TFS branch of the release to be rebuild)

:end