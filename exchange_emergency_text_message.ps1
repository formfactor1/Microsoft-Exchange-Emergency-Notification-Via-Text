<#
.Title
Exchange Emergency Text Message
.Description
Script to send a text message to every employee. Used for emergency notifications such as natural disasters or active shooters.
Full details at https://blog.watchpointdata.com/watchpoint-tip-of-the-week-employee-emergency-notifications
.How To Use
Modify the email settings, export paths and distrogroup info.
.Created By
Nathan Studebaker
#>

###########################################################################################
#Declare email. Don't declare a to field. It's used at the end.
$From = "emergencytest@mydomain.com"
$Body = "This is a test of the WatchPoint emergency broadcast system. This is only a test."
$Sub = "Test of the MyCompany emergency broadcast system"
$CredUser = "myuser@mydomain.com"
$CredPass = "mypassword" | ConvertTo-SecureString -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.Pscredential -Argumentlist $CredUser,$CredPass
$SmtpServer = "mail.mydomain.com"
$Port = "25"

#Declare other variables
$exportmembers = "C:\support\members.csv"
$exportresults = "C:\support\results.csv"

#Get members of our hidden distrobution group and export to csv
$members = get-adgroupmember "MyDistroGroup" | select-object -property "SamAccountName" | export-csv $exportmembers

#Get name,login, and mobile phone number from the group, and export to a second csv
Import-CSV -Path C:\users\msadmin\watchpointdata.csv | ForEach-Object { 
    Get-ADUser -Filter "SamAccountName -like '*$($_.SamAccountName)*'" -Properties MobilePhone,UserPrincipalName,Name | select Name,UserPrincipalName,MobilePhone 
} | Export-CSV $exportresults -NoTypeInformation

#Get just the "MobilePhone" number from our second csv, and send email to each member.

$textnumbers = import-csv $exportresults | % {$_.MobilePhone} 
 
ForEach($n in $textnumbers) 
 {
 Send-MailMessage -To $textnumbers -From $From -Body $Body -Subject $Sub -Credential $Credentials -SmtpServer $smtpServer -Port $Port
}
#End of Script