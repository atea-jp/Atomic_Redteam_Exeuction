# Check if a CSV file path argument is provided
if ($args.Count -ne 1) {
    Write-Host "Please provide the path to the CSV file as a command-line argument."
    Exit
}

# Get the CSV file path from the command-line argument
$csvFilePath = $args[0]

# Check if the CSV file exists
if (-not (Test-Path $csvFilePath -PathType Leaf)) {
    Write-Host "The specified CSV file does not exist."
    Exit
}

# Read the CSV file
$csvData = Get-Content $csvFilePath

# Create a folder to store the logs
$LogsFolder = "C:\Temp\$ID-$Test-logs"
New-Item -ItemType Directory -Path $LogsFolder
$EventLogPath = "$LogsFolder\EventLogs"
New-Item -ItemType Directory -Path $EventLogPath


# Process each line in the CSV file
foreach ($line in $csvData) {
    $ID, $Test = $line -split ',', 2
    $Test = $Test.Trim()

    # Output the $ID and $Test values
    Write-Host "ID: $ID"
    Write-Host "Test: $Test"
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
                Get-WinEvent -LogName $EventLogName | Export-csv $EventLogPath\$SafeLogName.csv
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


}