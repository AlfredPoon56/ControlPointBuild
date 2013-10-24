@echo off

Rem **** %1 contains either *_2007 or *_2010. Extract the right most 4 char to determine 
Rem      if this is a 2007 or 2010 build. 
Rem  We will use the SPVER variable for now.
if "%SPVER%" == "2010" set HiveNum=14
if "%SPVER%" == "2007" set HiveNum=12

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
set manualSource="\\axsource\SourceSafe\DOCS\ControlPointOnline%DocVer%\Install Docs"

Echo CopyBuildProducts: copy files to '%installDirectory%'
if Not %logfile%=="" Echo CopyBuildProducts: copy files to '%installDirectory%'  >> %logFile%

rem Make install directory writeable
attrib %installDirectory%\*.* -R /s

Rem Delete the install directory.
rd "%installDirectory%" /S /Q

rem Create the install directory
MD %installDirectory%

rem copy the Disk 1 folder
MD %installDirectory%\Disk1
xcopy "%spDevDir%\Install\ControlPoint\Media\Release\Disk Images\Disk1" %installDirectory%\Disk1 /y

rem copy the manuals to axstore
xcopy %manualSource%\*.pdf %installDirectory%\Disk1 /y
xcopy %manualSource%\*.zip %installDirectory%\Disk1 /y
xcopy %spDevDir%\Docs\Readme_Online.htm %installDirectory%\Disk1 /y
xcopy %spDevDir%\Docs\Before_you_begin_Online.pdf %installDirectory%\Disk1 /y

rem copy additional files
rem xcopy "%spDevDir%\Install\ControlPoint Prerequisites\Media\Release 2\Package\Prerequisites.exe" %installDirectory%\Disk1 /y

rem MD %installDirectory%\Disk1\images
rem xcopy %spDevDir%\Install\CONTROLPOINTCDIMAGE\images %installDirectory%\Disk1\images /y

rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\autorun.ico %installDirectory%\Disk1 /y
rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\AUTORUN.INF %installDirectory%\Disk1 /y
rem xcopy C:\SharepointDev\Install\CONTROLPOINTCDIMAGE\Index.hta %installDirectory%\Disk1 /y

MD %installDirectory%\Disk1\PreInstallValidation
xcopy %spDevDir%\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\*.exe %installDirectory%\Disk1\PreInstallValidation /y
xcopy %spDevDir%\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\*.exe.config %installDirectory%\Disk1\PreInstallValidation /y
xcopy %spDevDir%\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\*.dll %installDirectory%\Disk1\PreInstallValidation /y

REM ****** Copy the pdb files
MD %installDirectory%\PDBFiles\AxcelerFeature
MD %installDirectory%\PDBFiles\Layouts.Axceler.Bin

xcopy "%spDevDir%\LAYOUTS\axceler\bin\*.pdb" %installDirectory%\PDBFiles\Layouts.Axceler.Bin /y
xcopy %spDevDir%\xcUtilities\bin\Release\*.pdb %installDirectory%\PDBFiles\AxcelerFeature /y
xcopy %spDevDir%\xcClient\bin\Release\*.pdb %installDirectory%\PDBFiles\AxcelerFeature /y
xcopy %spDevDir%\xcSandboxSolution\Features\*.wsp %installDirectory%\*.* /y
