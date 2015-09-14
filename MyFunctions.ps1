. .\CommonLib.ps1

Write-Host "Installing functions"
function A1
{
	$currentLocation = $PSScriptRoot
	$currentLocation
	# StopService "pingfederate"
	$confirmation = 'y'
	$confirmation = GetConfirmation "Do you want to back up the tomcat log files"
	$confirmation
	
	
	$TomcatLogsLocation = "C:\temp1"
	$RSAAALogsLocation = "C:\temp2"
	$machineFQDN = GetMachineFQDN
	$AllLogsFolderName = $machineFQDN+ "_RSA_"+ $(get-date -f MM-dd-yyyy_HH_mm_ss)
	$TomcatLogsBackUpFolderPath =  [io.path]::combine($currentLocation, $AllLogsFolderName ,"Tomcat_Logs")  
	$TomcatLogsBackUpFolderPath
	$RSAAALogsBackUpFolderPath = [io.path]::combine($currentLocation, $AllLogsFolderName ,"RSA_AA_Logs") 
	$RSAAALogsBackUpFolderPath
	$TomcatLogsBackupConfirmationMessage = "Do you want to back up the tomcat log files?"
	$TomcatLogsDeleteConfirmationMessage = "Do you want to delete the tomcat log files?"

	$RSAAALogsBackupConfirmationMessage = "Do you want to back up the RSA AA log files?"
	$RSAAALogsDeleteConfirmationMessage = "Do you want to delete the RSA AA log files?"



$ConfirmTomcatLogBackup = GetConfirmation $TomcatLogsBackupConfirmationMessage
if( $ConfirmTomcatLogBackup -eq 'y') 
{
	
	CreateFolderIfDoesnotExist TomcatLogsBackUpFolderPath
	# if (!(Test-Path -path $AllLogsFolderName)) {New-Item $AllLogsFolderName -Type Directory}
	# {
	#	New-Item $AllLogsFolderName -Type Directory
	#}
    # Copy-Item $TomcatLogsLocation -Destination Join-path $AllLogsFolderName $TomcatLogsFolderName
}

}



function GetConfirmation
{
	$message = $args[0]
	$confirmation = 'y'
	$confirmation = Read-Host $message
	if($confirmation -eq '')
	{
		$confirmation = 'y'
	}
	if ($confirmation -eq 'y') {
		Write-Host "You said YES"
	}
	else
	{
		Write-Host "You said NO"
	}
	return $confirmation
}
