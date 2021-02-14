# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-14 08:24:46 jpdur"
# ------------------------------------------------------------------------------

function BuildRequest {
    Write-Host "Build Request"
}

function createRequest {
    param(
	[Parameter(Mandatory=$false)] [string]$StartDate,
	[Parameter(Mandatory=$false)] [string]$EndDate
    )

    $StartDateasDate = [datetime]::ParseExact($StartDate,"yyyy-MM-dd", $null) 
    $EndDateasDate   = [datetime]::ParseExact($EndDate  ,"yyyy-MM-dd", $null) 

    # ------------------------------------------------------------------------------
    # Example of full request between 2 dates
    # $request = 'https://eservices.mas.gov.sg/api/action/datastore/search.json?resource_id=95932927-c8bc-4e7a-b484-68a66a24edfe&limit=10&between%5Bend_of_day%5D=2021-01-12,2021-01-15=end_of_day+asc'
    # ------------------------------------------------------------------------------
    $root_request = "https://eservices.mas.gov.sg/api/action/datastore/search.json?resource_id=95932927-c8bc-4e7a-b484-68a66a24edfe&limit=10&between%5Bend_of_day%5D="
    $end_request = "=end_of_day+asc"

    # Create the request accordingly
    if (($StartDate.length -eq 0) -and ($EndDate.length -eq 0)) {
	# We create a request only for the date of today and yesterday. Due to the TZ difference with Europe 
	# an easy way to catch up the differences
	$request = $root_request + $Yesterday.ToString("yyyy-MM-dd") + "," + $Today.ToString("yyyy-MM-dd") + $end_request
	$nbdays = 2
    }
    # StartDate only defined up to today
    else {if (($StartDate.length -ne 0) -and ($EndDate.length -eq 0)) {
	      $request = $root_request + $StartDateasDate.ToString("yyyy-MM-dd") + "," + $Today.ToString("yyyy-MM-dd") + $end_request
	      $nbdays = (New-TimeSpan -start $StartDateasDate -end $Today).Days + 1
	  }
	  # StartDate and EndDate defined
	  else {if (($StartDate.length -ne 0) -and ($EndDate.length -ne 0)) {
		    $request = $root_request + $StartDateasDate.ToString("yyyy-MM-dd") + "," + $EndDateasDate.ToString("yyyy-MM-dd") + $end_request 
		    $nbdays = (New-TimeSpan -start $StartDateasDate -end $EndDateasDate ).Days + 1
		}}}

    # Adjust the limit if we are requesting more than 10 days
    if ($nbdays -gt 10) {
	# Debug 
	# Write-Output ("Adjust Limit to "+$nbdays)

	# substitution string to adjust the limit accordingly  
	# JPD - There are easiest ways but wanted to do some regexp substitution 
	$newlimit = "`$1"+"limit="+$nbDays+"`$2"
	$request = $request -replace ('^(.*?)limit=10(.*?)$',($newlimit))
    }

    # Key to return the data to caller
    $request
    
}

function extractRawData {
    
    param(
	[Parameter(Mandatory=$true)] [string]$request
    )
    
    #Extract the data from MAS and process the JSON accordingly 
    $data = Invoke-WebRequest $request | Select -ExpandProperty Content | ConvertFrom-Json | Select -ExpandProperty result   

    # Create Empty array to store the normalized data
    $StandardData=@()
    
    # Processing the data in order to get the standard data type
    $data.records | ForEach-Object {
	
	# Read the date for the record to be processed
	$FxDateasDate = [datetime]::ParseExact($_.end_of_day,"yyyy-MM-dd", $null)

	# Loop through all the properties of the object
	$_.PSObject.Properties | ForEach-Object {
	    # Eliminate the 3 fields we are not interested in
	    if (($_.Name -ne "timestamp") -and ($_.Name -ne "end_of_day") -and ($_.Name -ne "preliminary")) {

		# Extract the key information from Name
		$CCY = $_.Name.substring(0,3).ToUpper()
		if ($_.Name.length -ge 8) { $Mult = $_.Name.substring(8) } else { $Mult = 1 }

		# Create the structure of the object to be added 
		$ObjectStructure = @{
		    Date  = $FxDateasDate
		    CCY1  = "SGD"
		    CCY2  = $CCY
		    Value = $Mult / $_.Value
		}

		# Add the new record to the list - Inspired from method 4
		# https://ridicurious.com/2018/10/15/4-ways-to-create-powershell-objects/
		$StandardData += New-Object psobject -Property $ObjectStructure
		
	    } # Properties to be processed
	} # Loop all properties
    } # End each record 

    # Key to return the data to caller
    $StandardData
    
}
