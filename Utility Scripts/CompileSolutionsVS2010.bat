@echo off

ECHO Compiling Solutions VS2010...
ECHO Compiling Solutions VS2010... >> %logFile%
SET totalerror=0

rem NOTE: devenv.exe only seems to work with the fully qualified path names.  Variables seem to screw things up.

Rem Define the solution file to be used based on the version of controlpoint being build.
set bldSolution=xcAdminBuild2007.sln
if "%cpVer%"== "" set bldSolution=PTAdmin\ControlPointBuild2007.sln

rem Compile xcAdminBuild2007.sln
ECHO Starting %bldSolution%...
ECHO Starting %bldSolution%... >> %logFile%
"C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\Program Files\Common Files\Microsoft Shared\web server extensions\12\TEMPLATE\LAYOUTS\axceler\%bldSolution%" /REBUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
ECHO Starting Finished %bldSolution%
ECHO Starting Finished %bldSolution% >> %logFile%
echo Errorlevel: %ERRORLEVEL%
echo totalerror: %totalerror%

rem Compile ControlPointInstallCheck2007.sln
ECHO Starting ControlPointInstallCheck2007.sln...
ECHO Starting ControlPointInstallCheck2007.sln... >> %logFile%
"C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck\ControlPointInstallCheck2007.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
ECHO Starting Finished ControlPointInstallCheck2007.sln
ECHO Starting Finished ControlPointInstallCheck2007.sln >> %logFile%
echo Errorlevel: %ERRORLEVEL%
echo totalerror: %totalerror%

REM *** The follow compiles are not needed for poirot.
if "%cpver%"=="" goto Done
rem Compile xcUtilities2007.sln
ECHO Starting xcUtilities2007.sln...
ECHO Starting xcUtilities2007.sln... >> %logFile%
"C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\SharepointDev\xcUtilities\xcUtilities2007.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
ECHO Starting Finished xcUtilities2007.sln
ECHO Starting Finished xcUtilities2007.sln >> %logFile%
echo Errorlevel: %ERRORLEVEL%
echo totalerror: %totalerror%

rem Compile C:\SharepointDev\CreateVirtDirectory
ECHO Starting C:\SharepointDev\CreateVirtDirectory...
ECHO Starting C:\SharepointDev\CreateVirtDirectory... >> %logFile%
"C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\SharepointDev\CreateVirtDirectory\CreateVirtDirectory2007.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
ECHO Starting Finished CreateVirtDirectory2007.sln
ECHO Starting Finished CreateVirtDirectory2007.sln >> %logFile%
echo Errorlevel: %ERRORLEVEL%
echo totalerror: %totalerror%

goto Done
rem Compile C:\SharepointDev\AddOns\CodePlexInstallerForSP2007\SharePoint Solution Installer.sln
ECHO Starting C:\SharepointDev\AddOns\CodePlexInstallerForSP2007\SharePoint Solution Installer.sln...
ECHO Starting C:\SharepointDev\AddOns\CodePlexInstallerForSP2007\SharePoint Solution Installer.sln... >> %logFile%
"C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\SharepointDev\AddOns\CodePlexInstallerForSP2007\SharePoint Solution Installer.sln" /BUILD Release >> %buildfile%
xcopy "C:\SharepointDev\AddOns\CodePlexInstallerForSP2007\Source\bin\Release\setup.exe*" "C:\SharepointDev\AddOns" /y
ECHO Starting Finished SharePoint Solution Installer.sln
ECHO Starting Finished SharePoint Solution Installer.sln >> %logFile%
echo Errorlevel: %ERRORLEVEL%
echo totalerror: %totalerror%


ECHO Create ControlPointAddOn.wsp file
ECHO Create ControlPointAddOn.wsp file >> %logFile%
cd C:\SharepointDev\AddOns
WspBuilder.exe

:Done
set /a totalerror+=%ERRORLEVEL%
cd "C:\ControlPoint_Build"
rem CALL "C:\SharepointDev\AddOns\WSPBuilder.exe" >> %logFile%

ECHO Finished Compiling Solutions
ECHO Finished Compiling Solutions >> %logFile%
echo Errorlevel: %ERRORLEVEL%
echo totalerror: %totalerror%

:end
