@echo off

ECHO Compiling Solutions...
ECHO Compiling Solutions... >> %logFile%
SET totalerror=0

rem NOTE: devenv.exe only seems to work with the fully qualified path names.  Variables seem to screw things up.

rem Compile xcAdmin2010.sln
ECHO Starting xcAdmin2010.sln...
ECHO Starting xcAdmin2010.sln... >> %logFile%
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\Program Files\Common Files\Microsoft Shared\web server extensions\14\TEMPLATE\LAYOUTS\axceler\PTAdmin\ControlPointBuild2010%PURE%.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
echo totalerror : %totalerror%
ECHO Starting Finished xcAdmin2010.sln
ECHO Starting Finished xcAdmin2010.sln >> %logFile%

rem Compile ControlPointInstallCheck2010.sln
ECHO Starting ControlPointInstallCheck2010.sln...
ECHO Starting ControlPointInstallCheck2010.sln... >> %logFile%
"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv" "C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck2010.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
echo totalerror : %totalerror% >> %logFile%
echo totalerror : %totalerror%

ECHO Starting Finished ControlPointInstallCheck2010.sln
ECHO Starting Finished ControlPointInstallCheck2010.sln >> %logFile%

if "%cpVer%"=="" goto skipAddons
ECHO Create ControlPointAddOn.wsp file
ECHO Create ControlPointAddOn.wsp file >> %logFile%
cd C:\SharepointDev\AddOns
WspBuilder.exe

:skipAddons
set /a totalerror+=%ERRORLEVEL%
echo totalerror : %totalerror%
echo totalerror : %totalerror% >> %logFile%
cd "C:\ControlPoint_Build"
rem CALL "C:\SharepointDev\AddOns\WSPBuilder.exe" >> %logFile%

ECHO Finished Compiling Solutions
ECHO Finished Compiling Solutions >> %logFile%

:end
