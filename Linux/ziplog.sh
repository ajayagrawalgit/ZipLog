#!/bin/bash

# Clear the screen
clear

# Define the log file for recording script activities
LOGFILE="/var/log/ziplog_log_archive.log"

# Function to log messages
log() {
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] $1" >> "$LOGFILE"
}

# Log script start
log "Log Archive Script started."

# Display a professional header
echo -e "--------------------------------------------------"
echo -e "          LOG ARCHIVING AND ZIP UTILITY"
echo -e "--------------------------------------------------"
echo -e " A N   O P E N   S O U R C E   P R O J E C T"
echo -e " Developed by Ajay Agrawal"
echo -e "--------------------------------------------------"

# Prompt for user inputs with explanations
read -p "Enter the complete path where your logs are stored: " LOGPATH
read -p "Enter the number of days before which you want to archive logs: " NOSDays

# Log user inputs
log "User provided log path: $LOGPATH"
log "User provided days for archiving: $NOSDays"

# Validate the log path
if [[ ! -d "$LOGPATH" ]]; then
    echo "Error: The specified log path doesn't exist."
    log "Error: The specified log path doesn't exist."
    exit 1
fi

# Create a timestamp for the archive directory
TIMESTAMP=$(date "+%d-%m-%Y_%H-%M")
MKDIRNAME="AGEDLOGS_$TIMESTAMP"

# Count the total number of logs in the specified directory
LOGCOUNT=$(find "$LOGPATH" -type f -name "*.log" | wc -l)

# Find logs older than NOSDays
AGING_LOGS=$(find "$LOGPATH" -type f -name "*.log" -mtime +"$NOSDays" | wc -l)

echo "Total number of logs present in $LOGPATH: $LOGCOUNT"
echo "Number of logs older than $NOSDays days: $AGING_LOGS"

# Log the log count and aged log count
log "Total logs in $LOGPATH: $LOGCOUNT"
log "Aged logs (older than $NOSDays days): $AGING_LOGS"

if [[ $AGING_LOGS -eq 0 ]]; then
    echo "No logs older than $NOSDays days found in $LOGPATH. Nothing to archive."
    log "No logs older than $NOSDays days found. Nothing to archive."
else
    # Create a temporary file to store the list of aged logs
    TEMPFILE="templist_$TIMESTAMP.txt"

    echo "Redirecting the names of aged logs to $TEMPFILE."
    find "$LOGPATH" -type f -name "*.log" -mtime +"$NOSDays" > "$TEMPFILE"

    echo -e "\nList of logs older than $NOSDays days:"
    cat "$TEMPFILE"

    # Create the archive directory and move logs into it
    mkdir "$LOGPATH/$MKDIRNAME"
    while read -r file; do
        mv "$file" "$LOGPATH/$MKDIRNAME"
    done < "$TEMPFILE"

    # Create a compressed archive of the directory
    tar -czf "$LOGPATH/$MKDIRNAME.tar.gz" -C "$LOGPATH" "$MKDIRNAME"

    # Clean up temporary files and directories
    rm -f "$TEMPFILE"
    rm -rf "$LOGPATH/$MKDIRNAME"

    echo -e "\nLogs older than $NOSDays days have been archived successfully."
    log "Logs older than $NOSDays days have been archived successfully."
    echo "Archive Name: $MKDIRNAME.tar.gz"
    echo "Archive Path: $LOGPATH"
    echo "Absolute Archive Path: $LOGPATH/$MKDIRNAME.tar.gz"
    log "Archive Name: $MKDIRNAME.tar.gz"
    log "Archive Path: $LOGPATH/$MKDIRNAME.tar.gz"
fi

# Log script completion
log "Log Archive Script completed."

echo -e "\nThanks for using the Log Archiving and Zip Utility."
echo -e "Take care!\n"

