# ------------------------------------------------------------------------------
#                     Author    : FIS - JPD
#                     Time-stamp: "2021-03-31 07:51:22 jpdur"
# ------------------------------------------------------------------------------

# ----------------------------------------------------------------------
# The SpotImportsLib module is assumed to have been imported when called
# if not the creation of the Format object via FormatDef would fail
# ----------------------------------------------------------------------

# Create the object that will be returned afterwards
$FormatDef = FormatDef -Name "FIS"

# -------------------------------------------------------------------------
# By default we generate only for FX Pairs so a parameter is always needed
# As the header/contents may differ between FXPair and FXRate
# -------------------------------------------------------------------------

# By default the Header should be similar to the string below
# $OutputCSV  = 'Market entity type,Market entity code,Variant,Date,Value' + "`n"

# Create the Header for the CSV File 
$HeaderFct = {
    
    param([Parameter(Mandatory=$true)] [string]$FISType,
          [Parameter(Mandatory=$true)] [string]$CSVSep
	 )
    
    # return the result of the request
    if ($FISType -eq "FX Pair") {
	return 'Market entity type'+$CSVSep+'Market entity code'+$CSVSep+'Variant'+$CSVSep+'Date'+$CSVSep+'Value' + "`n"
    } else {
	# for FXRate - header is different
	return 'FX Rate ISO Code'+$CSVSep+'Date'+$CSVSep+'Variant'+$CSVSep+'Value'+$CSVSep+'Market Entity Type'+$CSVSep+'Market Entity Code' + "`n"
    }
    
}

# Add the method to the object
$FormatDef | Add-Member -MemberType ScriptMethod -Name "Header" -Value $HeaderFct

# By default we generate only for FX Pairs so an extra parameter is required 
# $OutputCSV += "FX Pair"+$CSVSep+$CCY+"/SGD"+$CSVSep+"Closing"+$CSVSep+$FXDateasDate.ToString($DateFormat)+$CSVSep+$Rate+ "`r`n"

# Create the Line for the CSV File 
$LineFct = {

    param([Parameter(Mandatory=$true)] [string]$FISType,
          [Parameter(Mandatory=$true)] [string]$CSVSep,
          [Parameter(Mandatory=$true)] [string]$BaseCurrency,
          [Parameter(Mandatory=$true)] [string]$CCY,
          [Parameter(Mandatory=$true)] [datetime]$FXDateasDate,
          [Parameter(Mandatory=$true)] [string]$Rate,
          [Parameter(Mandatory=$true)] [string]$FISVariant
	 )

    # return the line for the Output - Check the hard coded date format
    # By using this convention should work too with the US Setup --> Careful
    if ($FISType -eq "FX Pair") {
	return $FISType+$CSVSep+$BaseCurrency+"/"+$CCY+$CSVSep+$FISVariant+$CSVSep+$FXDateasDate.ToString("yyyy-MM-dd")+$CSVSep+$Rate+ "`r`n"
    } else {
	# for FXRate - Line structure is different
	return $CCY+$CSVSep+$FXDateasDate.ToString("yyyy-MM-dd")+$CSVSep+$FISVariant+$CSVSep+$Rate+$CSVSep+$FISType+$CSVSep+$CCY+ "`n"
    }

}

# Add the method to the object
$FormatDef | Add-Member -MemberType ScriptMethod -Name "Line" -Value $LineFct


# # As if it were a normal function. No extra precaution
# $S2 = {param([Parameter(Mandatory=$false)] [string] $ParamStr)
#        if ($ParamStr -eq $null) {$str = $this.Name} else {$str = $ParamStr}
#        Write-Host "Length is "+ ($str).Length }

# $FormatDef | Add-Member -MemberType ScriptMethod -Name "TestParam" -Value $S2
# $FormatDef.TestParam()

# return the object created with the associated functions and Data
return $FormatDef

