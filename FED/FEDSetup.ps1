# ------------------------------------------------------------------------------
#                     Author    : FIS - JPD
#                     Time-stamp: "2021-03-30 11:36:49 jpdur"
# ------------------------------------------------------------------------------

# ----------------------------------------------------------------------
# The SpotImportsLib module is assumed to have been imported when called
# if not the creation of the Source object via SourceDef would fail
# ----------------------------------------------------------------------

# -------------------------------------------------------------------------------
# The Script executable for each source does the source specific function 
# i.e. receives the extract parameters 
# and generates the output
# For each Date
# The Exchange Rates for pair of currencies using always the same convention
# similar to ECB. Currencies are called CCY1 CCY2 
# and the value associates is to be imterpreted as 
# 1 CCY1 = Value CCY2 @Date 
# EUR USD 1.1 ==> 1EUR = 1.1 USD
# EUR GBP 0.8 ==> 1EUR = 0.8 GBP
# in a standard format 
# -------------------------------------------------------------------------------

# -------------------------------------------------------------- 
# To ease the writing of the function and debug 
# we use a local module which is the key main functions
# it is uploaded as part of the main script
# -------------------------------------------------------------- 
# import-module -Force -Name ./FED/FEDLib

# Create the object that will be returned afterwards
$SourceDef = SourceDef -Name "FED" -BaseCurrency "USD"

# Create the ExtractData method/function based on the received parameters
# i.e. StartDateasDate and EndDateasDate 
$ExtractDataFct = {
    param([Parameter(Mandatory=$false)] [datetime]$StartDateasDate,
          [Parameter(Mandatory=$false)] [datetime]$EndDateasDate)

    # Goes through all historical data and extract only the records between StartDate and EndDate
    # and returns the data with standard formatting 
    $StandardData = extractDatainInterval -StartDate ($StartDateasDate.ToString("yyyy-MM-dd")) -EndDate ($EndDateasDate.ToString("yyyy-MM-dd"))

    # Key to return the data to caller
    $StandardData
}

# Add the method to the object
$SourceDef | Add-Member -MemberType ScriptMethod -Name "ExtractData" -Value $ExtractDataFct

# # As if it were a normal function. No extra precaution
# $S2 = {param([Parameter(Mandatory=$false)] [string] $ParamStr)
#        if ($ParamStr -eq $null) {$str = $this.Name} else {$str = $ParamStr}
#        Write-Host "Length is "+ ($str).Length }

# $SourceDef | Add-Member -MemberType ScriptMethod -Name "TestParam" -Value $S2
# $SourceDef.TestParam()

# return the object created with the associated functions and Data
return $SourceDef

