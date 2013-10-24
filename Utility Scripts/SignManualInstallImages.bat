rem ** File name: SignManualInstallImages.bat
rem **
rem ** This file is called before packaging the cP Kit with Install Shield
rem ** The "SignTool.exe is used to sign all the .dlls and .exe that get packaged
rem **   into the ControlPoint kit.
rem **
rem ** The signtool and the certificate should be located in \SharePointDev

set SPDevDir=\SharePointDev
set SignTool=".\Utility Scripts\SignTool.exe"
set CertFile="%SPDevDir%\Install\MetalogixSoftwareCorporation2011-2014.pfx"
set Pwd=LogixOfMeta
set Ts=http://timestamp.verisign.com/scripts/timstamp.dll

set SignArgs=sign /f %CertFile% /p %Pwd% /t %Ts%

rem ** Start signing the images.
%Signtool% %SignArgs% %SPDevDir%\ControlPointInstallCheck\ControlPointInstallCheck\bin\Release\ControlPointInstallCheck.exe
%Signtool% %SignArgs% %SPDevDir%\xcClient\bin\Release\xcClient.exe
%Signtool% %SignArgs% %SPDevDir%\CreateVirtDirectory\CreateVirtDirectory\bin\Release\CreateVirtDirectory.exe
%Signtool% %SignArgs% %SPDevDir%\xcUtilities\bin\Release\xcUtilities.exe