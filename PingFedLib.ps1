add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

Add-Type -AssemblyName System.IO.Compression.FileSystem

function GetMachineFQDN
{
    return $env:computername+"."+$env:userdnsdomain
}



function GetPingFedHeartbeatUrl
{
  # $machineFQDN = $[System.Net.Dns]::GetHostByName(($env:computerName)) | FL HostName | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };
  $machineFQDN = GetMachineFQDN
  $heartbeatUrl = "https://"+$machineFQDN+"/pf/heartbeat.ping"
  return $heartbeatUrl;
}


function GetPingFedAdminUrl
{
    $machineFQDN = GetMachineFQDN
    $adminUrl = "https://"+$machineFQDN+":9999/pingfederate/app"
    return $adminUrl
}


function IsPingFedHeartbeatOK
{

    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    $webClient = new-object System.Net.WebClient -EA SilentlyContinue
    $webClient.Headers.Add("user-agent", "PowerShell Script")
    $MaxNumberOfAttempts = 20
    $TotalNumberOfAttempts = 0
    $heartbeatURL = $args[0]
    "Heartbeat check for " + $heartbeatURL + " started"
    $output = ""
    $startTime = get-date
    while ($MaxNumberOfAttempts -gt $TotalNumberOfAttempts) {
       try{
           $output = $webClient.DownloadString($heartbeatURL) 
       }
       catch
       {
       }
       $endTime = get-date

       if ($output -like "*OK*") {
          Write-Host -foregroundcolor Green "PingFed Engine Heartbeat UP! :"   ($endTime - $startTime).TotalSeconds " seconds elapsed"
          break;
       } else {
          Write-Host -foregroundcolor Gray "PingFed Engine Heartbeat coming up : " ($endTime - $startTime).TotalSeconds " seconds elapsed"
       }
       $TotalNumberOfAttempts = $TotalNumberOfAttempts + 1
       sleep(6)
    }

    return $output
}


function IsPingFederateAdminOK
{

    [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

    $heartbeatURL = $args[0]
    

    "Heartbeat check for Admin on " + $heartbeatURL + " started"

    $MaxNumberOfAttempts = 20
    $TotalNumberOfAttempts = 0
    $startTime = get-date
    while ($MaxNumberOfAttempts -gt $TotalNumberOfAttempts) {
        $req=[system.Net.HttpWebRequest]::Create($heartbeatURL) 
        $res = $req.getresponse();
        $stat = $res.statuscode;
        $res.Close();
        "Status is " + $stat
       $endTime = get-date
       if ($stat -eq "OK") {
          Write-Host -foregroundcolor Green "PingFed Admin UP! :"   ($endTime - $startTime).TotalSeconds " seconds elapsed"
          break;
       } else {
          Write-Host -foregroundcolor Gray "PingFed Admin coming up : " ($endTime - $startTime).TotalSeconds " seconds elapsed"
       }

       $TotalNumberOfAttempts = $TotalNumberOfAttempts + 1
       sleep(6)
    }
    return $stat
}

<#
The below function reads the run.properties file and looks for the "pf.operational.mode"
This property indicates the operational mode of the runtime server (protocol
engine) from a clustering standpoint. 

 Valid values are:
     STANDALONE        - This server is a standalone instance that runs both 
                       the UI console and protocol engine (default).
     CLUSTERED_CONSOLE - This server is part of a cluster and runs only the 
                       administration console.
     CLUSTERED_ENGINE  - This server is part of a cluster and runs only the 
                      protocol engine. 
#>
function GetPingFederateOperationalMode
{
    $runPropertiesPath = $args[0]
    $runPropertiesEntryForOperationalMode = Get-Content $runPropertiesPath | Where { $_ -match "^pf.operational.mode=" -and $_.trim() -ne "" }
    # $runPropertiesContents
    $serverMode = ""
    # $runPropertiesContents.Length
    if ($runPropertiesEntryForOperationalMode.Length -gt 0 )
    {
        $serverMode = $runPropertiesEntryForOperationalMode.Split("=")[1]
    }
    return $serverMode
    # $hashTable = convertfrom-stringdata -stringdata $runPropertiesContents
    # $hashTable[0]
}


function ZipPingFederateLogFiles {
	$pingFedLogsFolder = $args[0]
	$pingFedLogsFolder
	$machineFQDN = GetMachineFQDN
	$zipFilePath = $pingFedLogsFolder+'/'+$machineFQDN+$(get-date -f MM-dd-yyyy_HH_mm_ss)+'.zip'
	$zipFilePath 
	# $zipFileName = $(get-date -f MM-dd-yyyy_HH_mm_ss) +'.zip'
	# $zipFilePath = JOIN-PATH $pingFedLogsFolder $machineFQDN $zipFileName
	# $zipFilePath = JOIN-PATH $pingFedLogsFolder $zipFileName
	$logFilesFilter = $pingFedLogsFolder +'/server*.log*'
	# ls $logFilesFilter | ZipFiles $zipFilePath
	New-Zipfile $zipFilePath $logFilesFilter
	# c:/pingfederate_logs/CHLCNU403B80D.CORP.LPL.COM09-11-2015_12_37_15.zip
}

function ZipFiles { 
  Param([string]$path) 

  if (-not $path.EndsWith('.zip')) {$path += '.zip'} 

  if (-not (test-path $path)) { 
    set-content $path ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) 
  } 
  $path
  $ZipFile = (new-object -com shell.application).NameSpace($path) 
  $input | foreach {$zipfile.CopyHere($_.fullname)} 
} 


function New-ZipFile {
	#.Synopsis
	#  Create a new zip file, optionally appending to an existing zip...
	[CmdletBinding()]
	param(
		# The path of the zip to create
		[Parameter(Position=0, Mandatory=$true)]
		$ZipFilePath,
 
		# Items that we want to add to the ZipFile
		[Parameter(Position=1, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
		[Alias("PSPath","Item")]
		[string[]]$InputObject = $Pwd,
 
		# Append to an existing zip file, instead of overwriting it
		[Switch]$Append,
 
		# The compression level (defaults to Optimal):
		#   Optimal - The compression operation should be optimally compressed, even if the operation takes a longer time to complete.
		#   Fastest - The compression operation should complete as quickly as possible, even if the resulting file is not optimally compressed.
		#   NoCompression - No compression should be performed on the file.
		[System.IO.Compression.CompressionLevel]$Compression = "Optimal"
	)
	begin {
		# Make sure the folder already exists
		[string]$File = Split-Path $ZipFilePath -Leaf
		[string]$Folder = $(if($Folder = Split-Path $ZipFilePath) { Resolve-Path $Folder } else { $Pwd })
		$ZipFilePath = Join-Path $Folder $File
		# If they don't want to append, make sure the zip file doesn't already exist.
		if(!$Append) {
			if(Test-Path $ZipFilePath) { Remove-Item $ZipFilePath }
		}
		$Archive = [System.IO.Compression.ZipFile]::Open( $ZipFilePath, "Update" )
	}
	process {
		foreach($path in $InputObject) {
			foreach($item in Resolve-Path $path) {
				# Push-Location so we can use Resolve-Path -Relative
				Push-Location (Split-Path $item)
				# This will get the file, or all the files in the folder (recursively)
				foreach($file in Get-ChildItem $item -Recurse -File -Force | % FullName) {
					# Calculate the relative file path
					$relative = (Resolve-Path $file -Relative).TrimStart(".\")
					# Add the file to the zip
					$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($Archive, $file, $relative, $Compression)
				}
				Pop-Location
			}
		}
	}
	end {
		$Archive.Dispose()
		Get-Item $ZipFilePath
	}
}

function GetPingFederateLogFolder
{
	$runPropertiesPath = $args[0]
    $runPropertiesEntryForLogFolder = Get-Content $runPropertiesPath | Where { $_ -match "^pf.log.dir=" -and $_.trim() -ne "" }
    # $runPropertiesContents
    $logFolderPath = ""
    # $runPropertiesContents.Length
    if ($runPropertiesEntryForLogFolder.Length -gt 0 )
    {
        $logFolderPath = $runPropertiesEntryForLogFolder.Split("=")[1]
    }
    return $logFolderPath
}

<#
This function pings the heartbeat URL or the admin console URL If the current PingFederate machine is an ENGIN 
or ADMIN console respectively (in case of clustered environment) 
or both the URLs if the machine has both the engine and admin console (e.g. in case of local development machine)
#>
function CheckPingFederateStatusAfterServiceStart
{

$PingFedOperationalMode = $args[0]

switch ($PingFedOperationalMode){
     STANDALONE 
     {
        "STANDALONE mode"
        $adminURL = GetPingFedAdminUrl 
        $heartbeatURL = GetPingFedHeartbeatUrl
        IsPingFederateAdminOK $adminURL
        IsPingFedHeartbeatOK $heartbeatURL
        break
     }
     CLUSTERED_CONSOLE 
     {
        "CLUSTERED_CONSOLE mode"
        $adminURL = GetPingFedAdminUrl 
        IsPingFederateAdminOK $adminURL
        break
     }
     CLUSTERED_ENGINE 
     { 
        "CLUSTERED_ENGINE mode"
        $heartbeatURL = GetPingFedHeartbeatUrl
        IsPingFedHeartbeatOK $heartbeatURL
        break
     }
     default {"Unrecognized mode"; break}
     }

}