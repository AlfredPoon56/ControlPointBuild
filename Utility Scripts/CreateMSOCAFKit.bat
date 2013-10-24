Rem ** This batch file creates an MSOCAF kit as a set of files in the required MSOCAF folder 
Rem ** tree to be used for Shell's Office-365 DedicatedOnline and OnPremises environment.
Rem ** It also creates a ControlPoint V5.0.1 Native kit for customers who have SharePoint 
Rem ** Claims/Custom Claims Web Applications or DedicatedOnline environments that does not
Rem ** need to be MSOCAF certified.

Rem ** Now the script is being used by 2010 and 2013 Native builds, we need to know the SP Version.
Rem ** This is being passed in using P1.
set NativeKit=%1

Rem ** Set up the DFeature and DFeatureBase variables. Now that the WSPBuilder has been decoupled from the xcDiscoveryFeature
Rem ** folder location.
set DFeatureBase=xcDiscoveryFeature2010Pure
Rem * If the xcFeatureBase folder exist, set up the DFeatureBase variable to there
if Exist c:\sharepointdev\xcFeatureBase\WSPBuilder\AxcelerFeatures.wsp set DFeatureBase=xcFeatureBase

Rem *************************************** Create the MSOCAF folder tree **
MD %installDirectory%\MSOCAF_Kit
MD %installDirectory%\MSOCAF_Kit\Root
MD %installDirectory%\MSOCAF_Kit\Root\"Release documents"
MD %installDirectory%\MSOCAF_Kit\Root\"Solutions artifacts"
MD %installDirectory%\MSOCAF_Kit\Root\"Installation scripts"
MD %installDirectory%\MSOCAF_Kit\Root\"Test documents"
MD %installDirectory%\MSOCAF_Kit\Root\"Source code"
MD %installDirectory%\MSOCAF_Kit\Root\"Caf Reports"

set RD=%installDirectory%\MSOCAF_Kit\Root\"Release documents"
set SA=%installDirectory%\MSOCAF_Kit\Root\"Solutions artifacts"
set IS=%installDirectory%\MSOCAF_Kit\Root\"Installation scripts"
set TD=%installDirectory%\MSOCAF_Kit\Root\"Test documents"
set SC=%installDirectory%\MSOCAF_Kit\Root\"Source code"
set CR=%installDirectory%\MSOCAF_Kit\Root\"Caf Reports"

Rem Sign the PowerShell Script.
set SignTool=c:\SharepointDev\Install\SignTool.exe
set CertFile=c:\SharepointDev\Install\CodeSigningCertificate.pfx
set Pwd=sharepoint2010
set SignArgs=sign /f %CertFile% /p %Pwd% /t %Ts%
%Signtool% %SignArgs% c:\SharepointDev\MSOCAF\WaitForAdmJob.ps1

Rem ** Begin to move files.
Rem (Installation Scripts folder)
xcopy c:\SharepointDev\MSOCAF\*.cmd %IS% /y
xcopy c:\SharepointDev\MSOCAF\*.ps1 %IS% /y
xcopy C:\SharepointDev\xcClient\bin\Release\*.dll  %IS% /y
xcopy C:\SharepointDev\xcClient\bin\Release\*.exe  %IS% /y
xcopy C:\SharepointDev\xcClient\bin\Release\*.xml  %IS% /y
xcopy C:\SharepointDev\xcClient\bin\Release\*.config  %IS% /y
xcopy C:\SharepointDev\SPInstaller\Development\Source\bin\Release\ControlPointInstall.exe.config %IS% /y
xcopy C:\SharepointDev\SPInstaller\Development\Source\bin\Release\ControlPointInstall.exe %IS% /y
xcopy C:\SharepointDev\SPInstaller\Development\Source\bin\Release\InstallerChecks.dll %IS% /y
xcopy C:\SharePointDev\xcAdminCoreC\script_xcAdminCreate.sql %IS% /y
xcopy C:\SharePointDev\xcAdminCoreC\script_xcAdminUpdate.sql %IS% /y
xcopy C:\SharePointDev\xcAdminCoreC\script_xcAdminRights.sql %IS% /y
xcopy "C:\SharePointDev\ThirdParty\Microsoft Licensing\Microsoft.Licensing.LicAdmin.*" %IS% /y
xcopy "C:\SharePointDev\ThirdParty\Microsoft Licensing\Microsoft.Licensing.Permutation*.*" %IS% /y

Rem (Test Doc and CAF Reports)
xcopy "c:\SharepointDev\MSOCAF\Caf Reports\*.*" %CR% /y
xcopy "c:\SharepointDev\MSOCAF\Test documents\*.*" %TD% /y

Rem (Release documents folder)
Rem -- The manualSource variable was defined in the CopyManual.bat file.
xcopy c:\SharepointDev\MSOCAF\*.docx %RD% /y
xcopy c:\SharepointDev\MSOCAF\*.doc %RD% /y

set manualSourceWord="\\Axsource\SourceSafe\DOCS\ControlPoint%DocVer%\Install Docs Word"
xcopy %manualSourceWord%\*.docx %RD% /y
Rem xcopy %ReadmeSource%\Before_you_begin.doc %RD% /y


Rem (Solution artifacts folder)
rem xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\12\TEMPLATE\Layouts\Axceler\bin\*.dll %SA% /y
rem xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\GAC\Microsoft*.dll %SA% /y
rem xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\GAC\System.Threading.dll %SA% /y
rem xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\GAC\AntiXSSLibrary.dll %SA% /y
rem xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\GAC\Telerik*.dll %SA% /y
xcopy C:\SharepointDev\%DFeatureBase%\WSPBuilder\*.wsp %SA% /y
xcopy C:\SharepointDev\WspBuilderHelp\WSPBuilderHelp\*.wsp %SA% /y
xcopy %installDirectory%\PDBFiles\*.* %SA% /y

Rem (Copy the prerequisite files into the MSOCAF_Kit)
MD %installDirectory%\MSOCAF_Kit\Prerequisites
set PR=%installDirectory%\MSOCAF_Kit\Prerequisites
xcopy c:\SharepointDev\MSOCAF\Prerequisites\*.dll %PR% /y

Rem (Copy the prerequisite source files into the MSOCAF_Kit)
MD %installDirectory%\MSOCAF_Kit\PreReq_WSPSources
set PS=%installDirectory%\MSOCAF_Kit\PreReq_WSPSources
xcopy c:\SharepointDev\MSOCAF\PreReq_WSPSources %PS% /y /e

Rem (Copy the controlpoint dll files into the DLLs folder)
MD %installDirectory%\DLLs
set DLL=%installDirectory%\DLLs
xcopy C:\SharePointDev\%DFeatureBase%\WSPBuilder\AxcelerFeatures\*.dll %DLL% /y

Rem ******************* Create the Native_Kit folder and copy the appropriate files into it. ****
MD %installDirectory%\Native_Kit
set NK=%installDirectory%\Native_Kit

xcopy %RD%\*.* %NK%\"Release documents"\*.* /y
xcopy %IS%\*.* %NK%\"Installation scripts"\*.* /y
xcopy C:\SharepointDev\CreateVirtDirectory\CreateVirtDirectory\bin\Release\CreateVirtDirectory.* %NK%\"Installation scripts"\*.* /y
xcopy C:\SharepointDev\RecyclePool\bin\Release\RecyclePool.exe %NK%\"Installation scripts"\*.* /y
xcopy C:\SharepointDev\xcUtilities\bin\Release\xcUtilities.*  %NK%\"Installation scripts"\*.* /y
Rem ** Copy the prerequisite kits. (Report Viewer and .Net)
if "%NativeKit%"=="2010" (
	xcopy "C:\SharePointDev\Install\ControlPoint\Third Party Installers\ReportViewer.exe" %NK%\"Installation scripts"\*.* /y
	xcopy "C:\SharePointDev\Install\ControlPoint\Third Party Installers\dotNetFx35setup.exe" %NK%\"Installation scripts"\*.* /y
) else (
	xcopy "C:\SharePointDev\Install\ControlPoint\Third Party Installers\ReportViewer11.msi" %NK%\"Installation scripts"\*.* /y
	xcopy "C:\SharePointDev\Install\ControlPoint\Third Party Installers\SQLSysClrTypes.msi" %NK%\"Installation scripts"\*.* /y
	xcopy "C:\SharePointDev\Install\ControlPoint\Third Party Installers\dotNetFx40_Full_setup.exe" %NK%\"Installation scripts"\*.* /y
)
xcopy %SA%\*.* %NK%\"Solutions artifacts"\*.* /y

Rem Add the Prerequisite WSPs into the MSOCAF kit.
Rem *** did not need. *** xcopy c:\SharepointDev\MSOCAF\PrerequisiteWSPs\*.WSP %SA% /y

Rem (Delete the appropiate AxcelerFeatures.wsp and dll files)
del %SA%\AxcelerFeatures.wsp /q
ren %SA%\AxcelerFeaturesShell.wsp AxcelerFeatures.wsp

del %NK%\"Solutions artifacts"\*.dll /q
del %NK%\"Solutions artifacts"\AxcelerFeaturesShell.wsp /q
del %NK%\"Release documents"\MSODeploymentGuide.docx /q

Rem ******************* Now delete the Disk1, Localization Resources, and Patch Components folders and files.
Rem ** Don't need the following cleanup any more.
rem del /s /q %installDirectory%\Disk1\*.*
rem del /s /q %installDirectory%\"Localization Resources"\*.*
rem del /s /q %installDirectory%\"Patch Components"\*.*
rem RD /s/q %installDirectory%\Disk1
rem RD /s/q %installDirectory%\"Localization Resources"
rem RD /s/q %installDirectory%\"Patch Components"


