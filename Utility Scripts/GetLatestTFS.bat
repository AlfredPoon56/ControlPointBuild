@echo on

rem -- Run the batch file to set up the VS environment which also defines
rem -- the TFS commandline commands.
if "%spver%"=="2010" call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
if "%spver%"=="2007" call "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
if "%spver%"=="2013" call "C:\Program Files (x86)\Microsoft Visual Studio 11.0\VC\vcvarsall.bat" x86

rem -- Set the tfs user name and password.
set tfsUser=Metalogix\TfsBuild
set tfspwd=Team@dm1n
rem Set the TFS Collection string
set tfsCollection=http://tfs11.metalogix.internal:8080/tfs/AxcelerProjectcollection
set tfsWorkspace=cpbuild%spVer%
set tfsComputer=cpbuild
set spDevDirPrev=%spDevDir%
if "%spVer%"=="2010" set tfsComputer=cpbuild2010
if "%spVer%"=="2013" set tfsComputer=cpbuild2013

rem -- If building prior version, change the workspace used and re-prepare the directories.
if "%cpVer%"=="" goto buildCurrent
rmdir "%spDevDir%" /S /Q
rmdir "%axcelerHive%" /S /Q
set spDevDirPrev=%spDevDir%_%cpVer%
set axcelerHivePrev=%axcelerHive%_%cpVer%
set tfsWorkspace=%tfsWorkspace%_%cpVer%
md "%spDevDirPrev%"
md "%axcelerHivePrev%"

:buildCurrent
echo ***************  tfsWorkspace=%tfsWorkspace%
ECHO Starting to get sources from Team Foundation Server...
ECHO Starting to get sources from Team Foundation Server... >> %logFile%

ECHO Set TFS to use workspace %tfsWorkspace%
tf workspace %tfsWorkspace%;%tfsUser% /computer:%tfsComputer% /noprompt /collection:%tfsCollection% /login:%tfsUser%,%tfspwd%

ECHO TFS Workspace bindings are:
tf workfold /workspace:%tfsWorkspace% /login:%tfsUser%,%tfspwd%
tf workfold /workspace:%tfsWorkspace% /login:%tfsUser%,%tfspwd% >> %buildfile%


cd "%spDevDirPrev%"

set TFSGet=tf get
set FromVersion=Get Latest
if Not %1=="" set TFSGet=%TFSGet% /version:L%1
if Not %1=="" set FromVersion=Label %1

rem Get the code from TFS for SharepointDev and cpPresentation
ECHO getting sources from TFS for SharepointDev and cpPresentation from %FromVersion%
ECHO get sources from TFS for SharepointDev and cpPresentation from %FromVersion% >> %logFile%

%TFSGet% /force /recursive /login:%tfsUser%,%tfspwd% >> %buildfile%
cd c:\ControlPoint_build

rem -- If building prior version, rename the target directories.
if "%cpVer%"=="" goto done
echo ********* Renaming to SharePointDev and the (Hive) directories.
rename "%spDevDirPrev%" "SharePointDev"
rename "%axcelerHivePrev%" "axceler"

:done
ECHO Finished getting code for SharepointDev and cpPresentation
ECHO Finished getting code for SharepointDev and cpPresentation >> %logFile%

