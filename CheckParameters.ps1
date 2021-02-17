# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-17 11:52:33 jpdur"
# ------------------------------------------------------------------------------

# Convert String Date to Date
if ($StartDate.length -eq 0) {$StartDateasDate = $null} else { $StartDateasDate = [datetime]::ParseExact($StartDate,"yyyy-MM-dd", $null) }
if ($EndDate.length -eq 0)   {$EndDateasDate   = $null} else { $EndDateasDate   = [datetime]::ParseExact($EndDate  ,"yyyy-MM-dd", $null) }

# ---------------------------------------------------------
# If no EndDate then EndDate is today 
# If no StartDate then EndDate -1 
# ---------------------------------------------------------
if ($EndDateasDate -eq $null) {
        $EndDateasDate = Get-Date
}

if ($StartDateasDate -eq $null) {
    $StartDateasDate = $EndDateasDate.AddDays(-1)
}

# Uniquify the generated file(s)
$BatchID = (New-GUID).Guid

# -------------------------------------------------------------------
# https://www.sqlshack.com/powershell-split-a-string-into-an-array/
# Convert the , separated list of currencies into an Array 
# -------------------------------------------------------------------

# Manage the list of currencies to validate the contents and setup a default
if ($ListCurrenciesStr.length -ne 0) {

    Write-Output "Processing",$ListCurrenciesStr
    Write-Output "Processing",$GlobalListCurrencies

    # Check that all currencies are actual currency from the global list of Currencies
    $ListCurrenciesPossible = $ListCurrenciesStr.Split(",")

    # Filter Out the Currencies not Recognised
    # https://stackoverflow.com/questions/25084484/how-to-search-array-of-objects-contains-an-item-in-another-array
    $ListNonExistingCCY = $ListCurrenciesPossible | ? {$_ -notin $GlobalLisCurrencies.ccy} 
    $ListCurrencies     = $ListCurrenciesPossible | ? {$_ -in    $GlobalLisCurrencies.ccy}

    # -------------------------------------------------------------------------
    # NB: If none of the currencies of the list have been validated
    # then ListCurrencies is empty and all available currencies will be inserted
    # in the result file(s)
    # -------------------------------------------------------------------------

}

# Class to manipulate ListDates
class DateStruct {
    [string]$Date
    [datetime]$DateasDate
}

# Manage the list of dates if any has been provided 
if ($ListDatesStr.length -ne 0) {
    
    # Process the List of Dates if it exists
    $ListDates = @()

    # ------------------------------------------------------------------------------- 
    # Convert the , separated string into an array
    # if the date is not a recognized one - error is displayed and the incorrect date
    # is filtered out automatically... the error message below is displayed
    # ------------------------------------------------------------------------------- 
    # Exception calling "ParseExact" with "3" argument(s): "The DateTime represented 
    # by the string is not supported in calendar System.Globalization.GregorianCalendar."
    # ------------------------------------------------------------------------------- 
    $ListDatesStr.Split(",") | ForEach {
	$ListDates += New-Object DateStruct -Property @{ Date=$_ ; DateasDate = [datetime]::ParseExact($_,"yyyy-MM-dd", $null) }
    }

    # Filtered out any duplicate dates
    $ListDates = $ListDates | Sort-Object -Property Date -Unique

    # Modify StartDate and EndDate accordingly
    if ($ListDates.length -ne 0) {
	
	# Extract Max and min 
	$MinDate = $ListDates | Select-Object -first 1
	$MaxDate = $ListDates | Select-Object -last 1

	# Adjust accordingly StartDate and EndDate in order to extract the needed data
	$StartDate = $MinDate.Date ; $StartDateasDate = $MinDate.DateasDate
	$EndDate   = $MaxDate.Date ; $EndDateasDate   = $MaxDate.DateasDate
    }
    else {
	$ListDates = $null
    }

}


# Debug
# if ($ListCurrencies -eq $null) {Write-Host "No currency List"}

# Package all the parameters in order to add them to the dashboard
$ParametersList = [pscustomobject]@{
    BatchID = $BatchID
    Link = ""
# All repackaged parameters in the order of the displayed fields    
    StartDate = $StartDate
    EndDate = $EndDate
    Source = $Source
    ListCurrencies = $ListCurrenciesStr
    ListDates = $ListDatesStr
    Format = $Format
    BaseCurrency = $BaseCurrency
    FISType = $FISType
    FISVariant = $FISVariant
    Output = $Output
    CSVSep = $CSVSep
    Processing = $Processing
    Show = $Show
}

# --------------------------------------------------------
# Add all the Parameters of this run to the Dashboards
# --------------------------------------------------------
# Read the list of previous runs
$data = Import-Excel -Path ("./Dashboard.xlsx") 

# Add the new run at the top of the list 
$ParametersArray = @()
$ParametersArray += $ParametersList
$ParametersArray += $data

# Push all runs to the list
$ParametersArray | Export-Excel -AutoSize -AutoFilter Dashboard.xlsx -WorksheetName "Dashboard"




