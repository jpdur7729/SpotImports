# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-21 18:23:25 jpdur"
# ------------------------------------------------------------------------------

# Signature function to test if the module is available 
function SpotImportFct {
    Write-Host "SpotImportLib Module is available"
}

# Inspired from https://mcpmag.com/articles/2018/07/10/check-for-locked-file-using-powershell.aspx?m=1
# Alternative https://stackoverflow.com/questions/24992681/powershell-check-if-a-file-is-locked
# --------------------------------------------------------
# Given an absolute path - checks that the file is locked 
# --------------------------------------------------------
function Test-FileLock {
    param (
	[parameter(Mandatory=$true)][string]$Path
    )

    $oFile = New-Object System.IO.FileInfo $Path

    # If it does not exist --> No FileLock
    if ((Test-Path -Path $Path) -eq $false) {
	return $false
    }

    # Test if it is possible to open
    try {
	$oStream = $oFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)

	if ($oStream) {
	    $oStream.Close()
	}
	return $false
    } catch {
	# file is locked by a process.
	return $true
    }
}

# ----------------------------------------------------------------------------
# https://devblogs.microsoft.com/powershell/new-object-psobject-property-hashtable/
# Creation of the Source object which is dynamically extended with the ad-hoc 
# methods/functions so that it can be called from the main script
# ----------------------------------------------------------------------------
function SourceDef {
    param(
        [Parameter(Mandatory=$true)] [String]$Name,
        [Parameter(Mandatory=$true)] [string]$BaseCurrency
    )

    # Object Creation
    $src = New-Object PSObject -Property @{
        Name = $Name 
        BaseCurrency = $BaseCurrency
    }

    # Key to actually return the object 
    $src
}

# ---------------------------------------------------------
# Create an object to handle the different type of Formats
# 2 methods to be added when instantiating the object 
# ---------------------------------------------------------
function FormatDef {
    param(
        [Parameter(Mandatory=$true)] [String]$Name
    )

    # Object Creation
    $obj = New-Object PSObject -Property @{
        Name = $Name 
    }

    # Key to actually return the object 
    $obj
}

# ---------------------------------------------------------
# Create an object to handle the different type of Processings
# 1 methods to be added when instantiating the object 
# ---------------------------------------------------------
function ProcessingDef {
    param(
        [Parameter(Mandatory=$true)] [String]$Name
    )

    # Object Creation
    $obj = New-Object PSObject -Property @{
        Name = $Name 
    }

    # Key to actually return the object 
    $obj
}

# -----------------------------------------------------------------------------------------
# Manipulation of the list of all Currencies to validate that any currency used is correct 
# -----------------------------------------------------------------------------------------

class Currency {
    [string]$ccy
    [string]$name;
}

# List of currencies obtained from
# https://gist.github.com/joseluisq/59adf057a8e77f625e44e8328767a2a5

$GlobalLisCurrencies = @(
[Currency]@{ccy="AED";name="United Arab Emirates Dirham"}
[Currency]@{ccy="AFN";name="Afghan Afghani"}
[Currency]@{ccy="ALL";name="Albanian Lek"}
[Currency]@{ccy="AMD";name="Armenian Dram"}
[Currency]@{ccy="ANG";name="Netherlands Antillean Guilder"}
[Currency]@{ccy="AOA";name="Angolan Kwanza"}
[Currency]@{ccy="ARS";name="Argentine Peso"}
[Currency]@{ccy="AUD";name="Australian Dollar"}
[Currency]@{ccy="AWG";name="Aruban Florin"}
[Currency]@{ccy="AZN";name="Azerbaijani Manat"}
[Currency]@{ccy="BAM";name="Bosnia-Herzegovina Convertible Mark"}
[Currency]@{ccy="BBD";name="Barbadian Dollar"}
[Currency]@{ccy="BDT";name="Bangladeshi Taka"}
[Currency]@{ccy="BGN";name="Bulgarian Lev"}
[Currency]@{ccy="BHD";name="Bahraini Dinar"}
[Currency]@{ccy="BIF";name="Burundian Franc"}
[Currency]@{ccy="BMD";name="Bermudan Dollar"}
[Currency]@{ccy="BND";name="Brunei Dollar"}
[Currency]@{ccy="BOB";name="Bolivian Boliviano"}
[Currency]@{ccy="BRL";name="Brazilian Real"}
[Currency]@{ccy="BSD";name="Bahamian Dollar"}
[Currency]@{ccy="BTC";name="Bitcoin"}
[Currency]@{ccy="BTN";name="Bhutanese Ngultrum"}
[Currency]@{ccy="BWP";name="Botswanan Pula"}
[Currency]@{ccy="BYN";name="Belarusian Ruble"}
[Currency]@{ccy="BZD";name="Belize Dollar"}
[Currency]@{ccy="CAD";name="Canadian Dollar"}
[Currency]@{ccy="CDF";name="Congolese Franc"}
[Currency]@{ccy="CHF";name="Swiss Franc"}
[Currency]@{ccy="CLF";name="Chilean Unit of Account (UF)"}
[Currency]@{ccy="CLP";name="Chilean Peso"}
[Currency]@{ccy="CNH";name="Chinese Yuan (Offshore)"}
[Currency]@{ccy="CNY";name="Chinese Yuan"}
[Currency]@{ccy="COP";name="Colombian Peso"}
[Currency]@{ccy="CRC";name="Costa Rican Colon"}
[Currency]@{ccy="CUC";name="Cuban Convertible Peso"}
[Currency]@{ccy="CUP";name="Cuban Peso"}
[Currency]@{ccy="CVE";name="Cape Verdean Escudo"}
[Currency]@{ccy="CZK";name="Czech Republic Koruna"}
[Currency]@{ccy="DJF";name="Djiboutian Franc"}
[Currency]@{ccy="DKK";name="Danish Krone"}
[Currency]@{ccy="DOP";name="Dominican Peso"}
[Currency]@{ccy="DZD";name="Algerian Dinar"}
[Currency]@{ccy="EGP";name="Egyptian Pound"}
[Currency]@{ccy="ERN";name="Eritrean Nakfa"}
[Currency]@{ccy="ETB";name="Ethiopian Birr"}
[Currency]@{ccy="EUR";name="Euro"}
[Currency]@{ccy="FJD";name="Fijian Dollar"}
[Currency]@{ccy="FKP";name="Falkland Islands Pound"}
[Currency]@{ccy="GBP";name="British Pound Sterling"}
[Currency]@{ccy="GEL";name="Georgian Lari"}
[Currency]@{ccy="GGP";name="Guernsey Pound"}
[Currency]@{ccy="GHS";name="Ghanaian Cedi"}
[Currency]@{ccy="GIP";name="Gibraltar Pound"}
[Currency]@{ccy="GMD";name="Gambian Dalasi"}
[Currency]@{ccy="GNF";name="Guinean Franc"}
[Currency]@{ccy="GTQ";name="Guatemalan Quetzal"}
[Currency]@{ccy="GYD";name="Guyanaese Dollar"}
[Currency]@{ccy="HKD";name="Hong Kong Dollar"}
[Currency]@{ccy="HNL";name="Honduran Lempira"}
[Currency]@{ccy="HRK";name="Croatian Kuna"}
[Currency]@{ccy="HTG";name="Haitian Gourde"}
[Currency]@{ccy="HUF";name="Hungarian Forint"}
[Currency]@{ccy="IDR";name="Indonesian Rupiah"}
[Currency]@{ccy="ILS";name="Israeli New Sheqel"}
[Currency]@{ccy="IMP";name="Manx pound"}
[Currency]@{ccy="INR";name="Indian Rupee"}
[Currency]@{ccy="IQD";name="Iraqi Dinar"}
[Currency]@{ccy="IRR";name="Iranian Rial"}
[Currency]@{ccy="ISK";name="Icelandic Krona"}
[Currency]@{ccy="JEP";name="Jersey Pound"}
[Currency]@{ccy="JMD";name="Jamaican Dollar"}
[Currency]@{ccy="JOD";name="Jordanian Dinar"}
[Currency]@{ccy="JPY";name="Japanese Yen"}
[Currency]@{ccy="KES";name="Kenyan Shilling"}
[Currency]@{ccy="KGS";name="Kyrgystani Som"}
[Currency]@{ccy="KHR";name="Cambodian Riel"}
[Currency]@{ccy="KMF";name="Comorian Franc"}
[Currency]@{ccy="KPW";name="North Korean Won"}
[Currency]@{ccy="KRW";name="South Korean Won"}
[Currency]@{ccy="KWD";name="Kuwaiti Dinar"}
[Currency]@{ccy="KYD";name="Cayman Islands Dollar"}
[Currency]@{ccy="KZT";name="Kazakhstani Tenge"}
[Currency]@{ccy="LAK";name="Laotian Kip"}
[Currency]@{ccy="LBP";name="Lebanese Pound"}
[Currency]@{ccy="LKR";name="Sri Lankan Rupee"}
[Currency]@{ccy="LRD";name="Liberian Dollar"}
[Currency]@{ccy="LSL";name="Lesotho Loti"}
[Currency]@{ccy="LYD";name="Libyan Dinar"}
[Currency]@{ccy="MAD";name="Moroccan Dirham"}
[Currency]@{ccy="MDL";name="Moldovan Leu"}
[Currency]@{ccy="MGA";name="Malagasy Ariary"}
[Currency]@{ccy="MKD";name="Macedonian Denar"}
[Currency]@{ccy="MMK";name="Myanma Kyat"}
[Currency]@{ccy="MNT";name="Mongolian Tugrik"}
[Currency]@{ccy="MOP";name="Macanese Pataca"}
[Currency]@{ccy="MRO";name="Mauritanian Ouguiya (pre-2018)"}
[Currency]@{ccy="MRU";name="Mauritanian Ouguiya"}
[Currency]@{ccy="MUR";name="Mauritian Rupee"}
[Currency]@{ccy="MVR";name="Maldivian Rufiyaa"}
[Currency]@{ccy="MWK";name="Malawian Kwacha"}
[Currency]@{ccy="MXN";name="Mexican Peso"}
[Currency]@{ccy="MYR";name="Malaysian Ringgit"}
[Currency]@{ccy="MZN";name="Mozambican Metical"}
[Currency]@{ccy="NAD";name="Namibian Dollar"}
[Currency]@{ccy="NGN";name="Nigerian Naira"}
[Currency]@{ccy="NIO";name="Nicaraguan Cordoba"}
[Currency]@{ccy="NOK";name="Norwegian Krone"}
[Currency]@{ccy="NPR";name="Nepalese Rupee"}
[Currency]@{ccy="NZD";name="New Zealand Dollar"}
[Currency]@{ccy="OMR";name="Omani Rial"}
[Currency]@{ccy="PAB";name="Panamanian Balboa"}
[Currency]@{ccy="PEN";name="Peruvian Nuevo Sol"}
[Currency]@{ccy="PGK";name="Papua New Guinean Kina"}
[Currency]@{ccy="PHP";name="Philippine Peso"}
[Currency]@{ccy="PKR";name="Pakistani Rupee"}
[Currency]@{ccy="PLN";name="Polish Zloty"}
[Currency]@{ccy="PYG";name="Paraguayan Guarani"}
[Currency]@{ccy="QAR";name="Qatari Rial"}
[Currency]@{ccy="RON";name="Romanian Leu"}
[Currency]@{ccy="RSD";name="Serbian Dinar"}
[Currency]@{ccy="RUB";name="Russian Ruble"}
[Currency]@{ccy="RWF";name="Rwandan Franc"}
[Currency]@{ccy="SAR";name="Saudi Riyal"}
[Currency]@{ccy="SBD";name="Solomon Islands Dollar"}
[Currency]@{ccy="SCR";name="Seychellois Rupee"}
[Currency]@{ccy="SDG";name="Sudanese Pound"}
[Currency]@{ccy="SEK";name="Swedish Krona"}
[Currency]@{ccy="SGD";name="Singapore Dollar"}
[Currency]@{ccy="SHP";name="Saint Helena Pound"}
[Currency]@{ccy="SLL";name="Sierra Leonean Leone"}
[Currency]@{ccy="SOS";name="Somali Shilling"}
[Currency]@{ccy="SRD";name="Surinamese Dollar"}
[Currency]@{ccy="SSP";name="South Sudanese Pound"}
[Currency]@{ccy="STD";name="Sao Tome and Principe Dobra (pre-2018)"}
[Currency]@{ccy="STN";name="Sao Tome and Principe Dobra"}
[Currency]@{ccy="SVC";name="Salvadoran Colon"}
[Currency]@{ccy="SYP";name="Syrian Pound"}
[Currency]@{ccy="SZL";name="Swazi Lilangeni"}
[Currency]@{ccy="THB";name="Thai Baht"}
[Currency]@{ccy="TJS";name="Tajikistani Somoni"}
[Currency]@{ccy="TMT";name="Turkmenistani Manat"}
[Currency]@{ccy="TND";name="Tunisian Dinar"}
[Currency]@{ccy="TOP";name="Tongan Pa'anga"}
[Currency]@{ccy="TRY";name="Turkish Lira"}
[Currency]@{ccy="TTD";name="Trinidad and Tobago Dollar"}
[Currency]@{ccy="TWD";name="New Taiwan Dollar"}
[Currency]@{ccy="TZS";name="Tanzanian Shilling"}
[Currency]@{ccy="UAH";name="Ukrainian Hryvnia"}
[Currency]@{ccy="UGX";name="Ugandan Shilling"}
[Currency]@{ccy="USD";name="United States Dollar"}
[Currency]@{ccy="UYU";name="Uruguayan Peso"}
[Currency]@{ccy="UZS";name="Uzbekistan Som"}
[Currency]@{ccy="VEF";name="Venezuelan Bolivar Fuerte"}
[Currency]@{ccy="VND";name="Vietnamese Dong"}
[Currency]@{ccy="VUV";name="Vanuatu Vatu"}
[Currency]@{ccy="WST";name="Samoan Tala"}
[Currency]@{ccy="XAF";name="CFA Franc BEAC"}
[Currency]@{ccy="XAG";name="Silver Ounce"}
[Currency]@{ccy="XAU";name="Gold Ounce"}
[Currency]@{ccy="XCD";name="East Caribbean Dollar"}
[Currency]@{ccy="XDR";name="Special Drawing Rights"}
[Currency]@{ccy="XOF";name="CFA Franc BCEAO"}
[Currency]@{ccy="XPD";name="Palladium Ounce"}
[Currency]@{ccy="XPF";name="CFP Franc"}
[Currency]@{ccy="XPT";name="Platinum Ounce"}
[Currency]@{ccy="YER";name="Yemeni Rial"}
[Currency]@{ccy="ZAR";name="South African Rand"}
[Currency]@{ccy="ZMW";name="Zambian Kwacha"}
[Currency]@{ccy="ZWL";name="Zimbabwean Dollar"}
)

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

