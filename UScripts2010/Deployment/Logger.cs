using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

namespace Deployment
{
    public static class Logger
    {
        private const string LOG_FILE = @"C:\ControlPoint_Build\Build Log\Log.txt";

        /// <summary>
        /// Logs the message to the build log
        /// </summary>
        /// <param name="message">message to output</param>
        public static void Log(string message)
        {
            WriteToFile(message);
        }

        /// <summary>
        /// Logs the exception to the build log
        /// </summary>
        /// <param name="exception">the exception to process</param>
        public static void Log(Exception exception)
        {
            WriteToFile(exception.Message);
        }

        /// <summary>
        /// Handles the output of the text into the build log
        /// </summary>
        /// <param name="message"></param>
        private static void WriteToFile(string message)
        {
            if (File.Exists(LOG_FILE))
            {
                using (StreamWriter sw = new StreamWriter(LOG_FILE))
                {
                    sw.WriteLine(message);
                }
            }
            else
            {
                using (StreamWriter sw = File.CreateText(LOG_FILE))
                {
                    sw.WriteLine(message);
                }
            }
        }       
    }
}
