@echo off

ECHO Starting InstallShield Compilations...
ECHO Starting InstallShield Compilations... >> %logFile%

set product=

if Not "%1" == "" set product=%1

ECHO Compiling the ControlPoint%product% InstallShield Kit.
ECHO Compiling the ControlPoint%product% InstallShield Kit.  >> %logFile%

Set CPArch=STANDARD
if "%Pure%" == "Pure" set CPARCH=PURE

set ISVer=2010
Rem set all Poirot build to use Install Shield 2011
if "%cpver%" == "" set ISVer=2011

if "%spver%" == "2010" goto bld2010
if "%spver%" == "2013" goto bld2013
ECHO using InstallShield %ISVer%
ECHO using InstallShield %ISVer%  >> %logFile%
"C:\Program Files\InstallShield\%ISVer%\System\IsCmdBld.exe" -p "%spDevDir%\Install\ControlPoint Prerequisites\ControlPoint Prerequisites.ism" -r "Release 2" >> %buildfile%
"C:\Program Files\InstallShield\%ISVer%\System\IsCmdBld.exe" -p "%spDevDir%\Install\ControlPoint\ControlPoint%product%.ism" -r "Release" -D SPVERD=%SPVersionNumber% >> %buildfile%

goto end

:bld2010
set ISVer=2012
ECHO using InstallShield %ISVer%
ECHO using InstallShield %ISVer%  >> %logFile%
"C:\Program Files (x86)\InstallShield\%ISVer%\System\IsCmdBld.exe" -p "%spDevDir%\Install\ControlPoint Prerequisites\ControlPoint Prerequisites.ism" -r "Release 2" >> %buildfile%
"C:\Program Files (x86)\InstallShield\%ISVer%\System\IsCmdBld.exe" -p "%spDevDir%\Install\ControlPoint\ControlPoint%product%.ism" -r "Release" -D SPVERD=%SPVersionNumber% -D %CPARCH%=1 >> %buildfile%

goto end

:bld2013
set ISVer=2012
ECHO using InstallShield %ISVer%
ECHO using InstallShield %ISVer%  >> %logFile%
"C:\Program Files (x86)\InstallShield\%ISVer%\System\IsCmdBld.exe" -p "%spDevDir%\Install\ControlPoint Prerequisites\ControlPoint Prerequisites_is%ISVer%.ism" -r "Release 2" >> %buildfile%
"C:\Program Files (x86)\InstallShield\%ISVer%\System\IsCmdBld.exe" -p "%spDevDir%\Install\ControlPoint\ControlPoint%product%_is%ISVer%.ism" -r "Release" -D SPVERD=%SPVersionNumber% -D %CPARCH%=1 >> %buildfile%

:end
ECHO Finished InstallShield Compilations 
ECHO Finished InstallShield Compilations >> %logFile%
