.\CommonLib.ps1


$TomcatLogsLocation = "C:\Program Files\Apache Software Foundation\Tomcat 7.0\logs"
$RSAAALogsLocation = "D:\RSA\logs"
$AllLogsFolderName = GetMachineFQDN +"_RSA_"+ $(get-date -f MM-dd-yyyy_HH_mm_ss)
$TomcatLogsFolderName = "Tomcat_Logs"
$RSAAALogsFolderName = "RSA_AA_Logs"

$TomcatLogsBackupConfirmationMessage = "Do you want to back up the tomcat log files?"
$TomcatLogsDeleteConfirmationMessage = "Do you want to delete the tomcat log files?"

$RSAAALogsBackupConfirmationMessage = "Do you want to back up the RSA AA log files?"
$RSAAALogsDeleteConfirmationMessage = "Do you want to delete the RSA AA log files?"



$ConfirmTomcatLogBackup = GetConfirmation $TomcatLogsBackupConfirmationMessage
if($ConfirmTomcatLogBackup -eq 'y') {
    New-Item Join-path $AllLogsFolderName $TomcatLogsFolderName -directory
    Copy-Item "$TomcatLogsLocation -Destination Join-path $AllLogsFolderName $TomcatLogsFolderName
}


$ConfirmRSAAALogBackup = GetConfirmation $RSAAALogsBackupConfirmationMessage
if( $ConfirmRSAAALogBackup -eq 'y')
{
    New-Item Join-path $AllLogsFolderName $RSAAALogsFolderName -directory
}




# Ask the user if back needs to be taken
# Create a folder named <machinename>_RSAlogs_<timestamp>
# Tomcat log location - C:\Program Files\Apache Software Foundation\Tomcat 7.0\logs
# Copy all the files in the tomcat log location  to a folder named <machinename>_tomcat_timestamp
# Delete all the files from the tomcat log location
# RSA AA log location - D:\RSA\Logs
# Delete all the aa_server.log* files and the aa_soapcalls* modified today in the RSA log location  to a folder named <machinename>_RSA_timestamp


