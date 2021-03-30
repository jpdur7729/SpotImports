# ------------------------------------------------------------------------------
#                     Author    : FIS - JPD
#                     Time-stamp: "2021-03-30 11:37:41 jpdur"
# ------------------------------------------------------------------------------

# Inspired from https://mcpmag.com/articles/2018/07/10/check-for-locked-file-using-powershell.aspx?m=1
# Alternative https://stackoverflow.com/questions/24992681/powershell-check-if-a-file-is-locked
# --------------------------------------------------------
# Given an absolute path - checks that the file is locked 
# --------------------------------------------------------
function Test-FileLock {
    param (
	[parameter(Mandatory=$true)][string]$Path
    )

    $oFile = New-Object System.IO.FileInfo $Path

    # If it does not exist --> No FileLock
    if ((Test-Path -Path $Path) -eq $false) {
	return $false
    }

    # Test if it is possible to open
    try {
	$oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

	if ($oStream) {
	    $oStream.Close()
	}
	return $false
    } catch {
	# file is locked by a process.
	return $true
    }
}

# Debug
# Write-Host "Within CheckDashBoard"

# Test Dashboard.xlsx
if (Test-FileLock ($Exec_Dir+"\Dashboard.xlsx")) {
    Write-Host "Close Dashboard.xlsx in order to allow execution"
    return $true 
}

# Test FXRate.xlsx
if (Test-FileLock ($Exec_Dir+"\FXrate.xlsx")) {
    Write-Host "Close FXrate.xlsx in order to allow execution"
    return $true 
}

$false

