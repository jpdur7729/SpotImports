# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-03-30 11:07:04 jpdur"
# ------------------------------------------------------------------------------

function extractDatainInterval {
    param(
	[Parameter(Mandatory=$false)] [string]$StartDate,
	[Parameter(Mandatory=$false)] [string]$EndDate
    )

    # Convert parameters as date
    $StartDateasDate = [datetime]::ParseExact($StartDate,"yyyy-MM-dd", $null) 
    $EndDateasDate   = [datetime]::ParseExact($EndDate  ,"yyyy-MM-dd", $null)

    # Format the dates in US format
    $USFromDate = $StartDateasDate.ToString("MM/dd/yyyy")
    $USToDate   = $EndDateasDate.ToString("MM/dd/yyyy")

    # Extract the .zip files with the history of FX Rates from ECB
    # Force the output to be eurofxref-hist.zip thus overwriting any previous extraction
    # $extractcmd = "wget --no-check-certificate https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip -O eurofxref-hist.zip"
    $extractcmd  = "curl ""https://www.federalreserve.gov/datadownload/Output.aspx?rel=H10&series=60f32914ab61dfab590e0e470153e3ae&lastobs=25&from="+$USFromDate 
    $extractcmd += "&to="+$USToDate
    $extractcmd += "&filetype=csv&label=include&layout=seriescolumn"" -o FedRate.csv"

    # ---------------------------------------------------------------------------------------------
    # Store the command in a .bat file (Encoding ASCII guarantees that there is no odd character
    # Execute the command
    # Delete the intermediate file
    # ---------------------------------------------------------------------------------------------
    $extractcmd | Out-File -Encoding ASCII "./goextract.bat"
    ./goextract.bat
    rm goextract.bat

    # Read the lines of the csv spreadsheets
    $RawList =  Import-Csv -Path .\FedRate.csv

    $extractcmd  = "curl ""https://www.federalreserve.gov/datadownload/Output.aspx?rel=H10&series=60f32914ab61dfab590e0e470153e3ae&lastobs=25&from="+$USFromDate 
    $extractcmd += "&to="+$USToDate
    $extractcmd += "&filetype=csv&label=include&layout=seriesrow"" -o FedRateRow.csv"

    $extractcmd | Out-File -Encoding ASCII "./goextract.bat"
    ./goextract.bat
    rm goextract.bat

    # Read the lines of the csv spreadsheets 1 row = 1 currency
    # Easier to process organise the data per currencies
    $RawListRow =  Import-Csv -Path .\FedRateRow.csv
    
    # # Data is structure as indicated below
    # | Series Description  |  SPOT EXCHANGE RATE - EURO AREA |  SPOT EXCHANGE RATE - BRAZIL      |UNITED KINGDOM -- SPOT EXCHANGE RATE, US$/POUND (1/RXI_N.B.UK) |
    # | Unit:		    |	       Currency:_Per_EUR     |		      Currency:_Per_USD |					      Currency:_Per_GBP |
    # | Multiplier:	    |			       1     |				      1 |							      1 |
    # | Currency:	    |			     USD     |				    BRL |							    USD |
    # | Unique Identifier:  |	   H10/H10/RXI$US_N.B.EU     |		     H10/H10/RXI_N.B.BZ |					  H10/H10/RXI$US_N.B.UK |
    # | Time Period	    |		   RXI$US_N.B.EU     |			     RXI_N.B.BZ |						  RXI$US_N.B.UK |
    # | 19/02/2021 00:00:00 |			  1.2136     |				 5.3938 |							 1.4025 |
    # | 22/02/2021 00:00:00 |			  1.2155     |				 5.4781 |							 1.4077 |
    # | 23/02/2021 00:00:00 |			  1.2142     |				 5.4267 |							 1.4092 |
    # | 24/02/2021 00:00:00 |			  1.2143     |				 5.4249 |							 1.4106 |
    # | 25/02/2021 00:00:00 |			  1.2229     |				 5.4903 |							 1.4105 |

    # Prepare the data per currency 
    $Presentation = $RawListRow |  Select-Object Currency:,Unit:,Multiplier:,Descriptions: | Select-Object @{Label='CCY';Expression={If ($_."Currency:" -ne "USD") {$_."Currency:"} Else {$_."Unit:".substring($_."Unit:".length -3,3)}}},* 
    # $Presentation | Format-Table

    # Extract the list of all currencies
    # $AllCurrencies = $Presentation.CCY

    # Define all the headers that can be found
    $AllHeaders = $Presentation."Descriptions:"

    # Read the lines of the csv spreadsheets - 1 line = 1 date // ccy as the headers
    $RawList =  Import-Csv -Path .\FedRate.csv

    # Extract the list of Date for which the currencies will be handled  
    $ListData = $RawList | Where-Object { ($_."Series Description" -ge  $StartDate) -and ($_."Series Description" -le $EndDate) }

    # Prepare the standard format of Data
    $StandardData=@()

    # Process the list to get the standard format 
    $ListData | ForEach-Object {
	# For each line 
	$FxDateasDate = [datetime]::ParseExact($_."Series Description","yyyy-MM-dd", $null)

	# We extract all the Currencies provided by FED
	ForEach ($Header in $AllHeaders ) {

	    # Extract the currency Info for each of the specific headre
	    $CCYInfo = $Presentation | Where-Object {($_."Descriptions:" -eq  $Header)}
	    
	    # Mixed quotation certain and uncertain
	    if ($CCYInfo."Currency:" -eq "USD"){$Value = 1/$_.$Header} else {$Value = $_.$Header}
	    
	    # Create the structure of the object to be added 
	    $ObjectStructure = @{
		Date  = $FxDateasDate
		CCY1  = "USD"
		CCY2  = $CCYInfo.CCY
		Value = $Value
	    }

	    # Add the new record to the list - Inspired from method 4
	    # https://ridicurious.com/2018/10/15/4-ways-to-create-powershell-objects/
	    $StandardData += New-Object psobject -Property $ObjectStructure
	}
    }

    # Key to return the data to caller
    $StandardData 
    
}

# # ------------------------------------------------
# # Standard Output for the data extracted from ECB 
# # ------------------------------------------------
# function formatRawData {

#     param(
# 	[Parameter(Mandatory=$true)] [string]$request
#     )

#     #Extract the data from MAS and process the JSON accordingly 
#     $data = Invoke-WebRequest $request | Select -ExpandProperty Content | ConvertFrom-Json | Select -ExpandProperty result   

#     # Create Empty array to store the normalized data
#     $StandardData=@()

#     # Processing the data in order to get the standard data type
#     $data.records | ForEach-Object {

# 	# Read the date for the record to be processed
# 	$FxDateasDate = [datetime]::ParseExact($_.end_of_day,"yyyy-MM-dd", $null)

# 	# Loop through all the properties of the object
# 	$_.PSObject.Properties | ForEach-Object {
# 	    # Eliminate the 3 fields we are not interested in
# 	    if (($_.Name -ne "timestamp") -and ($_.Name -ne "end_of_day") -and ($_.Name -ne "preliminary")) {

# 		# Extract the key information from Name
# 		$CCY = $_.Name.substring(0,3).ToUpper()
# 		if ($_.Name.length -ge 8) { $Mult = $_.Name.substring(8) } else { $Mult = 1 }

# 		# Create the structure of the object to be added 
# 		$ObjectStructure = @{
# 		    Date  = $FxDateasDate
# 		    CCY1  = "SGD"
# 		    CCY2  = $CCY
# 		    Value = $Mult / $_.Value
# 		}

# 		# Add the new record to the list - Inspired from method 4
# 		# https://ridicurious.com/2018/10/15/4-ways-to-create-powershell-objects/
# 		$StandardData += New-Object psobject -Property $ObjectStructure

# 	    } # Properties to be processed
# 	} # Loop all properties
#     } # End each record 

#     # Key to return the data to caller
#     $StandardData

# }
