. .\PingFedLib.ps1
Set-ExecutionPolicy Unrestricted

Set-Location $PSScriptRoot


"############## Looking for PingFederate service ############"
$pingfederateserviceexecutablepath
$pingfederateserviceexecutablepath = gwmi win32_service|?{$_.name -like "pingfederate*"}|select pathname
$pingfederateservicename = gwmi win32_service|?{$_.name -like "pingfederate*"}|select displayname

if(!$pingfederateserviceexecutablepath) { throw "PingFederate service IS NOT installed on this machine. Script will not continue!"} else {"PingFederate service IS installed on this machine. Proceeding..."}

"############## Stopping PingFederate Service. ##############"
$pingfederateservicename
Stop-Service -displayname $pingfederateservicename.displayname
"############## PingFederate Service Stopped. ##############"

$pos = $pingfederateserviceexecutablepath.pathname.IndexOf(" -s ")
$pingfederateserviceexecutablepathstring = $pingfederateserviceexecutablepath.pathname.Substring(0, $pos)


"############## PingFederate service - Path to executable with -s onwards removed ##############"
$pingfederateserviceexecutablepathstring = $pingfederateserviceexecutablepathstring.Replace("`"","")
$pingfederateserviceexecutablepathstring


$pingfedexeexactlocation
$pingfedexeexactlocation = Get-Item $pingfederateserviceexecutablepathstring | Select-Object Directory

"############## PingFederate root folder ############## "
$pingfederaterootfolder
$pingfederaterootfolder = $pingfedexeexactlocation.Directory.Parent.Parent.FullName
$pingfederaterootfolder
$PingFedRunPropertiesFilePath = $pingfederaterootfolder + "/bin/run.properties"

"############## Zipping existing log files ##############"
$pingFedLogFolder = GetPingFederateLogFolder $PingFedRunPropertiesFilePath
ZipPingFederateLogFiles $pingFedLogFolder
"############## Zipping existing log files - Completed ##############"


"############## Deleting existing log files ##############"
$pingFedLogFolder
Remove-Item $pingFedLogFolder/* -include server.*
"############## Deleting existing log files - Completed ##############"


"############## Starting PingFederate Service. ##############"
$pingfederateservicename
Start-Service -displayname $pingfederateservicename.displayname
"############## PingFederate Service Started. ##############"


$PingFedOperationalMode = GetPingFederateOperationalMode $PingFedRunPropertiesFilePath
CheckPingFederateStatusAfterServiceStart $PingFedOperationalMode




<#
$adminURL = GetPingFedAdminUrl
$adminURL
$heartbeatURL = GetPingFedHeartbeatUrl
$heartbeatURL
IsPingFederateAdminOK $adminURL
IsPingFedHeartbeatOK $heartbeatURL
#>
pause

