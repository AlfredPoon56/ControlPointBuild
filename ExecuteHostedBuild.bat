@echo off
REm - Updated to work with Team Foundation Server.
Rem - Param 1 is the name of the TFS Workspace used to fetch the hosted sources. 
Rem -    the TFS login user and password are hard coded in the GetLatestTFS.bat file. 

Rem - p3 will be the location of the built sources. p4 is not used.
Rem - Sample call: 
Rem	Call "C:\ControlPoint_build\ExecuteHostedBuild.bat" Hosted apoon 0507.2010 20100507 Poirot_%spver% %1  $/SharePointDev 2010

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
CALL "C:\ControlPoint_Build\UScripts%spver%\SetEnvironmentVariables.bat" %1 %2 %7 %8

Echo 1. Continue with build on VSS project %VSSProj%.
Echo 2. Quit the build.  To change the Vss project, edit VSSproj in SetEnvironmentVariables.bat *****
CHOICE /C:12 /T 8 /D 1 /M "Enter a 1 to continue with the build or 2 to quit."
IF ERRORLEVEL == 2 goto end


ECHO ============================================================== > %logFile%
ECHO ============================================================== > %buildfile%
ECHO ControlPoint build process is starting on %DATE% at %TIME%... >> %logFile%
ECHO ControlPoint build process is starting on %DATE% at %TIME%... >> %buildfile%

rem IISreset so that the build directories (c:\SharepointDev and axceler hive) can be cleaned and repopulated.
rem (Not needed for Hosted build)
REM iisreset

rem Delete old workfolders and recreate in one before fetching from TFS.
set localFolder=%2%1
set spDevDir=c:\%localFolder%
set axcelerHive=c:\%localFolder%\Layouts\Axceler
RMDIR %spDevDir% /S /Q 

rem STEP 2: CREATE
MD %spDevDir%

REM ### copy the saved built files and refetch the language resources from TFS. ###
ECHO *******  You are about to perform a build on the VSS project %VSSProj% 

rem Get latest from source control system
Echo Get latest language resources from Source control system
echo Get latest language resources from source control >> %logfile%
rem If the variable cpBranch is defined, we are fetching off a TFS branch.
if Not "%cpBranch%" == "" set getSourceControl=GetLatestTFSHosted.bat

set GetLatestCmd="C:\ControlPoint_Build\Utility Scripts\%getSourceControl%"

rem if the GetFromLabel variable is set, we fetch the sources from that label.
rem  The GetFromLabel var is set in the caller of this script.
rem if not set, we will just pass a "" to the TFS batch script.
set GetLatestCmd=%GetLatestCmd% "%GetFromLabel%"
 
Echo %GetLatestCmd%
Echo %GetLatestCmd% >> %logFile%
CALL %GetLatestCmd%
if %ERRORLEVEL% NEQ 0 goto failed

rem Make files writable
echo Run MakeWriteable.bat >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\MakeWritable.bat"
if %ERRORLEVEL% NEQ 0 goto failed

rem Change the web.config from Web2010Client.config
del "%axcelerhive%\web.config"
rename "%axcelerhive%\webclient.config" web.config

rem if Obfuscate=NO then copy the Not_Obfuscate*.bat to be Obfuscate*.bat.
if "%Obfuscate%"=="" goto NextStep
copy /Y "%spDevDir%\xcAdminUtils\Not_ObfuscateDLL.bat" "%spDevDir%\xcAdminUtils\ObfuscateDLL.bat"
copy /Y "%spDevDir%\xcAdminUtils\Not_ObfuscateEXE.bat" "%spDevDir%\xcAdminUtils\ObfuscateEXE.bat"
set Obfuscate=

:NextStep
rem Update the version numbers
Echo Update the Version Numbers
Echo Update the Version Numbers >> %logfile%
%VS% "C:\ControlPoint_Build\UScripts%spver%\Deployment.sln" /BUILD Debug      
CALL "C:\ControlPoint_Build\UScripts%spver%\Deployment\bin\Debug\Deployment.exe" %3 %4 %localFolder%
if %ERRORLEVEL% NEQ 0 goto failed

:_buildit
rem Compile visual studio solutions. The compile command "VS" is set up in the SetEnvironmentVariables.bat file.
set HostedSolutionsDir=%spDevDir%\Layouts\axceler\PTAdmin

Rem Build the sandbox solution for 2013. (There was no change between 2010 and 2013.)
Echo "    ControlPoint Hosted..."
%vs% %HostedSolutionsDir%\CPDevHosted2010.sln /ReBuild Release >> %buildfile%
if %ERRORLEVEL% NEQ 0 goto failed
%vs% %HostedSolutionsDir%\CPDevHosted2010.sln /Clean Release >> %buildfile%

:SkipHostedBuild
Echo "    On Premises CP Client..."
%vs% %HostedSolutionsDir%\ControlPointBuild%spver%Online.sln /ReBuild Release >> %buildfile%
if %ERRORLEVEL% NEQ 0 goto failed

Rem Copy the online help from the \\axsource folder.
Echo Copying Help files to the Online HIVE help directory, ".\layouts\axceler\help"
md "%axcelerhive%\Help"
xcopy /e /y "\\axsource\SourceSafe\DOCS\ControlPointOnline%DocVer%\ControlPoint Online Help" "%axcelerhive%\Help\"
 
:ISbuild
rem Compile and build InstallShield projects
Echo Compile and build InstallShield Projects
Echo Compile and build InstallShield Projects >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CompileInstallShieldProjects.bat" Hosted
if %ERRORLEVEL% NEQ 0 goto failed


:_copyBuild
rem Copy the results of the build to axstore
Echo Copy build to axstore
Echo Copy build to axstore >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CopyHostedBuildProducts.bat" %5 %6
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