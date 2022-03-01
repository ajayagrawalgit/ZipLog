#HEADER SECTION

Write-Host @"
 _____  ___   ____    _        ___     ____ 
|__  / |_ _| |  _ \  | |      / _ \   / ___|
  / /   | |  | |_) | | |     | | | | | |  _ 
 / /_   | |  |  __/  | |___  | |_| | | |_| |
/____| |___| |_|     |_____|  \___/   \____|                                  
----------------------------------------------
   AN OPEN SOURCE PROJECT | BY AJAY AGRAWAL
----------------------------------------------


"@


#USER INPUTS
$LOGPATH = Read-Host -Prompt "Enter the COMPLETE PATH where your logs are stored "
$NOSDays = Read-Host -Prompt "Enter the No. of DAYS before which you want the logs to be zipped "

######################################################################################################

#VARIABLE DECLATATIONS
$AGING_LOGS_COUNT_OBJECT = Get-ChildItem "$LOGPATH"*.log -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-$NOSDays))} | Measure-Object
$AGING_LOGS = $AGING_LOGS_COUNT_OBJECT.Count

$LOGCOUNT_OBJECT = Get-ChildItem "$LOGPATH"*.log -Recurse | Measure-Object
$LOGCOUNT = $LOGCOUNT_OBJECT.Count

$ZIPPATH = $LOGPATH + "\AGEDLOGS_$((Get-Date).ToString('MM-dd-yyyy_hh-mm-ss')).zip"
$ZIPNAMESPLIT = $ZIPPATH.Split("\")
$ZIPNAMEINDEX = $ZIPNAMESPLIT.Count -1

######################################################################################################

Write-Host ""
Write-Host "TOTAL No. OF LOGS PRESENT IN $LOGPATH = $LOGCOUNT"
Write-Host "Out of which, $AGING_LOGS is the number of log(s) updated $NOSDays DAYS ago"
Write-Host ""

######################################################################################################

Start-Sleep -Seconds 5

#LOGIC
if( $AGING_LOGS -eq 0 ) {
    Write-Host "Hence, there are no log files present in $LOGPATH which are older than $NOSDays , You don't need to run this utility here in this path."
}
else {

    Write-Host "Below is the list of all the logs which are older than $NOSDays Days ->"
    Get-ChildItem "$LOGPATH"*.log* -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-7))} | Select-Object Name, CreationTime, Length, @{name='FileSize in MB';expr={[math]::Round($_.Length/1024/1024,5)}}, LastAccessTime, LastWriteTime | Sort-Object -Property LastWriteTime -Descending | Format-Table

    Write-Host ""
    Start-Sleep -Seconds 5
    Write-Host ""

    Write-Host "--------------------------------------------------------------------------------------------------------------------"
	Write-Host "Moving all the logs older than $NOSDays present in $LOGPATH to "$ZIPNAMESPLIT.GETVALUE($ZIPNAMEINDEX)" in the same location now."
	Write-Host "--------------------------------------------------------------------------------------------------------------------"

    Start-Sleep -Seconds 2

    Get-ChildItem "$LOGPATH"*.log -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-$NOSDays))} | Compress-Archive -Verbose -DestinationPath $ZIPPATH

    Get-ChildItem "$LOGPATH"*.log -Recurse | Where-Object {($_.LastWriteTime -lt (Get-Date).AddDays(-$NOSDays))} | Remove-Item -Verbose

    Write-Host ""
    Write-Host ""

    Write-Host "All the logs older than $NOSDays Days have been ZIPLOGGED now ;) Please find the details below: "
    Write-Host "Name of ZIPLOG:"$ZIPNAMESPLIT.GETVALUE($ZIPNAMEINDEX)
    Write-Host "Path where ZIPLOG is stored: $LOGPATH"
    Write-Host "& Hence, the Absolute Path of the ZIPLOG is: $ZIPPATH"

    Start-Sleep -Seconds 5
}

Write-Host ""
Write-Host ""
Write-Host "Thanks for using ZIPLOG. Stay Happy and Stay Motivated :)"
Write-Host "Take Care"
Write-Host ""
Write-Host ""
Start-Sleep -Seconds 5

###############################################################################################
######################################## END OF SCRIPT ########################################
###############################################################################################