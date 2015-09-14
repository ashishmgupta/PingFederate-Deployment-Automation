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


# Create a folder named <machinename>_RSAlogs_<timestamp>

# Tomcat log location - C:\Program Files\Apache Software Foundation\Tomcat 7.0\logs
# Copy all the files in the tomcat log location  to a folder named <machinename>_tomcat_timestamp
# Delete all the files from the tomcat log location

# RSA AA log location - D:\RSA\Logs
# Delete all the aa_server.log* files and the aa_soapcalls* modified today in the RSA log location  to a folder named <machinename>_RSA_timestamp




function GetMachineFQDN
{
    return $env:computername+"."+$env:userdnsdomain
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


function GetMachineFQDN
{
    return $env:computername+"."+$env:userdnsdomain
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


function CreateFolderIfDoesnotExist
{
	$folderName = $args[0]
    $folderName 
	if (!(Test-Path -path $folderName)) {New-Item $folderName -Type Directory}
	{
		New-Item -Path $folderName -ItemType Directory -Force
	}
}