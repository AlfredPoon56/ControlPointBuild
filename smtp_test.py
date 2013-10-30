#Send a test message using a specified smtp server.
print "--- begin ---"

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
prev_date_string_1 = "0507.2010"			#Strings to be replaced by Executebuild.bat - see documentation on that program for details
prev_date_string_2 = "20100507"
version_directory = "Watson_2007"			#Directory on \\axstore for the completed build

#Constants for email bot
version = "2007"					#Specifies the SharePoint version that this machine builds for
sender = 1						#Determines whether this instance sends mail. If not, it will write its message to messagefile to be read by another server.
messagefile = '\\\\' + 'axstore\\development\\temp\\Buildmessage.txt'	#File on axstore to transmit messages to the mailing program
server = "drum.percussiontools.local"		#SMTP server to send completion messages through
#server = "axwfe1.percussiontools.local"		#SMTP server to send completion messages through. "10.13.13.19"
#server = "smtp.ihostexchange.net"               #Use the ihost exchange SMTP server. 66.46.182.50

from_address = "buildrobot@axceler.com"			#From address for SMTP message
to_addresses = "APoon@Metalogix.com"	#email address to send completion messages to

#email address to send completion messages to
to_addresses = ["btrakimas@metalogix.com", "sneumann@metalogix.com","Woneil@metalogix.com", "APoon@metalogix.com"]	

#Email addresses to send mail to if the build failed.  Right now, includes everyone in development.  Someone should keep this up to date.
to_addresses_failed =  to_addresses + ["itroupansky@Metalogix.com", "skelly@Metalogix.com", "NShahukar@Metalogix.com", "AGupta@Metalogix.com", "gbond@Metalogix.com", "doconnor@Metalogix.com", "SVeeravatnam@Metalogix.com"]	

MIMEmessage = MIMEMultipart()
MIMEmessage['Subject'] = "Build test message."	

MIMEmessage['From'] = from_address
MIMEmessage['To'] = ", ".join(to_addresses)

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
print "--- Done ---"
