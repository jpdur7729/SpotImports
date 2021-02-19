# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-19 07:25:24 jpdur"
# ------------------------------------------------------------------------------

function extractDatainInterval {
    param(
	[Parameter(Mandatory=$false)] [string]$StartDate,
	[Parameter(Mandatory=$false)] [string]$EndDate
    )

    $StartDateasDate = [datetime]::ParseExact($StartDate,"yyyy-MM-dd", $null) 
    $EndDateasDate   = [datetime]::ParseExact($EndDate  ,"yyyy-MM-dd", $null) 

    # Extract the .zip files with the history of FX Rates from ECB
    # Force the output to be eurofxref-hist.zip thus overwriting any previous extraction
    $extractcmd = "wget --no-check-certificate https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.zip -O eurofxref-hist.zip"

    # ---------------------------------------------------------------------------------------------
    # Store the command in a .bat file (Encoding ASCII guarantees that there is no odd character
    # Execute the command
    # Delete the intermediate file
    # ---------------------------------------------------------------------------------------------
    $extractcmd | Out-File -Encoding ASCII "./goextract.bat"
    & "./goextract.bat"
    rm goextract.bat
    
    # Add the 7Zip command line to extract the csv file
    $cmd = """C:\Program Files\7-Zip\7z"" e eurofxref-hist.zip -aoa"
    $cmd | Out-File -Encoding ASCII "./gounzip.bat"
    & "./gounzip.bat"
    rm gounzip.bat

    # Read the lines of the csv spreadsheets
    $RawList =  Import-Csv -Path .\eurofxref-hist.csv

    # Data is structure as indicated below
    # |       Date |    USD |    JPY |    BGN |
    # |------------+--------+--------+--------|
    # | 2021-01-13 | 1.2166 | 126.44 | 1.9558 |
    # | 2021-01-12 | 1.2161 | 126.74 | 1.9558 |
    # | 2021-01-11 | 1.2163 | 126.76 | 1.9558 |

    # Step 1 filter for only the dates in the right interval 
    $ListData = $RawList | ? {$_.Date -ge  $StartDate} | ? {$_Date -le $EndDate}

    Write-Host $ListData
    exit

    # Key to return the data to caller
    $request
    
}

# ------------------------------------------------
# Standard Output for the data extracted from ECB 
# ------------------------------------------------
function formatRawData {
    
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
