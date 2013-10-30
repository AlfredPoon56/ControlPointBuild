#Automation and Email Script for ControlPoint Nightly Builds - SharePoint 2007
#6/15/2010
#Rick Benua

from os import path
from subprocess import call
from datetime import *
import string
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.parser import Parser

#Constant arguments for Executebuild.bat
user = "BuildUser"
password = "BuildUser"					#Username and password to VSS account
prev_date_string_1 = "0507.2010"			#Strings to be replaced by Executebuild.bat - see documentation on that program for details
prev_date_string_2 = "20100507"
version_directory = "Watson_2007"			#Directory on \\axstore for the completed build

#Constants for email bot
version = "2007"					#Specifies the SharePoint version that this machine builds for
sender = 1						#Determines whether this instance sends mail. If not, it will write its message to messagefile to be read by another server.
messagefile2010 = '\\\\' + 'axstore\\development\\temp\\Buildmessage2010.txt'	#File on axstore to transmit messages to the mailing program
messagefile2013 = '\\\\' + 'axstore\\development\\temp\\Buildmessage2013.txt'	#File on axstore to transmit messages to the mailing program
server = "drum.percussiontools.local"		#SMTP server to send completion messages through (drum is being decommissioned.)
#server = "axwfe1.percussiontools.local"		#SMTP server to send completion messages through. "10.13.13.19"


from_address = "buildrobot@axceler.com"			#From address for SMTP message

#email address to send completion messages to
to_addresses = ["btrakimas@metalogix.com", "sneumann@metalogix.com","Woneil@metalogix.com", "APoon@metalogix.com"]	

#Email addresses to send mail to if the build failed.  Right now, includes everyone in development.  Someone should keep this up to date.
to_addresses_failed =  to_addresses + ["itroupansky@Metalogix.com", "skelly@Metalogix.com", "NShahukar@Metalogix.com", "AGupta@Metalogix.com", "gbond@Metalogix.com", "doconnor@Metalogix.com", "SVeeravatnam@Metalogix.com", "FSullivan@Metalogix.com"]	

#Set date argument and run Executebuild.bat
raw_date = date.today()
curr_date = str(raw_date.year) + string.rjust(str(raw_date.month), 2, "0") + string.rjust(str(raw_date.day), 2, "0") #Ugly string formatting to pad single-digit months or days with 0s.
print curr_date
#call(["executebuild.bat", user, password, prev_date_string_1, prev_date_string_2, version_directory, "nightly", "$/ControlPointBranches/ControlPoint_Release_4.2", "2010"])  #Execute the build scripts (where all the actual work happens)
#Replaced the above with just calling the version specific build file. (Sherlock, Watson, or CPnext)
#call(["BuildHoudini.bat", "nightly", "2007"])
#call(["CopyNightlyBuildLog.bat", "2007"])

#Log file parsing
failed = 0	
with open("Build Log\Build.txt") as log:
	for line in log:
		if line.count("errors,") > 0:			#Search for summary lines containing "errors,".
			if int(line.split()[3]) > 0:		#"line.split()[3] is the portion of line that contains the number of errors. Python's str.split() function splits on whitespace if no other separator is given.
				failed = 1
with open("Build Log\Log.txt") as log:
	for line in log:
		if line.count("ERROR") > 0:
			failed = 1

#E-mail generation
message = ""
curr_time = datetime.today()
overall_failed = 0

if failed:
	message = "Nightly build of ControlPoint for SharePoint "+version+" for "+str(raw_date)+" failed at "+str(curr_time.hour)+":"+string.rjust(str(curr_time.minute), 2, "0")+"."
	message += "\n"
	message += "The errors are located in the file, \\\\Axstore\\Development\\Builds\\ControlPoint\\Nightly_Build_Logs\\2007\\Build.txt "
	overall_failed = 1
else:
	message = "Nightly build of ControlPoint for SharePoint "+version+" for "+str(raw_date)+" succeeded at "+str(curr_time.hour)+":"+string.rjust(str(curr_time.minute), 2, "0")+"."

buildfile = ""
logfile = ""

if sender:
	if path.exists(messagefile2010):
		input = open(messagefile2010, 'r+')
		try:
			overall_failed = failed | int(input.readline())
		except ValueError:
			print "No data (or bad formatting) in "+messagefile2010+"."
		finally:
			message += "\n\n"
			message += input.readline()
			buildstring = ""
			logstring = ""
			line = "foo"
			while len(line) > 0:
				line = input.readline()
				buildstring += line
			message += buildstring
			input.truncate(0)
		input.close()
	if path.exists(messagefile2013):
		input = open(messagefile2013, 'r+')
		try:
			overall_failed = failed | int(input.readline())
		except ValueError:
			print "No data (or bad formatting) in "+messagefile2013+"."
		finally:
			message += "\n\n"
			message += input.readline()
			buildstring = ""
			logstring = ""
			line = "foo"
			while len(line) > 0:
				line = input.readline()
				buildstring += line
			message += buildstring
			input.truncate(0)
		input.close()
#print "sending message:"
#print message+"\n"
MIMEmessage = MIMEMultipart()
MIMEmessage.attach(MIMEText(message))

if overall_failed:
	MIMEmessage['Subject'] = "The ControlPoint code named (BlackStone) Nightly Build Failed"	
	to_addresses = to_addresses_failed
else:
	MIMEmessage['Subject'] = "The ControlPoint code named (BlackStone) Nightly Build Succeeded"
MIMEmessage['From'] = from_address
MIMEmessage['To'] = ", ".join(to_addresses);
#print "MIME message:"
#print MIMEmessage.as_string()

#E-mail distribution
if sender:
	connection = smtplib.SMTP(host=server)
	refused = dict()
	try:
		refused = connection.sendmail(from_address, to_addresses, MIMEmessage.as_string())
	except smtplib.SMTPRecipientsRefused as list:
		print "Error: All listed recipients refused by server."
		refused = list
	except smtplib.SMTPHeloError:
		print "Error: Server did not respond to HELO request."
	except smtplib.SMTPSenderRefused:
		print "Error: Server refused sender address."
	except smtplib.SMTPDataError:
		print "Error: The server replied with an unexpected error code."
	connection.quit()
	if len(refused) > 0:
		print "The server refused some email recipients."
		for pair in refused.items():
			print "Refused "+pair[0]+":"
			print pair[1]
