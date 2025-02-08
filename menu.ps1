# Menu program for PowerShell

# Function to validate and read the CSV file
function Read-AppList {
    param (
        [string]$csvPath = "$PSScriptRoot\apps.csv"
    )
    
    if (-not (Test-Path $csvPath)) {
        Write-Error "CSV file not found at $csvPath"
        return $null
    }
    
    try {
        $apps = Import-Csv $csvPath
        return $apps
    }
    catch {
        Write-Error "Error reading CSV file: $_"
        return $null
    }
}

# Function to display the menu of apps

function Show-AppMenu {
    param (
        [Parameter(Mandatory=$true)]
        $apps
    )
    
    Write-Host "`n::: PowerShell Menu :::`n" -ForegroundColor Cyan
    
    $apps | Where-Object { Test-Path ([System.Environment]::ExpandEnvironmentVariables($_.Path)) } | 
        Sort-Object Alias | ForEach-Object {
            Write-Host ("{0,-30} {1}" -f $_.Alias, $_.Name)
    }
    Write-Host ""
}

function Set-AppAliases {
    param (

        [Parameter(Mandatory=$true)]
        $apps
    )
    
    $apps | ForEach-Object {
        $expandedPath = [System.Environment]::ExpandEnvironmentVariables($_.Path)
        if (-not [string]::IsNullOrEmpty($_.Path) -and 
            -not [string]::IsNullOrEmpty($_.Alias) -and 
            (Test-Path $expandedPath)) {
            
            $execPath = $expandedPath  # Capture the path in this scope
            $scriptBlock = {
                param([Parameter(ValueFromRemainingArguments=$true)]$args)
                & $execPath $args
            }.GetNewClosure()  # Capture the current value of $execPath
            
            Set-Item -Path "Function:Global:$($_.Alias)" -Value $scriptBlock
        }
    }
}

# Main script execution
$apps = Read-AppList

if ($apps) {
    Show-AppMenu $apps
    Set-AppAliases $apps
}