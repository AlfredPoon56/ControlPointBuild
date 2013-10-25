@echo off

ECHO Compiling Solutions...
ECHO Compiling Solutions... >> %logFile%
SET totalerror=0

rem NOTE: devenv.exe only seems to work with the fully qualified path names.  Variables seem to screw things up.

rem Compile xcAdmin2013.sln
ECHO Starting xcAdmin2013.sln...
ECHO Starting xcAdmin2013.sln... >> %logFile%
"C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv" "C:\Program Files\Common Files\Microsoft Shared\web server extensions\15\TEMPLATE\LAYOUTS\axceler\PTAdmin\ControlPointBuild2013%PURE%.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
echo totalerror : %totalerror%
ECHO Finished xcAdmin2013.sln
ECHO Finished xcAdmin2013.sln >> %logFile%

rem Compile ControlPointInstallCheck2013.sln
ECHO Starting ControlPointInstallCheck2013.sln...
ECHO Starting ControlPointInstallCheck2013.sln... >> %logFile%
"C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\devenv" "C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck2013.sln" /BUILD Release >> %buildfile%
set /a totalerror+=%ERRORLEVEL%
echo totalerror : %totalerror% >> %logFile%
echo totalerror : %totalerror%

ECHO Finished ControlPointInstallCheck2013.sln
ECHO Finished ControlPointInstallCheck2013.sln >> %logFile%

set /a totalerror+=%ERRORLEVEL%
echo totalerror : %totalerror%
echo totalerror : %totalerror% >> %logFile%
cd "C:\ControlPoint_Build"

ECHO Finished Compiling Solutions
ECHO Finished Compiling Solutions >> %logFile%

:end
