# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-14 11:37:13 jpdur"
# ------------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Detailed presentation in Presentation .org 
# -------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------
# https://powertoe.wordpress.com/2014/04/26/you-know-powershell-is-an-object-oriented-language-right/
# Object for the poor as it is simply a struct (C Equivalent) with some extra functions added
# Relies on the default psobject
# ----------------------------------------------------------------------------------------------------

# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.1
# PowerShell

# Class SoundNames : System.Management.Automation.IValidateSetValuesGenerator {
#     [String[]] GetValidValues() {
#         $SoundPaths = '/System/Library/Sounds/',
#             '/Library/Sounds','~/Library/Sounds'
#         $SoundNames = ForEach ($SoundPath in $SoundPaths) {
#             If (Test-Path $SoundPath) {
#                 (Get-ChildItem $SoundPath).BaseName
#             }
#         }
#         return [String[]] $SoundNames
#     }
# }

# The [SoundNames] class is then implemented as a dynamic ValidateSet value as follows:
# PowerShell

# Param(
#     [ValidateSet([SoundNames])]
#     [String]$Sound
# )








# Management of all parameters 
param(
    [Parameter(Mandatory=$false)] [string] $Exec_Dir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition),
    # [Parameter(Mandatory=$false)] [string] $ListCurrenciesStr = "GBP,USD,JPY",
    [Parameter(Mandatory=$false)] [string] $ListCurrenciesStr,
    [Parameter(Mandatory=$false)] [ValidateSet('NoAction','F2')]     [string] $Processing = "NoAction",
    [Parameter(Mandatory=$false)] [ValidateSet('FIS','F2')]          [string] $Format = "FIS",
    [Parameter(Mandatory=$false)] [ValidateSet('ECB','MAS')]         [string] $Source = "ECB",
    [Parameter(Mandatory=$false)] [ValidateSet('CsvXlsx','CsvOnly')] [string] $Output = "CsvXlsx",
    [Parameter(Mandatory=$false)] [ValidateSet(",",";","|")]         [string] $CSVSep = ",",
    [Parameter(Mandatory=$false)] [ValidateSet("FXPair","FXRate")]   [string] $FISType = "FXPair",
    [Parameter(Mandatory=$false)] [string] $FISVariant = "Closing",
    [Parameter(Mandatory=$false)] [string] $StartDate,
    [Parameter(Mandatory=$false)] [string] $EndDate
)

# Import module with some standardized function
import-module -Force -Name ./SpotImportsLib

# # 1st value of the list is the default value 
# $ListSources    = "ECB","MAS"
# $ListOutput     = "CsvXlsx", "CsvOnly"
# $ListProcessing = "NoAction","F2"
# $ListCSVSeps    = ",",";","|"
# $ListOutput     = "CsvXlsx", "CsvOnly"
# $ListFormat     = "F2", "FIS"

# Method to validate that the received parameters is in a list
          # [Parameter(Mandatory=$true)]
          # [ValidateSet('Small','Medium','Large')]
          # [String]$size

# Convert String Date to Date
if ($StartDate.length -eq 0) {$StartDateasDate = $null} else { $StartDateasDate = [datetime]::ParseExact($StartDate,"yyyy-MM-dd", $null) }
if ($EndDate.length -eq 0)   {$EndDateasDate   = $null} else { $EndDateasDate   = [datetime]::ParseExact($EndDate  ,"yyyy-MM-dd", $null) }

# ---------------------------------------------------------------------------------------
# Check Parameters / for more complex checks that simply ValidateSet
# and for extra adjustments of default data
# returns an object which describes all the parameters => ready to be used for dashboard
# ---------------------------------------------------------------------------------------
. ./CheckParameters.ps1

# -------------------------------------------------
# Based on the Source -> Setup script to be called
# And Ad-hoc module to be loaded
# $SourceDef = &"./ECB/ECBSetup.ps1"
# As a result SourceDeb has all the method and Data associated
# -------------------------------------------------
$Setup        = "./"+$Source+"/"+$Source+"Setup.ps1"
$SourceModule = "./"+$Source+"/"+$Source+"Lib"
Import-module -Force -Name ($SourceModule)
$SourceDef = &($Setup)

# -------------------------------------------------
# Based on the Format -> Setup script to be called
# And Ad-hoc module to be loaded
# $FormatDef = &"./Format/FISSetup.ps1"
# As a result SourceDeb has all the method and Data associated
# -------------------------------------------------
$FormatSetup = "./Format/"+$Format+"Setup.ps1"
$FormatDef   = &($FormatSetup)

# # CHeck that the dashboard is available - if not abort
# . ./CHeckDashboard.ps1

# Debug Data
# $SourceDef.BaseCurrency
# $StartDateasDate
# $EndDateasDate

# Execute the Source specific extract and format the data accordingly
# ------------------------------------------------------------------------- 
# The return Data is standardized as an array of objects with the following structure 
# Date: A string in format yyyy-MM-dd 
# CCY1: By default the BaseCurrency of the Source - ISO format 
# CCY2: The other currency - ISO format
# Value: 1 CCY1 = Value CCY2
# Example xxx EUR GBP 0.8 ==> 1 EUR = 0.8 GBP 
# ------------------------------------------------------------------------- 
$StandardData = $SourceDef.ExtractData($StartDateasDate,$EndDateasDate)

# # Debug
# Write-Output "In the main module"
# $StandardData

# Prepare the Output of the CSV File => Based on the Format 
# $OutputCSV  = 'Market entity type,Market entity code,Variant,Date,Value' + "`n"
$OutputCSV  = $FormatDef.Header($FISType,$CSVSep)

Write-Output "List Curr",$ListCurrencies,"End List"

# -------------------------------------------------------------------
# Process the data as required - This is common to all sources 
# now that the data extract has been performed and data standardized
# -------------------------------------------------------------------
$StandardData | ForEach-Object {

    # Extra generic treatments can be added accordingly
    # CCY1 is the reference currency of the source  
    # CCY2 is the currency for which the exchange rate is required
    # --------------------------------------------------------
    # If ListCurrencies is empty no currency is filtered if not ...
    If ( ($ListCurrencies -eq $null) -or ($ListCurrencies.Contains($_.CCY2)) ) {

	    # Output the line as provided
	    $OutputCSV  += $FormatDef.Line($FISType,$CSVSep,$_.CCY1,$_.CCY2,$_.Date,$_.Value,$FISVariant)
	}
	
}

# Generate the CSV file and overwrite the CSV file if it exists
$OutputCSV | Out-File ./FXrate.csv

# Copy the generated csv file
cp ./FXrate.csv ($Exec_Dir+"/Data/FXrate"+$BatchID+".csv")

# Generate the XLSX file if required  
if ($Output -ne "CsvOnly") {

    # Delete the destination file and convert the csv into an Excel spreadsheet
    # If any error such as the file does not exist it continues
    rm FXrate.xlsx -Force -ErrorAction Continue
    Import-Csv -Path .\FXrate.csv -Delimiter $CSVSep | Export-Excel -Show -AutoSize -AutoFilter FXrate.xlsx -WorksheetName "Market data"

    # Copy the generated xlsx file
    cp ./FXrate.xlsx ($Exec_Dir+"/Data/FXrate"+$BatchID+".xlsx")
}

# Remove the ad-hoc module which has been created
Remove-Module ($Source+"Lib")

# That way the module is only used as part of the script and no afterwards
Remove-Module SpotImportsLib
