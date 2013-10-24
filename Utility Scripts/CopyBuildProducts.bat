@echo off

Rem **** %1 contains either *_2007 or *_2010. Extract the right most 4 char to determine 
Rem      if this is a 2007 or 2010 build. 
Rem  We will use the SPVER variable for now.

if "%SPVER%" == "2013" set HiveNum=15
if "%SPVER%" == "2010" set HiveNum=14
if "%SPVER%" == "2007" set HiveNum=12

Rem ** Set up the DFeature and DFeatureBase variables. Now that the WSPBuilder has been decoupled from the xcDiscoveryFeature
Rem ** folder location.
set DFeature=xcDiscoveryFeature
set DFeatureBase=%DFeature%
Rem * If the xcFeatureBase folder exist, set up the DFeatureBase variable to there
if Exist c:\sharepointdev\xcFeatureBase\WSPBuilder\AxcelerFeatures.wsp set DFeatureBase=xcFeatureBase

Rem set the location of the AxcelerHIVE.
set AxcelerHIVE=C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\%HiveNum%\TEMPLATE\LAYOUTS\axceler

set CPRelease=%1

rem If cpver is not empty, prefix the release name with the cp version.
rem otherwise leave the cprelease string alone but set cpver to 4.3 tentatively.
if Not "%CPVer%"=="" (
  set CPRelease=%cpver%_%1
) else (
  set CPVer=4.3
)

set installDirectory="\\axstore\development\builds\ControlPoint\"%CPRelease%"\ControlPoint_"%2
set manualSource="C:\SharepointDev\Install\ControlPoint"
Rem set CMKit_Location=\\lee.northsydney.winapp.com.au\builds\ChangeManagerCurrentRelease
set CMCopyTo=%installDirectory%\Disk1\

Rem Get the name of the CM kit folder.
Rem Dir /b "%CMKit_Location%\Change Management*" > c:\CMKitFolder.txt
Rem set /p CMKitFolder=< c:\CMKitFolder.txt
Rem Del c:\CMKitFolder.txt

Echo CopyBuildProducts: copy files to '%installDirectory%'
if Not %logfile%=="" Echo CopyBuildProducts: copy files to '%installDirectory%'  >> %logFile%

rem Make install directory writeable
attrib %installDirectory%\*.* -R /s

Rem Delete the install directory.
rd "%installDirectory%" /S /Q

rem Create the install directory
MD %installDirectory%

rem For Native copy, just do the pdb files and then get out.
REM ****** Copy the pdb files
MD %installDirectory%\PDBFiles
xcopy "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\%HiveNum%\TEMPLATE\LAYOUTS\axceler\bin\*.pdb" %installDirectory%\PDBFiles /y
xcopy C:\SharepointDev\xcUtilities\bin\Release\xcUtilities.pdb %installDirectory%\PDBFiles /y
xcopy C:\SharepointDev\xcClient\bin\Release\xcClient.pdb %installDirectory%\PDBFiles /y
xcopy C:\SharepointDev\%DFeature%\bin\Release\*.pdb %installDirectory%\PDBFiles /y
xcopy C:\SharepointDev\xcCPPolicy\bin\Release\xcCPPolicy.pdb %installDirectory%\PDBFiles /y
Rem ** That's all we need to do for Native builds. **
if "%PURE%"=="Pure" goto wrapup

rem copy the Disk 1 folder
MD %installDirectory%\Disk1
xcopy "C:\SharepointDev\Install\ControlPoint\Media\Release\Disk Images\Disk1" %installDirectory%\Disk1 /y

echo on
rem Skip the CM copy for 2007 kits.
rem if %spver% == "2007" goto No_CM
rem MD %CMCopyTo% 
rem xcopy /e "%CMKit_Location%" %CMCopyTo% /y
Rem Delete the other CM installer in the kit.
rem if "%SPVER%"=="2010" (
rem   del /q "%CMCopyTo%\%CMKitFolder%\*2013.exe" 
rem ) else (
rem   del /q "%CMCopyTo%\%CMKitFolder%\*2010.exe"
rem )

:No_CM
rem copy the manuals to axstore
xcopy %manualSource%\*.pdf %installDirectory%\Disk1 /y
xcopy %manualSource%\*.zip %installDirectory%\Disk1 /y
xcopy C:\SharepointDev\Docs\Readme.htm %installDirectory%\Disk1 /y
xcopy C:\SharepointDev\Docs\Before_you_begin.pdf %installDirectory%\Disk1 /y

rem copy additional files
rem xcopy "C:\SharepointDev\Install\ControlPoint Prerequisites\Media\Release 2\Package\Prerequisites.exe" %installDirectory%\Disk1 /y

rem MD %installDirectory%\Disk1\images
rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\images %installDirectory%\Disk1\images /y

rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\autorun.ico %installDirectory%\Disk1 /y
rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\AUTORUN.INF %installDirectory%\Disk1 /y
rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\Index.hta %installDirectory%\Disk1 /y

MD %installDirectory%\Disk1\PreInstallValidation
xcopy C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\*.exe %installDirectory%\Disk1\PreInstallValidation /y
xcopy C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\*.exe.config %installDirectory%\Disk1\PreInstallValidation /y
xcopy C:\SharepointDev\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\*.dll %installDirectory%\Disk1\PreInstallValidation /y

MD %installDirectory%\Disk1\SupportTools
MD %installDirectory%\Disk1\SupportTools\SilentInstall

REM ******* Copy files the goes into the SupportTools folder.
rem ** xcUtilities **
xcopy C:\SharepointDev\xcUtilities\bin\Release\xcUtilities.exe %installDirectory%\Disk1\SupportTools /y
xcopy C:\SharepointDev\xcUtilities\bin\Release\xcUtilities.exe.config %installDirectory%\Disk1\SupportTools /y
rem * supporting MS files *
xcopy C:\SharepointDev\xcUtilities\bin\Release\Microsoft.Practices.EnterpriseLibrary.Common.dll %installDirectory%\Disk1\SupportTools /y
xcopy C:\SharepointDev\xcUtilities\bin\Release\Microsoft.Practices.EnterpriseLibrary.Logging.dll %installDirectory%\Disk1\SupportTools /y
rem * supporting .dll files *
xcopy C:\SharepointDev\xcUtilities\bin\Release\xc*.dll %installDirectory%\Disk1\SupportTools /y

REM ** Silent Install files **
xcopy C:\SharepointDev\SilentInstall\*.iss* %installDirectory%\Disk1\SupportTools\SilentInstall /y
xcopy C:\SharepointDev\SilentInstall\CommandLineInstall.* %installDirectory%\Disk1\SupportTools\SilentInstall /y

REM ** MimeTypes modification VB Scripts. **
xcopy C:\SharepointDev\SilentInstall\AddSLMimeTypes.vbs %installDirectory%\Disk1\SupportTools /y

if "%CPVer%" LEQ "4.2" goto Pre45
REM ** Copy the Axceler Menus .xml files and the installation instructions into the LanguageKits folders.  (only for post 4.2)
MD "%installDirectory%\Disk1\LanguageKits\French Resources\Menus"
MD "%installDirectory%\Disk1\LanguageKits\German Resources\Menus" 

xcopy C:\SharepointDev\LanguageResources\French\AppData\*.xml "%installDirectory%\Disk1\LanguageKits\French Resources\Menus" /y
xcopy C:\SharepointDev\LanguageResources\German\AppData\*.xml "%installDirectory%\Disk1\LanguageKits\German Resources\Menus" /y
xcopy "C:\SharepointDev\LanguageResources\Localization_of_ControlPoint - Installation Instructions.docx" "%installDirectory%\Disk1\LanguageKits\French Resources" /y
xcopy "C:\SharepointDev\LanguageResources\Localization_of_ControlPoint - Installation Instructions.docx" "%installDirectory%\Disk1\LanguageKits\German Resources" /y

:Pre45
REM ****** Copy files for Manual Install
MD %installDirectory%\Disk1\ManualInstall
MD "%installDirectory%\Disk1\ManualInstall\1. Create xcAdmin"
MD "%installDirectory%\Disk1\ManualInstall\2. Create Axceler WAP"
MD "%installDirectory%\Disk1\ManualInstall\\3. Deploy solution"
MD "%installDirectory%\Disk1\ManualInstall\4. License Manager"

xcopy /e C:\ControlPoint_Build\ManualInstall\*.* %installDirectory%\Disk1\ManualInstall /y

REM ****** Copy the Sample Dashboard files, for 2010 only
if "%SPVER%" == "2010" (
  MD "%installDirectory%\Disk1\SampleDashboard"
  xcopy /e C:\SharepointDev\SampleDashboard\*.* %installDirectory%\Disk1\SampleDashboard /y
)

rem ** SQL scripts **
if "%CPVer%" LEQ "4.2" (
  xcopy  "C:\SharepointDev\xcAdminCore\script_xcAdminCreate.sql" "%installDirectory%\Disk1\ManualInstall\1. Create xcAdmin" /y
  xcopy  "C:\SharepointDev\xcAdminCore\script_xcAdminUpdate.sql" "%installDirectory%\Disk1\ManualInstall\1. Create xcAdmin" /y
) else (
  xcopy  "C:\SharepointDev\xcAdminCoreC\script_xcAdminCreate.sql" "%installDirectory%\Disk1\ManualInstall\1. Create xcAdmin" /y
  xcopy  "C:\SharepointDev\xcAdminCoreC\script_xcAdminUpdate.sql" "%installDirectory%\Disk1\ManualInstall\1. Create xcAdmin" /y
)

rem ** DiscoveryFeature deployment packages. Get them from xcFeatureBase if folder exist**
xcopy  "C:\SharepointDev\%DFeatureBase%\package\ActivateSolutionPackage.cmd" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\%DFeatureBase%\package\DeleteSolutionPackage.cmd" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\%DFeatureBase%\package\DeploySolutionPackage.cmd" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\%DFeatureBase%\package\DeleteControlPointHelpPackage.cmd" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\%DFeatureBase%\package\DeployControlPointHelpPackage.cmd" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\%DFeatureBase%\package\WaitForAdmJob.ps1" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\%DFeatureBase%\WSPBuilder\AxcelerFeatures.wsp" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\WspBuilderHelp\WSPBuilderHelp\ControlPointHelpFeature.wsp" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y
xcopy  "C:\SharepointDev\CreateVirtDirectory\CreateVirtDirectory\bin\Release\CreateVirtDirectory.exe" "%installDirectory%\Disk1\ManualInstall\3. Deploy solution" /y

rem ** xcClient License Manager **
xcopy "C:\SharepointDev\xcClient\bin\Release\*.exe" "%installDirectory%\Disk1\ManualInstall\4. License Manager" /y
xcopy "C:\SharepointDev\xcClient\bin\Release\*.config" "%installDirectory%\Disk1\ManualInstall\4. License Manager" /y
xcopy "C:\SharepointDev\xcClient\bin\Release\*.dll" "%installDirectory%\Disk1\ManualInstall\4. License Manager" /y
xcopy "C:\SharepointDev\ThirdParty\Microsoft Licensing\*.*" "%installDirectory%\Disk1\ManualInstall\4. License Manager" /y


REM ****** Create and copy to Patch Components folder
md "%installDirectory%\Patch Components\bin"
@Echo on
xcopy "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\%HiveNum%\TEMPLATE\LAYOUTS\axceler\bin\xc*.dll" "%installDirectory%\Patch Components\bin" /y
xcopy "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\%HiveNum%\TEMPLATE\LAYOUTS\axceler\bin\cp*.dll" "%installDirectory%\Patch Components\bin" /y
@echo off

REM ****** Create and copy to Localization Resources folder
md "%installDirectory%\Localization Resources\App_Data"
md "%installDirectory%\Localization Resources\App_GlobalResources"
md "%installDirectory%\Localization Resources\App_LocalResources"
md "%installDirectory%\Localization Resources\ControlPointMenu"
md "%installDirectory%\Localization Resources\ControlPointSiteAdminMenu"
md "%installDirectory%\Localization Resources\xcSLClient1\Resources"

Rem ** Conditionalize the xcAdmin variable for pre and post V4.2.
if "%CPver%" LEQ "4.2" (
  set xcAdmin=xcAdmin
) else (
  set xcAdmin=cpPresentation
)

xcopy "%AxcelerHIVE%\App_Data\FarmActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\WAPActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\SiteActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\WebActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\ListActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\Tools.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\ManageCP.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\SiteAdminActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\USERActions.xml" "%installDirectory%\Localization Resources\App_Data" /y
xcopy "%AxcelerHIVE%\App_Data\settings.xml" "%installDirectory%\Localization Resources\App_Data" /y

xcopy "%AxcelerHIVE%\App_GlobalResources\*.resx" "%installDirectory%\Localization Resources\App_GlobalResources" /y
xcopy "%AxcelerHIVE%\App_LocalResources\*.resx" "%installDirectory%\Localization Resources\App_LocalResources" /y

xcopy "C:\SharepointDev\xcSLClient1\Resources\*Resource.resx" "%installDirectory%\Localization Resources\xcSLClient1\Resources" /y 

rem xcopy "C:\SharepointDev\AddOns\12\TEMPLATE\FEATURES\ControlPointMenu" "%installDirectory%\Localization Resources" /y
xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\12\TEMPLATE\FEATURES\ControlPointMenu "%installDirectory%\Localization Resources\ControlPointMenu" /y
xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\12\TEMPLATE\FEATURES\ControlPointSiteAdminMenu "%installDirectory%\Localization Resources\ControlPointSiteAdminMenu" /y
xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\12\Resources\AxcelerResources.resx "%installDirectory%\Localization Resources\ControlPointSiteAdminMenu\*.*" /y

Rem ****** In post V4.2, some resource files have been moved. Copy those now.
if "%CPver%" LEQ "4.2" goto cleanup
md "%installDirectory%\Localization Resources\Helper\App_LocalResources"
md "%installDirectory%\Localization Resources\MasterPages\App_LocalResources"
md "%installDirectory%\Localization Resources\UserControls\App_LocalResources"
xcopy "%AxcelerHIVE%\Helper\App_LocalResources\*.resx" "%installDirectory%\Localization Resources\Helper\App_LocalResources" /y
xcopy "%AxcelerHIVE%\MasterPages\App_LocalResources\*.resx" "%installDirectory%\Localization Resources\MasterPages\App_LocalResources" /y
xcopy "%AxcelerHIVE%\UserControls\App_LocalResources\*.resx" "%installDirectory%\Localization Resources\UserControls\App_LocalResources" /y
Rem **** The xcAdminResources.resx has been moved from cpPresentation to xcCommonCore. Copy it from the xcCommomCore project.
xcopy C:\SharepointDev\xcCommonCore\xcAdminResources.resx "%installDirectory%\Localization Resources\App_GlobalResources\*.*"

Rem **** Remove the Russian resources from the Localization Resourecs folder. ****
del "%installDirectory%\Localization Resources\MasterPages\App_LocalResources\*.ru.resx"
del "%installDirectory%\Localization Resources\App_LocalResources\*.ru.resx"
del "%installDirectory%\Localization Resources\App_GlobalResources\*.ru.resx"

Rem -- no need to translate the help.resx since it just references html files.
del "%installDirectory%\Localization Resources\App_GlobalResources\Help.resx"

:cleanup
REM ****** Build final cleanup. 
del "%installDirectory%\Disk1\ManualInstall\4. License Manager\Telerik.Web.UI.dll"
del "%installDirectory%\Disk1\ManualInstall\4. License Manager\vssver.scc"

Rem *** Don't do any automated install for 2007.
if "%SPVER%" == "2007" goto wrapup

Rem *** If this was a nightly build, start the automatedInstall of controlPoint.
if /I "%2"=="Nightly" (
  SchTasks /Run /TN "AutomatedInstall"
  Echo "*** The Automated Installation of ControlPoint has been initiated. ***"
)

:wrapup
Rem Copy the build logs to \\axstore
xcopy "C:\Controlpoint_Build\Build Log\Build.txt" "\\axstore\Development\Temp" /y
xcopy "C:\Controlpoint_Build\Build Log\Log.txt" "\\axstore\Development\Temp" /y

