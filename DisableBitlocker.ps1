# Define the log directory and log file path
$logPath = "C:\temp"
$logFile = Join-Path -Path $logPath -ChildPath "BitLockerLog.txt"

# Check if the directory exists, if not, create it
if (-not (Test-Path -Path $logPath)) {
    New-Item -ItemType Directory -Path $logPath | Out-Null
}

# Function to write log messages
function Write-Log {
    Param (
        [string]$Message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -FilePath $logFile -Append
}

# Check if the BitLocker module is installed
$module = Get-Module -ListAvailable -Name BitLocker
if (-not $module) {
    Write-Log "The BitLocker module is not installed. Please install the module to proceed."
    exit
}

# Check all drives and disable BitLocker if it is enabled
try {
    $bitLockerVolumes = Get-BitLockerVolume
    foreach ($volume in $bitLockerVolumes) {
        if ($volume.ProtectionStatus -eq 'On') {
            Write-Host "Drive $($volume.MountPoint) is encrypted. Attempting to disable BitLocker..."
            Disable-BitLocker -MountPoint $volume.MountPoint
            Write-Log "BitLocker on drive $($volume.MountPoint) has been disabled."
        } else {
            Write-Host "Drive $($volume.MountPoint) is not encrypted."
        }
    }
} catch {
    Write-Log "An error occurred: $_"
}