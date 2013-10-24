@echo off



echo ***************  VSSProj='%VSSProj%'
ECHO Rename folders for Visual Studio 2010...
ECHO Rename folders for Visual Studio 2010... >> %logFile%
echo on

del "%axcelerhive%\web.config"
rename "%axcelerhive%\web2010.config" web.config

cd %spDevDir%

if "%1"=="TFS" goto Done

rem -- In TFS the SP2010 Team Folders are mapped directly by the WORKSPACE.
rd /s /q AddOns
rd /s /q xcDiscoveryFeature
rd /s /q WspBuilderHelp

rename xcDiscoveryFeatureSP2010 xcDiscoveryFeature
rename AddonsSP2010 Addons
rename WspBuilderHelpSP2010 WspBuilderHelp
echo off

:Done
ECHO Finished renaming folders
ECHO  Finished renaming folders >> %logFile%
