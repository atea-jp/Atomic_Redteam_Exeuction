# Prompt the user for the ID (string)
$ID = Read-Host "Enter the ID (string)"

# Prompt the user for the Test (comma-separated numerical values)
$Test = Read-Host "Enter the Test (comma-separated numerical values)"

# Create a folder to store the logs
$LogsFolder = "C:\Temp\$ID-$Test-logs"
New-Item -ItemType Directory -Path $LogsFolder
$EventLogPath = "$LogsFolder\EventLogs"
New-Item -ItemType Directory -Path $EventLogPath

# Invoke-AtomicTest with -CheckPrereqs
Invoke-AtomicTest $ID -CheckPrereqs

# Invoke-AtomicTest with -GetPrereqqs
Invoke-AtomicTest $ID -GetPrereqs

# Construct the execution log path
$ExecutionLogPath = "$LogsFolder\Atomic_Red_Team_Execution_Log_MITRE_${ID}_TEST_${Test}.csv"

# Invoke-AtomicTest with -TestNumbers and -ExecutionLogPath
Invoke-AtomicTest $ID -TestNumbers $Test -ExecutionLogPath $ExecutionLogPath


# Exporting Logs to CSV file.
Get-WinEvent -ListLog * | select LogName, RecordCount | ForEach-Object {
    if ($_.RecordCount -gt 0) {
            $EventLogName = $_.LogName
            $SafeLogName = $EventLogName.Replace("/", "-")
            Get-WinEvent -LogName $EventLogName | Export-csv $LogsFolder\$EventLogPath\$SafeLogName.csv
            Wevtutil cl $EventLogName
    }

}

# Output the path to the event logs
Write-Host "Windows Event logs exported to $EventLogPath"

# Zip the logs folder
$LogsZipFile = "C:\Temp\${ID}_${Test}_logs.zip"
Compress-Archive -Path $LogsFolder -DestinationPath $LogsZipFile -Force

# Output the path to the zip file
Write-Host "Logs zipped to $LogsZipFile"

# Clean up the environment
Invoke-AtomicTest $ID -TestNumbers $Test -Cleanup
