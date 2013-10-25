@echo off
rem Set environment variables
set spDevDir=C:\SharepointDev
set axcelerHive=C:\Program Files\Common Files\Microsoft Shared\web server extensions\14\TEMPLATE\LAYOUTS\axceler
set ssdir=\\axsource\SourceSafe\BStormNT
set ssuser=%1
set sspwd=%2
set HostedSuffix=_%1
set Force_Dir=Yes	
set msBuildLocation="C:\WINDOWS\Microsoft.NET\Framework\v3.5"
set devEnvLocation=C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE

REM  set VSSProj=$/ControlPointBranches/ControlPoint_Release_3.5.1
REM set VSVER=2008
REM set VSSProj=$/ControlPointBranches/4.0_2010_SharepointDev

REM set VSVER=2010
REM set VSSProj=$/SharepointDev

Rem If called by called by the mainline build (Mason), clear hosted suffix for the logfile and buildfile names.
if "%1"=="TFS" set HostedSuffix=
set logFile="C:\ControlPoint_Build\Build Log\Log%HostedSuffix%.txt"
set buildfile="C:\ControlPoint_Build\Build Log\Build%HostedSuffix%.txt"

set VSSProj=%3
set VSVER=%4


set SPVersionNumber=14
set SingleBuild=%7

set SPVER=2010


if '%VSVER%' NEQ '2008' goto _2010Build

REM building with Visual Studio 2008
set VS="C:\Program Files (x86)\Microsoft Visual Studio 9.0\Common7\IDE\devenv"
set VSVER=2008
set SolutionFile=xcAdmin.sln
set xcUtilitiesSln=xcUtilities.sln
set set InstallCheckSln=ControlPointInstallCheck.sln
goto _end

:_2010Build

REM Building with Visual Studio 2010
set VS="C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv"
set VSVER=2010
set SolutionFile=ControlPointBuild2010.sln
set xcUtilitiesSln=xcUtilities2010.sln
set CreateVirtSln=CreateVirtDirectory2010.sln
set InstallCheckSln=ControlPointInstallCheck2010.sln


:_end

@echo off

echo Leave SetEnvironmentVariables
