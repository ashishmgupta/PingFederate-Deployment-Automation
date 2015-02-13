Set-ExecutionPolicy Unrestricted

Set-Location $PSScriptRoot

$deploysourceserverfolderlocation = Join-Path $PSScriptRoot server
$deploysourceserverfolderlocation

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

"############# Backing up the folder ##################"
$pingfederaterootfolderparent = $pingfedexeexactlocation.Directory.Parent.Parent.Parent.FullName
$pingfederatebackupfoldername =  "PF_"+ $(get-date -f MM-dd-yyyy_HH_mm_ss) 
$pingfederatebackupfolderfullpath = $pingfederaterootfolderparent + $pingfederatebackupfoldername 
Write-Host "$($pingfederaterootfolder) getting backed up to $($pingfederatebackupfolderfullpath)"
# $pingfederatebackupfolder = $pingfederaterootfolder +"_"+ $(get-date -f MM-dd-yyyy_HH_mm_ss) 
 robocopy $pingfederaterootfolder $pingfederatebackupfolderfullpath /E
"############# Backup completed ##################"

"############## PingFederate 'server' folder path ##############"
$pingfederateserverfolder = Join-Path $pingfederaterootfolder server
$pingfederateserverfolder


"############## PingFederate 'default' folder path ############## "
$pingfederatedefaultfolder = Join-Path $pingfederateserverfolder default
$pingfederatedefaultfolder

"############## PingFederate 'deploy' folder path ############## "
$pingfederatedeployfolder = Join-Path $pingfederatedefaultfolder deploy
$pingfederatedeployfolder

Set-Location $pingfederatedeployfolder

"############## This is how you can get all he yourcompany.jar files to be deleted ############## "
Get-ChildItem $pingfederatedeployfolder -name -filter yourcompany*.jar

"############## All yourcompany*.jar files deleted ##############"

Write-Host "$($deploysourceserverfolderlocation) deploying to $($pingfederateserverfolder)"

Copy-Item -Path $deploysourceserverfolderlocation $pingfederaterootfolder -recurse -force

"############## Deployment completed ##############"

"############## Starting PingFederate Service. ##############"
$pingfederateservicename
Start-Service -displayname $pingfederateservicename.displayname
"############## PingFederate Service Started. ##############"


pause