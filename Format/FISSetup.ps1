# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-14 08:21:51 jpdur"
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
    return 'Market entity type'+$CSVSep+'Market entity code'+$CSVSep+'Variant'+$CSVSep+'Date'+$CSVSep+'Value' + "`n"

}

# Add the method to the object
$FormatDef | Add-Member -MemberType ScriptMethod -Name "Header" -Value $HeaderFct

# By default we generate only for FX Pairs so an extra parameter is required 
# $OutputCSV += "FX Pair"+$CSVSep+$CCY+"/SGD"+$CSVSep+"Closing"+$CSVSep+$FXDateasDate.ToString($DateFormat)+$CSVSep+$Rate+ "`r`n"

# Create the Line for the CSV File 
$LineFct = {

    param([Parameter(Mandatory=$true)] [string]$FISType,
          [Parameter(Mandatory=$true)] [string]$CSVSep,
          [Parameter(Mandatory=$true)] [string]$CCY,
          [Parameter(Mandatory=$true)] [string]$BaseCurrency,
          [Parameter(Mandatory=$true)] [datetime]$FXDateasDate,
          [Parameter(Mandatory=$true)] [string]$Rate,
          [Parameter(Mandatory=$true)] [string]$FISVariant
	 )

    # return the line for the Output - Check the hard coded date format
    # By using this convention should work too with the US Setup --> Careful
    return $FISType+$CSVSep+$CCY+"/"+$BaseCurrency+$CSVSep+$FISVariant+$CSVSep+$FXDateasDate.ToString("yyyy-MM-dd")+$CSVSep+$Rate+ "`r`n"

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

