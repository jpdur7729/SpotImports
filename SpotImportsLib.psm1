# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-14 07:29:26 jpdur"
# ------------------------------------------------------------------------------

# Signature function to test if the module is available 
function SpotImportFct {
    Write-Host "SpotImportLib Module is available"
}

# ----------------------------------------------------------------------------
# https://devblogs.microsoft.com/powershell/new-object-psobject-property-hashtable/
# Creation of the Source object which is dynamically extended with the ad-hoc 
# methods/functions so that it can be called from the main script
# ----------------------------------------------------------------------------
function SourceDef {
    param(
          [Parameter(Mandatory=$true)] [String]$Name,
          [Parameter(Mandatory=$true)] [string]$BaseCurrency
    )

    # Object Creation
    $src = New-Object PSObject -Property @{
        Name = $Name 
        BaseCurrency = $BaseCurrency
    }

    # Key to actually return the object 
    $src
}

# ---------------------------------------------------------
# Create an object to handle the different type of Formats
# 2 methods to be added when instantiating the object 
# ---------------------------------------------------------
function FormatDef {
    param(
          [Parameter(Mandatory=$true)] [String]$Name
    )

    # Object Creation
    $obj = New-Object PSObject -Property @{
        Name = $Name 
    }

    # Key to actually return the object 
    $obj
}
