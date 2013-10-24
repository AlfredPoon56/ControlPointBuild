@echo off

echo ***************  VSSProj='%VSSProj%'
ECHO Starting to get code from SourceSafe...
ECHO Starting to get code from SourceSafe... >> %logFile%

Rem ***** We will use the SPVER variable to determine if this was a 2007 or
Rem       2010 build.
set VSSHome=C:\Program Files\Microsoft Visual Studio\Common\VSS\win32
if "%SPVER%" == "2010" set VSSHome=C:\Program Files (x86)\Microsoft Visual SourceSafe


ECHO Getting code for SharepointDev...
ECHO Getting code for SharepointDev... >> %logFile%

set VssGet=GET

if Not "%1"=="" set VssGet=%VssGet% -Vl"%1"

set xcAdminProject=xcAdmin
rem if the CPver is not specified which implied CPnext. Change xcAdmin to cpPresentation.
if "%CPVer%" == "" set xcAdminProject=cpPresentation

cd %spDevDir%

rem Set Working Folder for SharepointDev
ECHO ss.exe WORKFOLD %VSSproj% %spDevDir%
ECHO set work folder to '%VSSproj%' >> %logFile%

"%VSSHome%\ss.exe" WORKFOLD %VSSproj% %spDevDir% >> %buildfile%

rem Get the code from SourceSafe for Sharepoint Dev
ECHO ss.exe %VssGet% %VSSproj% %spDevDir%
ECHO get source from VSS for project '%VSSproj%' >> %logFile%
"%VSSHome%\ss.exe" %VssGet% %VSSproj% -R -W >> %buildfile%

ECHO Finished getting code for SharepointDev
ECHO Finished getting code for SharepointDev >> %logFile%


ECHO Getting code for xcAdmin...
ECHO Getting code for xcAdmin... >> %logFile%
cd %axcelerHive%

rem Set Working Folder for xcAdmin
ECHO ss WORKFOLD %VSSproj%/%xcAdminProject% %axcelerHive%
ECHO ss WORKFOLD %VSSproj%/%xcAdminProject% %axcelerHive% >> %logFile%
"%VSSHome%\ss.exe" WORKFOLD %VSSproj%/%xcAdminProject% "%axcelerHive%" >> %buildfile%

rem Get the code from SourceSafe for xcAdmin
ECHO ss %VssGet% %VSSproj%/%xcAdminProject% %axcelerHive%
ECHO ss %VssGet% %VSSproj%/%xcAdminProject% %axcelerHive% >>  %logFile%
"%VSSHome%\ss.exe" %VssGet% %VSSproj%/%xcAdminProject% -R -W >> %buildfile%

ECHO Finished getting code for %xcAdminProject%
ECHO Finished getting code for %xcAdminProject% >> %logFile%

