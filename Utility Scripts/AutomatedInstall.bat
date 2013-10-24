Rem ** Filename: AutomatedInstall.bat
Rem **
Rem ** This file is used for automate the installation of the nightly build. It copies the nightly build files from 
Rem ** \\axstore\development\...\Nightly\disk1i nto the c:\CP_AutomatedInstall local folder. Then use the
Rem **  ControlPoint "SilentInstall" feature to perform a "Repair" install of the latest nightly built kit.
Rem **  
Rem ** 
Rem ** Currently, the script was designed to be used from the "CopyBuildProducts.bat" script.
Rem **
Rem ** At the end of the install, a file with the name of "RepairCompleted.txt" file will be created in the .\SilentInstall folder
Rem ** to be used by the regression test as a trigger to begin the test.
Rem **
Rem **   P1 = Name of the controlpoint release. (i.e. Houdini_2010, Blackstone_2010)


Rem **** InstallDirectory should be \\axstore\development\builds\ControlPoint\<release location>\ControlPoint_Nightly
Set KitLocation=\\axstore\development\builds\ControlPoint\%1\ControlPoint_Nightly
Set LocalKitDir=c:\CP_AutomatedInstall
Set SilentInstallDir=%LocalKitDir%\SupportTools\SilentInstall

Rem *** If the file "DoNotInstall.dat" existed in the c:\cp_AutomatedInstall folder, the installation will not happen. ***
if Exist "%LocalkitDir%\DoNotInstall.dat" goto end

:BeginInstall
Rem ** Copy all files from the kits "\disk1" folder. (no subdirectory files)
Copy /y %KitLocation%\Disk1\*.* %LocalKitDir%\*.*

Rem ** Change the current directory to that of the local kit's SilentInstall folder
cd %SilentInstallDir%
Call CommandLineInstall.bat Repair_Install.iss

:Completed
Rem ** When done, create a RepairCompleted.txt file in the SilentInstall folder
Set DateTime=%date% %time%
echo "The last ControlPoint Repair was completed on %DateTime%." > RepairCompleted.txt

:end