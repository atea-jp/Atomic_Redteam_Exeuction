# Prompt the user for the ID (string)
$ID = Read-Host "Enter the ID (string)"

# Prompt the user for the Test (comma-separated numerical values)
$Test = Read-Host "Enter the Test (comma-separated numerical values)"

# Create a folder to store the logs
$LogsFolder = "C:\Temp\$ID-$Test-logs"
New-Item -ItemType Directory -Path $LogsFolder

# Invoke-AtomicTest with -CheckPrereqs
Invoke-AtomicTest $ID -CheckPrereqs

# Invoke-AtomicTest with -GetPrereqqs
Invoke-AtomicTest $ID -GetPrereqqs

# Construct the execution log path
$ExecutionLogPath = "$LogsFolder\AR_ExecLog_${ID}_${Test}.csv"

# Invoke-AtomicTest with -TestNumbers and -ExecutionLogPath
Invoke-AtomicTest $ID -TestNumbers $Test -ExecutionLogPath $ExecutionLogPath

# Export Windows Event logs to EVTX format
$EventLogPath = "$LogsFolder\AR_EventLogs_${ID}_${Test}.evtx"

Get-WinEvent -ListLog * | Select-Object LogName, LogFilePath | ForEach-Object {
    $name = $_.LogName
    $safeName = $name.Replace("/", "-")
    wevtutil.exe EPL $name $EventLogPath
}

# Output the path to the event logs
Write-Host "Windows Event logs exported to $EventLogPath"

# Zip the logs folder
$LogsZipFile = "C:\Temp\$ID_$Test_logs.zip"
Compress-Archive -Path $LogsFolder -DestinationPath $LogsZipFile -Force

# Output the path to the zip file
Write-Host "Logs zipped to $LogsZipFile"

# Clean up the environment
Invoke-AtomicTest $ID -TestNumbers $Test -Cleanup

# Clear all Windows Event logs
wevtutil el | ForEach-Object { wevtutil cl "$_" }


