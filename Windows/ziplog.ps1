# Define the log file for recording script activities
$LOGFILE = "C:\var\log\ziplog_log_archive.log"

# Function to log messages
function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LOGFILE -Value "[$timestamp] $message"
}

# Log script start
Log-Message "Log Archive Script started."

# Display a professional header
Write-Host "--------------------------------------------------"
Write-Host "     LOG ARCHIVING AND ZIP UTILITY"
Write-Host "--------------------------------------------------"
Write-Host " A N   O P E N   S O U R C E   P R O J E C T"
Write-Host " Developed by Ajay Agrawal"
Write-Host "--------------------------------------------------"

# Prompt for user inputs with explanations
$LOGPATH = Read-Host "Enter the complete path where your logs are stored: "
$NOSDays = Read-Host "Enter the number of days before which you want to archive logs: "

# Log user inputs
Log-Message "User provided log path: $LOGPATH"
Log-Message "User provided days for archiving: $NOSDays"

# Validate the log path
if (-not (Test-Path -Path $LOGPATH -PathType Container)) {
    Write-Host "Error: The specified log path doesn't exist."
    Log-Message "Error: The specified log path doesn't exist."
    Exit 1
}

# Create a timestamp for the archive directory
$TIMESTAMP = Get-Date -Format "dd-MM-yyyy_HH-mm"
$MKDIRNAME = "AGEDLOGS_$TIMESTAMP"

# Count the total number of logs in the specified directory
$LOGCOUNT = (Get-ChildItem -Path $LOGPATH -File -Filter *.log | Measure-Object).Count

# Find logs older than NOSDays
$AGING_LOGS = (Get-ChildItem -Path $LOGPATH -File -Filter *.log | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$NOSDays) } | Measure-Object).Count

Write-Host "Total number of logs present in $LOGPATH: $LOGCOUNT"
Write-Host "Number of logs older than $NOSDays days: $AGING_LOGS"

# Log the log count and aged log count
Log-Message "Total logs in $LOGPATH: $LOGCOUNT"
Log-Message "Aged logs (older than $NOSDays days): $AGING_LOGS"

if ($AGING_LOGS -eq 0) {
    Write-Host "No logs older than $NOSDays days found in $LOGPATH. Nothing to archive."
    Log-Message "No logs older than $NOSDays days found. Nothing to archive."
}
else {
    # Create a temporary file to store the list of aged logs
    $TEMPFILE = "C:\temp\templist_$TIMESTAMP.txt"

    Write-Host "Redirecting the names of aged logs to $TEMPFILE."
    Get-ChildItem -Path $LOGPATH -File -Filter *.log | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$NOSDays) } | ForEach-Object { $_.FullName } | Out-File -FilePath $TEMPFILE

    Write-Host "`nList of logs older than $NOSDays days:"
    Get-Content -Path $TEMPFILE

    # Create the archive directory and move logs into it
    New-Item -ItemType Directory -Path "$LOGPATH\$MKDIRNAME"
    Get-Content -Path $TEMPFILE | ForEach-Object {
        Move-Item -Path $_ -Destination "$LOGPATH\$MKDIRNAME"
    }

    # Create a compressed archive of the directory
    Compress-Archive -Path "$LOGPATH\$MKDIRNAME" -DestinationPath "$LOGPATH\$MKDIRNAME.tar.gz"

    # Clean up temporary files and directories
    Remove-Item -Path $TEMPFILE
    Remove-Item -Path "$LOGPATH\$MKDIRNAME" -Force -Recurse

    Write-Host "`nLogs older than $NOSDays days have been archived successfully."
    Log-Message "Logs older than $NOSDays days have been archived successfully."
    Write-Host "Archive Name: $MKDIRNAME.tar.gz"
    Write-Host "Archive Path: $LOGPATH"
    Write-Host "Absolute Archive Path: $LOGPATH\$MKDIRNAME.tar.gz"
    Log-Message "Archive Name: $MKDIRNAME.tar.gz"
    Log-Message "Archive Path: $LOGPATH\$MKDIRNAME.tar.gz"
}

# Log script completion
Log-Message "Log Archive Script completed."

Write-Host "`nThanks for using the Log Archiving and Zip Utility."
Write-Host "Take care!"

