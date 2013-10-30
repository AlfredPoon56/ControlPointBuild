@echo off
REm - Updated to work with Team Foundation Server.
Rem - If param 1 is "TFS" than we fetch the sources from TFS.
Rem -    the TFS login user and password are hard coded in the GetLatestTFS.bat file. 

Rem - p3 will be the location of the built sources. p4 is not used.
Rem - Sample call: 
Rem	Call "C:\ControlPoint_build\ExecuteBuild.bat" LANGUAGE apoon 0507.2010 20100507 Poirot_%spver% %1  $/SharePointDev 2010

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
iisreset

rem goto _buildit

REM ### copy the Saved build sources to the target HIVE and SharepointDev folders.
CALL "C:\ControlPoint_Build\Utility Scripts\RefreshProjectDirectories.bat"
if %ERRORLEVEL% NEQ 0 goto failed

set builtSources=c:\BuildSources_%3

REM ### copy the saved built files and refetch the language resources from TFS. Both are done by GetLatestTFSLang.bat ###
ECHO *******  You are about to perform a build on the VSS project %VSSProj% 

rem Get latest from source control system
Echo Get latest language resources from Source control system
echo Get latest language resources from source control >> %logfile%
rem If the variable cpBranch is defined, we are fetching off a TFS branch.
if Not "%cpBranch%" == "" set getSourceControl=GetLatestTFSLang.bat

set GetLatestCmd="C:\ControlPoint_Build\Utility Scripts\%getSourceControl%"

rem if the GetFromLabel variable is set, we fetch the sources from that label.
rem  The GetFromLabel var is set in the caller of this script.
rem if not set, we will just pass a "" to the TFS batch script.
set GetLatestCmd=%GetLatestCmd% "%GetFromLabel%"
 
Echo %GetLatestCmd%
Echo %GetLatestCmd% >> %logFile%
CALL %GetLatestCmd%

if %ERRORLEVEL% NEQ 0 goto failed

rem ### Copy the xcAdminResource and the silverlight resources to the target build location.
set spDevLangDir=%spDevDir%\LanguageResources
set xcCommonCoreDir=%spDevDir%\xcCommonCore
set xcDiscoveryFeatureDir=%spDevDir%\xcDiscoveryFeature
set xcSLClient1Dir=%spDevDir%\xcSLClient1\Resources
xcopy /e /y %spDevLangDir%\French\xcSLClient1\*.* %xcSLClient1Dir%\*.*
xcopy /e /y %spDevLangDir%\French\xcCommonCoreResources\xcAdminResources.fr.resx %xcCommonCoreDir%\*.*
xcopy /e /y %spDevLangDir%\German\xcSLClient1\*.* %xcSLClient1Dir%\*.*
xcopy /e /y %spDevLangDir%\German\xcCommonCoreResources\xcAdminResources.de.resx %xcCommonCoreDir%\*.*

rem Compile visual studio solutions
Echo Just Compile the SilverLight VS solutions
Echo Just compile the SilverLight VS solutions >> %logfile%

REM ### Only compile the xcCommonCore and the xcSLClient1 projects. *can be common for both builds*
IF '%VSVER%' NEQ '2008' goto build2010
CALL "C:\ControlPoint_Build\UScripts%spver%\CompileSolutions.bat"
if '%totalerror%' NEQ '0' goto failed

:build2010
set vsCompiler="C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv.exe"
if not exist %vsCompiler% (
    set vsCompiler="C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv"
) else (
    set vsCompiler="C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv"
)

%vsCompiler% %spDevLangDir%\cpLanguageBuild.sln /Build Release 


Rem ### Repackage the AxcelerFeature.wsp file from xcDiscoveryFeature project's copybin.bat.
cd %spDevDir%\xcDiscoveryFeature
call copyBin.bat Release

echo Rebuilt the AxcelerFeature.wsp

:ISbuild
rem Compile and build InstallShield projects
Echo Compile and build InstallShield Projects
Echo Compile and build InstallShield Projects >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CompileInstallShieldProjects.bat"
if %ERRORLEVEL% NEQ 0 goto failed


:_copyBuild
rem Copy the results of the build to axstore
Echo Copy build to axstore
Echo Copy build to axstore >> %logfile%
CALL "C:\ControlPoint_Build\Utility Scripts\CopyBuildProducts.bat" %5 %6
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