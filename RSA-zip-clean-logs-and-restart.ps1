. .\PingFedLib.ps1
Set-ExecutionPolicy Unrestricted

Set-Location $PSScriptRoot

$RSALogsLoacation = "d:/RSA/logs"

"############## Looking for PingFederate service ############"
$tomcatserviceexecutablepath
$tomcatserviceexecutablepath = gwmi win32_service|?{$_.name -like "tomcat*"}|select pathname
$tomcatservicename = gwmi win32_service|?{$_.name -like "tomcat*"}|select displayname

if(!$tomcatserviceexecutablepath) { throw "Tomcat service IS NOT installed on this machine. Script will not continue!"} else {"Tomcat service IS installed on this machine. Proceeding..."}

"############## Stopping tomcat Service. ##############"
$tomcatservicename
Stop-Service -displayname $tomcatservicename.displayname
"############## tomcat Service Stopped. ##############"


"############## Zipping existing log files ##############"
$pingFedLogFolder = GettomcatLogFolder $PingFedRunPropertiesFilePath
ZiptomcatLogFiles $pingFedLogFolder
"############## Zipping existing log files - Completed ##############"


"############## Deleting existing log files ##############"
$pingFedLogFolder
Remove-Item $pingFedLogFolder/* -include server.*
"############## Deleting existing log files - Completed ##############"


"############## Starting tomcat Service. ##############"
$tomcatservicename
Start-Service -displayname $tomcatservicename.displayname
"############## tomcat Service Started. ##############"


$PingFedOperationalMode = GettomcatOperationalMode $PingFedRunPropertiesFilePath
ChecktomcatStatusAfterServiceStart $PingFedOperationalMode

<#
$adminURL = GetPingFedAdminUrl
$adminURL
$heartbeatURL = GetPingFedHeartbeatUrl
$heartbeatURL
IstomcatAdminOK $adminURL
IsPingFedHeartbeatOK $heartbeatURL
#>
pause

