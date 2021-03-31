# ------------------------------------------------------------------------------
#                     Author    : FIS - JPD
#                     Time-stamp: "2021-03-31 17:13:43 jpdur"
# ------------------------------------------------------------------------------

function extractDatainInterval {
    param(
	[Parameter(Mandatory=$false)] [string]$StartDate,
	[Parameter(Mandatory=$false)] [string]$EndDate
    )

    # List of all infos related to the currencies 
    $CCYInfoSeries = @(
	[pscustomobject]@{Currency='Australian Dollar';CCY='AUD';Key='XUDLADS';Prefix='XUDL';Suffix='ADS'}
	[pscustomobject]@{Currency='Canadian Dollar';CCY='CAD';Key='XUDLCDS';Prefix='XUDL';Suffix='CDS'}
	[pscustomobject]@{Currency='Chinese Yuan';CCY='CNY';Key='XUDLBK89';Prefix='XUDL';Suffix='BK89'}
	[pscustomobject]@{Currency='Czech Koruna';CCY='CZK';Key='XUDLBK25';Prefix='XUDL';Suffix='BK25'}
	[pscustomobject]@{Currency='Danish Krone';CCY='DKK';Key='XUDLDKS';Prefix='XUDL';Suffix='DKS'}
	[pscustomobject]@{Currency='Euro';CCY='EUR';Key='XUDLERS';Prefix='XUDL';Suffix='ERS'}
	[pscustomobject]@{Currency='Hong Kong Dollar';CCY='HKD';Key='XUDLHDS';Prefix='XUDL';Suffix='HDS'}
	[pscustomobject]@{Currency='Japanese Yen';CCY='JPY';Key='XUDLJYS';Prefix='XUDL';Suffix='JYS'}
	[pscustomobject]@{Currency='Hungarian Forint';CCY='HUF';Key='XUDLBK33';Prefix='XUDL';Suffix='BK33'}
	[pscustomobject]@{Currency='Indian Rupee';CCY='INR';Key='XUDLBK97';Prefix='XUDL';Suffix='BK97'}
	[pscustomobject]@{Currency='Israeli Shekel';CCY='ILS';Key='XUDLBK78';Prefix='XUDL';Suffix='BK78'}
	[pscustomobject]@{Currency='Malaysian Ringgit';CCY='MYR';Key='XUDLBK83';Prefix='XUDL';Suffix='BK83'}
	[pscustomobject]@{Currency='New Zealand Dollar';CCY='NZD';Key='XUDLNDS';Prefix='XUDL';Suffix='NDS'}
	[pscustomobject]@{Currency='Norwegian Krone';CCY='NOK';Key='XUDLNKS';Prefix='XUDL';Suffix='NKS'}
	[pscustomobject]@{Currency='Polish Zloty';CCY='PLN';Key='XUDLBK47';Prefix='XUDL';Suffix='BK47'}
	[pscustomobject]@{Currency='Russian Ruble';CCY='RUB';Key='XUDLBK85';Prefix='XUDL';Suffix='BK85'}
	[pscustomobject]@{Currency='Saudi Riyal';CCY='SAR';Key='XUDLSRS';Prefix='XUDL';Suffix='SRS'}
	[pscustomobject]@{Currency='Singapore Dollar';CCY='SGD';Key='XUDLSGS';Prefix='XUDL';Suffix='SGS'}
	[pscustomobject]@{Currency='Swedish Krona';CCY='SEK';Key='XUDLSKS';Prefix='XUDL';Suffix='SKS'}
	[pscustomobject]@{Currency='Swiss Franc';CCY='CHF';Key='XUDLSFS';Prefix='XUDL';Suffix='SFS'}
	[pscustomobject]@{Currency='South African Rand';CCY='ZAR';Key='XUDLZRS';Prefix='XUDL';Suffix='ZRS'}
	[pscustomobject]@{Currency='South Korean Won';CCY='KRW';Key='XUDLBK93';Prefix='XUDL';Suffix='BK93'}
	[pscustomobject]@{Currency='Taiwan Dollar';CCY='TWD';Key='XUDLTWS';Prefix='XUDL';Suffix='TWS'}
	[pscustomobject]@{Currency='Thai Baht';CCY='THB';Key='XUDLBK87';Prefix='XUDL';Suffix='BK87'}
	[pscustomobject]@{Currency='Turkish Lira';CCY='TRL';Key='XUDLBK95';Prefix='XUDL';Suffix='BK95'}
	[pscustomobject]@{Currency='US Dollar';CCY='USD';Key='XUDLUSS';Prefix='XUDL';Suffix='USS'}
    )

    # Convert parameters as date
    $StartDateasDate = [datetime]::ParseExact($StartDate,"yyyy-MM-dd", $null) 
    $EndDateasDate   = [datetime]::ParseExact($EndDate  ,"yyyy-MM-dd", $null)

    # Format the dates in US format
    $FromDate = $StartDateasDate.ToString("dd/MMM/yyyy")
    $ToDate   = $EndDateasDate.ToString("dd/MMM/yyyy")

    # Create the , separated list of all currencies available
    $ListSeries = $CCYInfoSeries.Key -join ','

    # Create the URL with all the various parameters to get the extract for 
    # all possible currencies 
    $URL  = "http://www.bankofengland.co.uk/boeapps/iadb/fromshowcolumns.asp?csv.x=yes&Datefrom="
    $URL += $FromDate+"&Dateto="
    $URL += $ToDate+"&SeriesCodes="
    $URL += $ListSeries+"&CSVF=TN&UsingCodes=Y&VPD=Y&VFD=N"

    # Create the extract
    $extractcmd = "wget """ + $URL + """ -o LogFile.txt -O BoEResult.csv"
    # ---------------------------------------------------------------------------------------------
    # Store the command in a .bat file (Encoding ASCII guarantees that there is no odd character
    # Execute the command
    # Delete the intermediate file
    # ---------------------------------------------------------------------------------------------
    $extractcmd | Out-File -Encoding ASCII "./goextract.bat"
    & "./goextract.bat"
    rm goextract.bat

    # Read the lines of the csv spreadsheets
    $RawList =  Import-Csv -Path .\BoEResult.csv

    # DATE is in format xx Jan 2021 --> Create TrueDate in format yyyy-mm-dd
    $RawList = $RawList | Select-Object @{Label='TrueDate';Expression={([datetime]::ParseExact($_.DATE,"dd MMM yyyy", $null)).ToString("yyyy-MM-dd")}},* 

    # Extract the list of Date for which the currencies will be handled  
    $ListData = $RawList | Where-Object { ($_.TrueDate -ge  $StartDate) -and ($_.TrueDate -le $EndDate) }

    # Select the list of all Headers
    $AllHeaders = $CCYInfoSeries.Key
    $AllHeaders

    # Prepare the standard format of Data
    $StandardData=@()

    # Process the list to get the standard format 
    $ListData | ForEach-Object {
	
	# For each line 
	$FxDateasDate = [datetime]::ParseExact($_.TrueDate,"yyyy-MM-dd", $null)

	# We extract all the Currencies provided by FED
	ForEach ($Header in $AllHeaders ) {

	    # Extract the currency Info for each of the specific headre
	    $CCYInfo = $CCYInfoSeries | Where-Object {($_.Key -eq  $Header)}

	    # Create the structure of the object to be added 
	    $ObjectStructure = @{
		Date  = $FxDateasDate
		CCY1  = "GBP"
		CCY2  = $CCYInfo.CCY
		Value = $_.$Header
	    }

	    # Add the new record to the list - Inspired from method 4
	    # https://ridicurious.com/2018/10/15/4-ways-to-create-powershell-objects/
	    $StandardData += New-Object psobject -Property $ObjectStructure
	}
    }

    # Key to return the data to caller
    $StandardData 
    
}

