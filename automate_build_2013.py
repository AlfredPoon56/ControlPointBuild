#Automation and Email Script for ControlPoint Nightly Builds - SharePoint 2007
#6/15/2010
#Rick Benua

from subprocess import call
from datetime import *
import string
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
from email.parser import Parser
from os import path

#Constant arguments for Executebuild.bat
user = "BuildUser"
password = "BuildUser"					#Username and password to VSS account
prev_date_string_1 = "0507.2010"			#Strings to be replaced by Executebuild.bat - see documentation on that program for details
prev_date_string_2 = "20100507"
version_directory = "Watson_2010"			#Directory on \\axstore for the completed build

#Constants for email bot
version = "2013"					#Specifies the SharePoint version that this machine builds for
sender = 0						#Determines whether this instance sends mail. If not, it will write its message to messagefile to be read by another server.
messagefile = '\\\\' + 'axstore\\development\\temp\\Buildmessage2013.txt'	#File on axstore to transmit messages to the mailing program
server = "drum.percussiontools.local"		#SMTP server to send completion messages through
from_address = "buildrobot@axceler.com"			#From address for SMTP message
to_addresses = ["betty.trakimas@axceler.com", "stan.neumann@axceler.com", "william.o'neil@axceler.com", "alfred.Poon@axceler.com"]	#email address to send completion messages to
#Email addresses to send mail to if the build failed.  Right now, includes everyone in development.  Someone should keep this up to date.
to_addresses_failed = to_addresses + ["david.toppin@axceler.com", "gangadhar.ginne@axceler.com", "irene.troupansky@axceler.com", "mark.webb@axceler.com", "stephen.kelly@axceler.com", "Ketan.Thakkar@axceler.com", "Anthony.Romano@axceler.com", "larissa.smelkov@axceler.com"]	#Email addresses to send mail to if the build failed.  Right

#Set date argument and run Executebuild.bat
raw_date = date.today()
curr_date = str(raw_date.year) + string.rjust(str(raw_date.month), 2, "0") + string.rjust(str(raw_date.day), 2, "0") #Ugly string formatting to pad single-digit months or days with 0s.
print curr_date
#call(["executebuild.bat", user, password, prev_date_string_1, prev_date_string_2, version_directory, "nightly", "$/ControlPointBranches/ControlPoint_Release_4.2", "2010"])  #Execute the build scripts (where all the actual work happens)
#Replaced the above with just calling the version specific build file. (Sherlock, Watson, or Poirot)
call(["BuildVNext.bat", "nightly", "2013"])
#Build the ControlPoint Online kit in the nightly build.
call(["BuildCPOnline.bat", "Nightly", "BlackStone"])
call(["BuildVNextNative.bat", "nightly", "2013"])
call(["CopyNightlyBuildLog.bat", "2013", "T"])

#Log file parsing
failed = 0
onPrem = "(succeeded)."
online = "(succeeded)."	
with open("Build Log\Build.txt") as log:
	for line in log:
		if line.count(": error") > 0:			#Search for summary lines containing "errors,".
			failed = 1
			onPrem = "(failed)."
with open("Build Log\Log.txt") as log:
	for line in log:
		if line.count("ERROR") > 0:
			failed = 1

with open("Build Log\Build_Online.txt") as log:
	for line in log:
		if line.count(": error") > 0:			#Search for summary lines containing "errors,".
			failed = 1
			online = "(failed)."
with open("Build Log\Log_Online.txt") as log:
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
	message += "The errors are located in one or both of the following files:" 
	message += "\n"
	message += "   \\\\Axstore\\Development\\Builds\\ControlPoint\\Nightly_Build_Logs\\2010\\Build.txt "+onPrem
	message += "\n"
	message += "   \\\\Axstore\\Development\\Builds\\ControlPoint\\Nightly_Build_Logs\\2010\\Build_Online.txt "+native
	overall_failed = 1
else:
	message = "Nightly build of ControlPoint for SharePoint "+version+" for "+str(raw_date)+" succeeded at "+str(curr_time.hour)+":"+string.rjust(str(curr_time.minute), 2, "0")+"."

buildfile = ""
logfile = ""
if sender:
	if path.exists(messagefile):
		input = open(messagefile, 'r+')
		try:
			overall_failed = failed | int(input.readline())
		except ValueError:
			print "No data (or bad formatting) in "+messagefile+"."
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
print "sending message:"
print message+"\n"
MIMEmessage = MIMEMultipart()
MIMEmessage.attach(MIMEText(message))

MIMEmessage['Subject'] = "(Mason) Nightly Build Succeeded"
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
	
else:
	output = open(messagefile, 'a')
	output.write(str(failed)+"\n")
	output.write(message+"\n")
	output.close()
