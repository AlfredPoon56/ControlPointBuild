Rem Copy the nightly build log files to the shared \\Axstore location.
Copy /y "c:\ControlPoint_Build\Build Log\Build.txt" \\Axstore\Development\Builds\ControlPoint\Nightly_Build_Logs\%1\*.*
Copy /y "c:\ControlPoint_Build\Build Log\Build_*Online.txt" \\Axstore\Development\Builds\ControlPoint\Nightly_Build_Logs\%1\*.*
Copy /y "c:\ControlPoint_Build\Build Log\Build_*Native.txt" \\Axstore\Development\Builds\ControlPoint\Nightly_Build_Logs\%1\*.*
