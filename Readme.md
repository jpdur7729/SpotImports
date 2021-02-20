# Overview

Generic Interface to

1.  Extract FX Rates from

    -   a given source
    -   for a different period
    -   for a given list of currencies
    -   generating FXPair or FXRate
    -   using a base currency different from the source default

2.  Produce file for different types of Format

    1.  FIS
    2.  F2 i.e. *JPD legacy format*

3.  Process the generated files

    -   Execute/Upload
    -   Store in log

## Intermediate Results

An intermediate csv is always generated

## Final Results

The csv is optionally transformed into an XLSX spreadsheet ready to be
processed

# Installation

## Required Setup

SpotImports relies on the Import-Excel module which needs to be
installed Reference of how to install Import-Excel can be found at

## Source-specific required

Due to the nature of the different sources and how the data is extracte
different complementary tools are required

| Source | Tool | Comments                                        |
|--------|------|-------------------------------------------------|
| ECB    | wget | Different options                               |
|        |      | Executable assumed to be available - Check Path |
| MAS    | \-   | Request relying on building an ad-hoc URL       |
|        |      | No complementary tool is required               |
| BoE    | \-   | Request relying on building an ad-hoc URL       |
|        |      | No complementary tool is required               |
|        |      |                                                 |

# Directory structure

| Directory  | Comments                                                        |
|------------|-----------------------------------------------------------------|
| .          | Where the code, documentation and dashboard is maintained Data  |
| Data       | Repository of all spreadsheet created                           |
| Format     | Repository of all the methods associated to the various formats |
| Action     | Repository of all the methods associated to the various Actions |
| Processing | Repository of all the methods associated to Processing          |
| ECB        | Scripts/ Data / ECB specific                                    |
| MAS        | Scripts/ Data / MAS specific                                    |
| …          |                                                                 |

# Control Dashboard

An Excel spreadsheet is updated with each and everyone of the call to
the extract It stores the batch ID, the various parameters used and a
link to the result file That way it is easy to have:

1.  A unique name for each and every file created No name ambiguity so
    easy to manage and upload even if unicity constraints are required
    and/or the file is a repeat of a previous extract
2.  Now when the files were created and what is the expected contents of
    the file
3.  The excel spreadsheet can then be used to check that the expected
    batches have run.

# Parameters

## Source

Indicates the source of the FX Rates

| Values    | Directory | Default | Comments                     |
|-----------|-----------|---------|------------------------------|
| ECB       | ECB       | D       | European Central Bank        |
| MAS       | MAS       |         | Monetary Authority Singapore |
| BoE       |           | Not Yet | Bank of England              |
| RijksBank |           | Not Yet | Swedish Central Bank         |
|           |           |         |                              |

## Dates

All Dates are string in the following format yyyy-mm-dd

| Parameter  | Default | Comments                        |
|------------|---------|---------------------------------|
| -StartDate | D       | If not populated System Date    |
| -EndDate   | D       | If not populated StartDate -1   |
| -ListDate  |         | List of dates all in yyyy-mm-dd |
|            |         | , `comma` separated             |

### StartDate / EndDate

As a result of the default convention if no StartDate and no EndDate is
indicated then extraction happens only for Today and the day Before

### ListDates

If ListDates is populated then StartDate and EndDate are **NOT** taken
into account even if populated.

The Extract phase is done based on:

-   the minimum Date in the list = StartDate
-   the maximal Date in the list = EndDate

The result of the extraction is then filtered using ListDates

## BaseCurrency

Exchange Rates are always presented against a Base Currency. By default
the Base Currency is the Base Curency of the source.

| Source | Default Base Currency |
|--------|-----------------------|
| ECB    | EUR                   |
| MAS    | SGD                   |
|        |                       |

But in some cases, it might be required to present the Exchange Rates
against a different Base Currency from the one provided by the Source

An example could be:

-   Source = MAS // required Base Currency = USD

A triangulation needs to be added in order to transform the SGD/VND
provided into the required USD/VND. In a similar way the SGD/USD
provided is replaced by the USD/SGD

### Not yet required

BaseCurrency could be extended and become a list of BaseCurrency.

No extra gain in accuracy but a higher volume of data to be handled. As
that implies that the number of records generated will be n\*p where:

-   n is the number of currencies extract (cf. List Currencies or the
    list of currencies fron the Source Setup)
-   p is the number of currencies in the BaseCurrency parameter list.

## ListCurrencies

Important in order to be able to automatically indicate a sub set of
currencies By default the ListCurrencies are defined based on the Source
ListCurrencies from ECB will always integrate NOK,SEK but not THB or IDR
ListCurrencies from MAS will include THB,IDR but not … For the default
from each source cf. the relevant data for the corresponding source

## Output

| Values  | Default | Comments                                               |
|---------|---------|--------------------------------------------------------|
| CsvOnly |         | Only a CSV File based on the default separator         |
| CsvXlsx | D       |                                                        |
| XLS     |         | Generates an xls spreadsheet with the CSV              |
|         |         | Not implemented YET - Only if Import-Excel supports it |

## CSVSep

A list of possible values addesd ; \| whoch should cover the non-English
csv format Please note that TAB is currently not supported

| Values | Default | Comments             |
|--------|---------|----------------------|
| ,      | D       | Standard CSVSep      |
| ;      |         |                      |
| ¦      |         | Pipe could be useful |

## Processing

| Values   | Default | Comments                                   |
|----------|---------|--------------------------------------------|
| NoAction | D       | The generated file(s) are not processed    |
| F2       |         | Process through F2 mechanism               |
| FIS      | Future  | When using the automatic drop down for FIS |

## Format

| Values | Default | Comments   |
|--------|---------|------------|
| FIS    | D       | Investran  |
| F2     |         | F2 project |

## FISType

Option only is accepted is Format = FIS

| Values | Default | Comments            |
|--------|---------|---------------------|
| FXPair | D       |                     |
| FXRate |         | Not yet Implemented |

## FISVariant

This is an option used for FIS only if Closing is not used There is no
control about the value. Only a default value **Closing** is provided.

## Show

| Values | Default | Comments                                                |
|--------|---------|---------------------------------------------------------|
| Show   | D       | Display the contents of the FXRate spreadsheet in Excel |
| NoShow |         | Does not display anything in Excel.                     |

NoShow option is actually useful if various circumstances such as:

1.  Excel is NOT available
2.  For testing purposes when many extracts in succession are done

# Date Format

Theoretically precaution has beem taken to convert/handle Date in the
universal format yyyy-MM-dd That should work for both European and US
users although not tested for US users

## If necessary

Possibility to leverage Use-Culture to manage Date and potentially CSV
characteristics Not tested and worked upon as it adds an extra
dependemcy to the configuration Link below is a pointe to the different
elements
<https://devblogs.microsoft.com/scripting/formatting-date-strings-with-powershell/>
