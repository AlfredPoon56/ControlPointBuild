@echo off

ECHO Compiling Solutions...
ECHO Compiling Solutions... >> %logFile%
SET totalerror=0

rem NOTE: devenv.exe only seems to work with the fully qualified path names.  Variables seem to screw things up.

rem Compile xcAdmin.sln
ECHO Starting xcAdmin.sln...
ECHO Starting xcAdmin.sln... >> %logFile%
"C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv" "C:\Program Files\Common Files\Microsoft Shared\web server extensions\14\TEMPLATE\LAYOUTS\axceler\PTAdmin\xcAdmin.sln" /BUILD Release >> %buildfile%
SET /A totalerror+=%ERRORLEVEL%
ECHO Starting Finished xcAdmin.sln
ECHO Starting Finished xcAdmin.sln >> %logFile%

rem Compile ControlPointInstallCheck.sln
ECHO Starting ControlPointInstallCheck.sln...
ECHO Starting ControlPointInstallCheck.sln... >> %logFile%
"C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv" "C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck.sln" /BUILD Release >> %buildfile%
SET /A totalerror+=%ERRORLEVEL%
ECHO Starting Finished ControlPointInstallCheck.sln
ECHO Starting Finished ControlPointInstallCheck.sln >> %logFile%

ECHO Create ControlPointAddOn.wsp file
ECHO Create ControlPointAddOn.wsp file >> %logFile%
cd C:\SharepointDev\AddOns
WspBuilder.exe
SET /A totalerror+=%ERRORLEVEL%
cd "C:\ControlPoint_Build"

ECHO Finished Compiling Solutions
ECHO Finished Compiling Solutions >> %logFile%

:end
