# Atomic_Redteam_Exeuction


This is a helper script that will help for executing Atomic Red Team tests and collecting Windows Event logs together with it. 


To run the script the following needs to be in place: 

## Installation

1. Run PowerShell as Administrator and set the execution policy to bypass

```PowerShell
Set-ExecutionPolicy bypass
```

2. Download and Install Invoke-Atomic RedTeam

```PowerShell
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing);
Install-AtomicRedTeam -getAtomics
```

3. Download RunAtomic.ps1
```PowerShell
git clone https://github.com/atea-jp/Atomic_Redteam_Exeuction.git
```

## Executing the Test

To execute the script you need a CSV file containing the MITRE ATT&CK IDs and test cases you would like to test. 

```PowerShell
.\RunAtomic.ps1 mycsv.csv
```
### CSV File
The CSV file need to be in this Format 

```
ID,Test,Case,Numbers
```

To only run a single test case for a specific ID: 

```
T1562,1
```

To run multiple test cases for a specific ID:
```
T1562,1,2
```

To run multiple test cases, but seperately:
```
T1562,1
T1562,2
```

To run test cases for multiple IDs:
```
T15162,1
T1091,1
```

