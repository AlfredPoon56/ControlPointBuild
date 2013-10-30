@echo off
REm - Updated to work with Team Foundation Server.
Rem - If param 1 is "TFS" than we fetch the sources from TFS.
Rem -    the TFS login user and password are hard coded in the GetLatestTFS.bat file. 

IF "%1"=="" goto missingParameters
IF "%2"=="" goto missingParameters
IF "%3"=="" goto missingParameters
IF "%4"=="" goto missingParameters
IF "%5"=="" goto missingParameters
IF "%6"=="" goto missingParameters
IF "%7"=="" goto missingParameters
IF "%8"=="" goto missingParameters

REM add a 9th argument to copy the final build to axstore. This should be done after the 2007 and 2010 build are completed.
if "%9"=="" goto DoBuild
@echo on
CALL "C:\ControlPoint_Build\UScripts%spver%\CopySingleInstall.bat" %6
goto end

:DoBuild

ECHO Call SetEnvironmentVariables.bat
rem set global directory variables
rem The first input to the bat file is the suffix to the build log filename. For a Native build, pass in "Native"
Set LogSuffix=%1
If "%Pure%"=="Pure" Set LogSuffix=Native
CALL "C:\ControlPoint_Build\UScripts%spver%\SetEnvironmentVariables.bat" %LogSuffix% %2 %7 %8

ECHO *******  You are about to perform a build on the TFS project branch %cpBranch% 

Echo 1. Continue with build on VSS project %VSSProj%.
Echo 2. Quit the build.  To change the Vss project, edit VSSproj in SetEnvironmentVariables.bat *****
CHOICE /C:12 /T 8 /D 1 /M "Enter a 1 to continue with the build or 2 to quit."
IF ERRORLEVEL == 2 goto end


ECHO ============================================================== > %logFile%
ECHO ============================================================== > %buildfile%
ECHO ControlPoint build process is starting on %DATE% at %TIME%... >> %logFile%
ECHO ControlPoint build process is starting on %DATE% at %TIME%... >> %buildfile%

rem IISreset so that the build directories (c:\SharepointDev and axceler hive) can be cleaned and repopulated.
iisreset

rem goto _buildit

rem Refresh project directories
ECHO Refreshing project directories... >> %logFile%
CALL "C:\ControlPoint_Build\Utility Scripts\RefreshProjectDirectories.bat"
if %ERRORLEVEL% NEQ 0 goto failed

rem Get latest from source control system
Echo Get latest from Source control system
echo Get latest from source control >> %logfile%
set getSourceControl=GetLatest.bat
if "%1"=="TFS" set getSourceControl=GetLatestTFS.bat

rem If the variable cpBranch is defined, we are fetching off a TFS branch.
if Not "%cpBranch%" == "" set getSourceControl=GetLatestTFSbranch.bat

set GetLatestCmd="C:\ControlPoint_Build\Utility Scripts\%getSourceControl%"

rem if the GetFromLabel variable is set, we fetch the sources from that label.
rem  The GetFromLabel var is set in the caller of this script.
rem if not set, we will just pass a "" to the TFS batch script.
set GetLatestCmd=%GetLatestCmd% "%GetFromLabel%"
 
Echo %GetLatestCmd%
Echo %GetLatestCmd% >> %logFile%
CALL %GetLatestCmd%

if %ERRORLEVEL% NEQ 0 goto failed

if '%SPVER%' NEQ '2010' goto skipFolders
if '%VSVER%' NEQ '2010' goto skipFolders
Echo call prepare2010FoldersForCompile
Echo call prepare2010FoldersForCompile >> %logFile%
CALL "C:\ControlPoint_Build\Utility Scripts\Prepare2010FoldersForCompile.bat" %1

:skipFolders

rem Make files writable
echo Run MakeWriteable.bat >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\MakeWritable.bat"
if %ERRORLEVEL% NEQ 0 goto failed

rem If building a "Pure" kit for shell, used the Telerik control in the Thirdparty\Telerik\mso folder.
if "%PURE%"=="Pure" (
  copy /y "c:\SharepointDev\ThirdParty\Telerik\mso\*.*" "c:\SharepointDev\ThirdParty\Telerik\*.*"
)

rem if Obfuscate=NO then copy the Not_Obfuscate*.bat to be Obfuscate*.bat.
if "%Obfuscate%"=="" goto NextStep
copy /Y "C:\SharepointDev\xcAdminUtils\Not_ObfuscateDLL.bat" "C:\SharepointDev\xcAdminUtils\ObfuscateDLL.bat"
copy /Y "C:\SharepointDev\xcAdminUtils\Not_ObfuscateEXE.bat" "C:\SharepointDev\xcAdminUtils\ObfuscateEXE.bat"
set Obfuscate=

:NextStep
rem Update the version numbers
Echo Update the Version Numbers
Echo Update the Version Numbers >> %logfile%
%VS% "C:\ControlPoint_Build\UScripts%spver%\Deployment.sln" /BUILD Debug      
CALL "C:\ControlPoint_Build\UScripts%spver%\Deployment\bin\Debug\Deployment.exe" %3 %4
if %ERRORLEVEL% NEQ 0 goto failed

rem Copy the manuals
Echo Copy the Manuals
Echo Copy the Manuals >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CopyManuals.bat" %DocVer%
if %ERRORLEVEL% NEQ 0 goto failed

:_buildit
rem Compile visual studio solutions
Echo Compile VS solutions
Echo Compile VS solutions >> %logfile%

IF '%VSVER%' NEQ '2008' goto build2010
CALL "C:\ControlPoint_Build\UScripts%spver%\CompileSolutions.bat"
if '%totalerror%' NEQ '0' goto failed
goto compileDone

:build2010
IF '%VSVER%' NEQ '2010' goto build2012
CALL "C:\ControlPoint_Build\UScripts%spver%\CompileSolutionsVS2010.bat"
if %totalerror% NEQ 0 goto failed
goto compileDone

:build2012
CALL "C:\ControlPoint_Build\UScripts%spver%\CompileSolutionsVS2012.bat"
if %totalerror% NEQ 0 goto failed

:compileDone
rem Make the help solution file - ControlPointHelpFeature.wsp
echo Make the help solution file >> %logfile%
cd "C:\SharepointDev\WspBuilderHelp\WspBuilderHelp"
CALL "C:\SharepointDev\WspBuilderHelp\WspBuilderHelp\CopyHelp.bat" %SPVersionNumber% %DocVer%
cd "C:\ControlPoint_Build"

rem If it is a "Native"(pure) build, skip the IS kit creation. 
if "%PURE%"=="Pure" goto _copyBuild

:ISbuild
rem Compile and build InstallShield projects
Echo Compile and build InstallShield Projects
Echo Compile and build InstallShield Projects >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CompileInstallShieldProjects.bat"
if %ERRORLEVEL% NEQ 0 goto failed

:_SignImagesInManualInstall
rem Copy the results of the build to axstore
Echo Sign the images that go into the Manual Install folders
Echo Sign the images that go into the Manual Install folders >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\SignManualInstallImages.bat"

:_copyBuild
rem Copy the results of the build to axstore
Echo Copy build to axstore
Echo Copy build to axstore >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CopyBuildProducts.bat" %5 %6
if %ERRORLEVEL% NEQ 0 goto failed

rem Create a MSOCAF Kit for both 2010 and 2013.
if Not "%MSOCAFKit%" == "Shell" goto end
:_createMSOCAFkit
rem create a MSOCAF kit in axstore
Echo Create a MSOCAF Kit to axstore
Echo create a MSOCAF Kit to axstore >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CreateMSOCAFKit.bat" %SPVer%
if %ERRORLEVEL% NEQ 0 goto failed

goto end


rem stop process and spit out error messages
:failed
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO -------- A BUILD ERROR HAS OCCURED.  PLEASE SEE C:\Build\Build Log\Log.txt FOR DETAILS ---------- 
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

ECHO ERROR!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! >> %logFile% 
goto end

:missingParameters
ECHO MISSING PARAMETER: PLEASE ENTER A USERNAME, PASSWORD, PREVIOUS VERSION NUMBER FOR AssemblyInfo.cs, PREVIOUS VERSION NUMBER FOR SQL, RELEASE NAME and DATE-TAG
ECHO Build Failed due to missing parameters.

:end
cd C:\ControlPOint_build
ECHO ControlPoint Build completed
ECHO ControlPoint Build completed >> %logFile%
ECHO ============================================================== >> %logFile%