# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-03-30 08:41:05 jpdur"
# ------------------------------------------------------------------------------

# -------------------------------------------------------------------------
# Detailed explanation in Readme.org 
# -------------------------------------------------------------------------

# Management of all parameters 
param(
    [Parameter(Mandatory=$false)] [string] $Exec_Dir = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition),
    # [Parameter(Mandatory=$false)] [string] $ListCurrenciesStr = "GBP,USD,JPY",
    [Parameter(Mandatory=$false)] [string] $ListCurrenciesStr,
    # [Parameter(Mandatory=$false)] [string] $ListDatesStr = "2021-01-01,2021-02-11,2021-02-12,2021-01-01,2020-13-13",
    [Parameter(Mandatory=$false)] [string] $ListDatesStr,
    [Parameter(Mandatory=$false)] [ValidateSet('NoAction','F2')]     [string] $Processing = "NoAction",
    [Parameter(Mandatory=$false)] [ValidateSet('FIS','F2')]          [string] $Format = "FIS",
    [Parameter(Mandatory=$false)] [ValidateSet('ECB','MAS','FED')]   [string] $Source = "ECB",
    [Parameter(Mandatory=$false)] [ValidateSet('CsvXlsx','CsvOnly')] [string] $Output = "CsvXlsx",
    [Parameter(Mandatory=$false)] [ValidateSet(",",";","|")]         [string] $CSVSep = ",",
    [Parameter(Mandatory=$false)] [ValidateSet("FXPair","FXRate")]   [string] $FISType = "FXPair",
    [Parameter(Mandatory=$false)] [ValidateSet("Show","NoShow")]     [string] $Show = "Show",
    [Parameter(Mandatory=$false)] [string] $FISVariant = "Closing",
    [Parameter(Mandatory=$false)] [string] $BaseCurrency,
    [Parameter(Mandatory=$false)] [string] $StartDate,
    [Parameter(Mandatory=$false)] [string] $EndDate
)

# Execution is done from the directory of the script ==> relative paths are thus possible
cd $Exec_Dir

# ----------------------------------------------------------------------
# Before Starting the process let's check that Dashboard is accessible 
# Check that there is no open file which will create problems later on 
# ----------------------------------------------------------------------
if (&("./CheckDashboard.ps1")){
    exit
}

# Import module with some standardized function
import-module -Force -Name ./SpotImportsLib

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

# If BaseCurrency has been populated then we keep it
if ($BaseCurrency.length -eq 0) {
    $BaseCurrency = $SourceDef.BaseCurrency
}

# $BaseCurrency

# -------------------------------------------------
# Based on the Format -> Setup script to be called
# And Ad-hoc module to be loaded
# $FormatDef = &"./Format/FISSetup.ps1"
# As a result SourceDeb has all the method and Data associated
# -------------------------------------------------
$FormatSetup = "./Format/"+$Format+"Setup.ps1"
$FormatDef   = &($FormatSetup)

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

# Do not Delete !!!! 
# weird cleanup as in some cases records with empty date appear
$StandardData = $StandardData | Where-Object {$_.Date -ne $null}

# $StandardData

# We need know to filter the data based on the list of dates available
if ($ListDates -ne $null) {
    "Filtering List of Dates"
    $StandardData = $StandardData | ? {$_.Date -in  $ListDates.DateasDate}
}

# # Debug
# Write-Output "In the main module"
# $StandardData

# Prepare the Output of the CSV File => Based on the Format 
# $OutputCSV  = 'Market entity type,Market entity code,Variant,Date,Value' + "`n"
$OutputCSV  = $FormatDef.Header($FISType,$CSVSep)

# Write-Output "List Curr",$ListCurrencies,"End List"

# -----------------------------------------------------------
# if BaseCurrency required = SourceDef.BaseCurrency 
# If that is not the case then pivot calculation is required
# -----------------------------------------------------------
if ($BaseCurrency -ne $SourceDef.BaseCurrency) {
    # Extract the exchange value for the $BaseCurrency
    $BaseFXRates = $StandardData | Where-Object {($_.CCY2 -eq $BaseCurrency)}

    # Debug
    # "Ad-Hoc $BaseCurrency Exchange Rate"
    # $BaseFXRates
}

# $StandardData.length

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

	if ($BaseCurrency -eq $SourceDef.BaseCurrency) {
	    # Output the line as provided - Default 
	    $OutputCSV  += $FormatDef.Line($FISType,$CSVSep,$_.CCY1,$_.CCY2,$_.Date,$_.Value,$FISVariant)
	}
	else {
	    $RefDate = $_.Date
	    # Triangulation is required - Select Exchange Rate
	    $BaseCurrencyRate = ($BaseFXRates | Where-Object {($_.Date -eq $RefDate)}).Value

	    # Output the line. Check that Base Currency has not been added in the list
	    if ($BaseCurrency -ne $_.CCY2) {
		$OutputCSV  += $FormatDef.Line($FISType,$CSVSep,$BaseCurrency,$_.CCY2,$_.Date,$_.Value/$BaseCurrencyRate,$FISVariant)
	    } else {
		# We create the record $BaseCurrency = CCY1 / $SourceDef.BaseCurrency = CC2
		$OutputCSV  += $FormatDef.Line($FISType,$CSVSep,$BaseCurrency,$SourceDef.BaseCurrency,$_.Date,1/$BaseCurrencyRate,$FISVariant)
	    }
	}
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
    # https://riptutorial.com/powershell/example/20867/erroraction-parameter
    # No error message if the file does NOT exist // If blocked sorted before 
    rm FXrate.xlsx -Force -ErrorAction SilentlyContinue

    # ---------------------------------------------------------------------------------------
    # Splatting to be used in order to pass a parameter which is actually a variable
    # https://stackoverflow.com/questions/58507217/how-to-pass-a-switch-parameter-as-a-variable-via-splatting-in-powershell
    # Using the : syntax as explained in the link above 
    # Use for flag Show in the Export-Excel ... Could be used for the WorksheetName too 
    # ---------------------------------------------------------------------------------------

    # Import-Csv -Path .\FXrate.csv -Delimiter $CSVSep | Export-Excel -Show -AutoSize -AutoFilter FXrate.xlsx -WorksheetName "Market data"
    Import-Csv -Path .\FXrate.csv -Delimiter $CSVSep | Export-Excel -Show:$ShowOption -AutoSize -AutoFilter FXrate.xlsx -WorksheetName "Market data"

    # Copy the generated xlsx file
    cp ./FXrate.xlsx ($Exec_Dir+"/Data/FXrate"+$BatchID+".xlsx")
}

# Processing if required 
if ($Processing -ne "NoAction") {
    # -------------------------------------------------
    # Based on the Processing -> Setup script to be called
    # The Ad-hoc Process function is made available
    # -------------------------------------------------
    $ProcessingSetup = "./Processing/"+$Processing+"Processing.ps1"
    $ProcessingDef   = &($ProcessingSetup)

    # Process as expected
    $ProcessingDef.Process()
}

# Remove the ad-hoc module which has been created
Remove-Module ($Source+"Lib")

# That way the module is only used as part of the script and no afterwards
Remove-Module SpotImportsLib

# Print a white line to improve output
" "
