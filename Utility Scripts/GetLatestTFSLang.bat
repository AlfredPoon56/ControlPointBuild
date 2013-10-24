@echo on
rem -- This file is used for Fetching TFS sources from a branch and make all preparations for the build.
rem -- Run the batch file to set up the VS environment which also defines
rem -- the TFS commandline commands. We will be using the Workspace with the same name as the branch.
if "%spver%"=="2010" call "C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86
if "%spver%"=="2007" call "C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" x86

rem -- Set the tfs user name and password.
set tfsUser=Metalogix\TfsBuild
set tfspwd=Team@dm1n
rem Set the TFS Collection string
set tfsCollection=http://tfs11.metalogix.internal:8080/tfs/AxcelerProjectcollection
rem get the branch name from the global variable.
set branchName=%cpBranch%
set tfsWorkspace=%branchName%%spVer%
set tfsComputer=cpbuild
if "%spVer%"=="2010" set tfsComputer=cpbuild2010

rem -- Building from a branch, re-prepare the directories.
rmdir "%spDevDir%" /S /Q
rmdir "%axcelerHive%" /S /Q
set spDevDirBranch=%spDevDir%_%branchName%
set axcelerHiveBranch=%axcelerHive%_%branchName%
md "%spDevDirBranch%"
md "%axcelerHiveBranch%"

ECHO Restore built project directories... >> %logFile%
rem copy the \sharepointdev folders
echo Copying the saved \SharePointDev build folder, this may take a while ....
xcopy /e /Y /Q %builtSources%\SharePointDev\*.* "%spDevDirBranch%"
echo Copying the saved axceler(HIVE) build folder, this may take a while ....
xcopy /e /Y /Q %builtSources%\Axceler\*.* "%axcelerHiveBranch%"
if %ERRORLEVEL% NEQ 0 goto failed

:buildCurrent
echo ***************  tfsWorkspace=%tfsWorkspace%
ECHO Starting to get sources from Team Foundation Server on AxTfs...
ECHO Starting to get sources from Team Foundation Server on AxTfs... >> %logFile%

ECHO Set TFS to use workspace %tfsWorkspace%
tf workspace %tfsWorkspace%;%tfsUser% /computer:%tfsComputer% /noprompt /collection:%tfsCollection% /login:%tfsUser%,%tfspwd%

ECHO TFS Workspace bindings are:
tf workfold /workspace:%tfsWorkspace% /login:%tfsUser%,%tfspwd%
tf workfold /workspace:%tfsWorkspace% /login:%tfsUser%,%tfspwd% >> %buildfile%


cd "%spDevDirBranch%"

set TFSGet=tf get
set FromVersion=Get Latest
if Not %1=="" set TFSGet=%TFSGet% /version:L%1
if Not %1=="" set FromVersion=Label %1

rem Get the code from TFS for SharepointDev and cpPresentation
ECHO getting sources from TFS for SharepointDev and cpPresentation from %FromVersion%
ECHO get sources from TFS for SharepointDev and cpPresentation from %FromVersion% >> %logFile%

rem %TFSGet% /force /recursive /login:%tfsUser%,%tfspwd% >> %buildfile%
%TFSGet% $/%branchName%/LanguageResources /force /recursive /login:%tfsUser%,%tfspwd% >> %buildfile%
%TFSGet% $/%branchName%/cpPresentation/App_Data/SupportedLanguages.txt /force /recursive /login:%tfsUser%,%tfspwd% >> %buildfile%
%TFSGet% $/%branchName%/xcSLClient1/xcSLClient1.csproj /force /recursive /login:%tfsUser%,%tfspwd% >> %buildfile%
cd c:\ControlPoint_build

rem -- Branch build, rename the target directories to the standard buildable HIVE and \SharepointDev.
echo ********* Renaming to SharePointDev and the (Hive) directories.
rename "%spDevDirBranch%" "SharePointDev"
rename "%axcelerHiveBranch%" "axceler"

:done
ECHO Finished getting code for SharepointDev and cpPresentation
ECHO Finished getting code for SharepointDev and cpPresentation >> %logFile%

