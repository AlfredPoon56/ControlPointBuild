using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Text.RegularExpressions;

namespace Deployment
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                UpdateVersionNumbers(args);
            }
            catch (Exception ex)
            {
                Logger.Log(ex);
            }
        }

        private static void UpdateVersionNumbers(string[] args)
        {
            string[] projNames = new string[] { "xcDiscoveryFeature", "cpAdminBridge", "cpPresenter", "xcAdminCommon", "xcAdminUtils", "xcCommonCore", "xcDatalayer", "xcSPAccessCore", "xcSPObjects", "xcStandardLib", "xcUILib" };
            string monthDay =DateTime.Now.Month.ToString();
            if (DateTime.Now.Month < 10)
            {
                monthDay = string.Format("{0}{1}", new object[] { "0", monthDay });
            }
            string day = DateTime.Now.Day.ToString();
            if (DateTime.Now.Day < 10)
            {
                day = string.Format("{0}{1}", new object[] { "0", day });
            }
            monthDay = string.Format("{0}{1}", new object[] { monthDay, day });

            string newVersionTagForAssembly = string.Format(
                "{0}.{1}",
                new object[] { 
                    monthDay, 
                    DateTime.Now.Year.ToString()
                }
            );

            string newVersionTagForSQL = string.Format(
                "{0}{1}",
                new object[] { 
                    DateTime.Now.Year.ToString(),
                    monthDay
                }
            );

            string axcelerDir, adminCoreDir;
            if (args.Length > 2) 
            {
		string sourceDir = args[2];
                axcelerDir = @"C:\" + sourceDir;
                adminCoreDir = @"C:\" + sourceDir;
            }
            else
            {
                axcelerDir = @"C:\Program Files\Common Files\Microsoft Shared\web server extensions\14\TEMPLATE";
                adminCoreDir = @"C:\SharepointDev";
            }

            // For V4.2 and lower.
            Logger.Log("Updating AssemblyInfo.cs in xcAdminCore");
            ReplaceTextInFile(
                adminCoreDir + @"\xcAdminCore\Properties\AssemblyInfo.cs",
                args[0],
                newVersionTagForAssembly);
            Logger.Log("Finished Updating AssemblyInfo.cs in xcAdminCore");

            Logger.Log("Updating script_xcAdminUpdate.sql");
            ReplaceTextInFile(
                adminCoreDir + @"\xcAdminCore\script_xcAdminUpdate.sql",
                args[1],
                newVersionTagForSQL);
            Logger.Log("Finished Updating script_xcAdminUpdate.sql");

            
            // For post V4.2.
            Logger.Log("Updating AssemblyInfo.cs in xcAdminCoreC");
            ReplaceTextInFile(
                adminCoreDir + @"\xcAdminCoreC\Properties\AssemblyInfo.cs",
                args[0],
                newVersionTagForAssembly);
            Logger.Log("Finished Updating AssemblyInfo.cs in xcAdminCoreC");

            Logger.Log("Updating AssemblyInfo.cs in Axceler Hive");
            ReplaceTextInFile(
                axcelerDir + @"\LAYOUTS\axceler\Properties\AssemblyInfo.cs",
                args[0],
                newVersionTagForAssembly);
            Logger.Log("Finished Updating AssemblyInfo.cs in Axceler Hive");

            Logger.Log("Updating script_xcAdminUpdate.sql in xcAdminCoreC");
            ReplaceTextInFile(
                adminCoreDir + @"\xcAdminCoreC\script_xcAdminUpdate.sql",
                args[1],
                newVersionTagForSQL);
            Logger.Log("Finished Updating script_xcAdminUpdate.sql in xcAdminCoreC");

            // Try and update the Assembly File Version of other ControlPoint DLLs
            foreach (string project in projNames)
            {
                //loop thru each project and change the version number if it is the form ".0507.2010"
                Logger.Log("Updating AssemblyInfo.cs in " + project);
                ReplaceTextInFile(
                    adminCoreDir + @"\" + project + @"\Properties\AssemblyInfo.cs",
                    args[0],
                    newVersionTagForAssembly);
                Logger.Log("Finished Updating AssemblyInfo.cs in " + project);
            }

        }

        private static void ReplaceTextInFile(string filePath, string textToReplace, string newText)
        {
            StreamReader reader = new StreamReader(filePath);
            string content = reader.ReadToEnd();
            reader.Close();

            content = Regex.Replace(content, textToReplace, newText);

            FileInfo replacementInfo = new FileInfo(filePath);
            replacementInfo.IsReadOnly = false;

            StreamWriter writer = new StreamWriter(filePath);
            writer.Write(content);
            writer.Close();
        }
    }
}
