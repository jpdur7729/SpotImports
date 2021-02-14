# --------------------------------------------------------------
#                  Author    : JPD
#                  Time-stamp: "2021-02-14 15:10:58 jpdur"
# --------------------------------------------------------------
https://orgmode.org/manual/Escape-Character.html C-x 8 to enter the
non visible escape character

* Overview 
Generic Interface to
1) Extract FX Rates from
   - a given source
   - for a different period
   - for a given list of currencies
   - generating FXPair or FXRate
   - using a base currency different from the source default
2) Product different types of Format
   - FIS
   - F2 // JPD legacy format to proces the data
3) Action
   - Execute/Upload 
   - Store in log
** Intermediate Results
An intermediate csv is - optionally - generated to enable some type
of exports
** Final Results
The csv is transformed into an XLSX spreadsheet ready to be
processed


* Installation
** Required Setup
SpotImports relies on the Import-Excel module which needs to be
installed Reference of how to install Import-Excel can be found at

** Source-specific required
Due to the nature of the different sources and how the data is
extracte different complementary tools are required

| Source | Tool | Comments                                        |
|--------+------+-------------------------------------------------|
| ECB    | wget | Different options                               |
|        |      | Executable assumed to be available - Check Path |
|--------+------+-------------------------------------------------|
| MAS    | -    | Request relying on building an ad-hoc URL       |
|        |      | No complementary tool is required               |
|--------+------+-------------------------------------------------|
| BoE    | -    | Request relying on building an ad-hoc URL       |
|        |      | No complementary tool is required               |
|        |      |                                                 |
                           

* Directory structure
| Directory  | Comments                                                        |
|------------+-----------------------------------------------------------------|
| .          | Where the code, documentation and dashboard is maintained Data  |
| Data       | Repository of all spreadsheet created                           |
| Format     | Repository of all the methods associated to the various formats |
| Action     | Repository of all the methods associated to the various Actions |
| Processing | Repository of all the methods associated to Processing          |
|------------+-----------------------------------------------------------------|
| ECB        | Scripts/ Data / ECB specific                                    |
| MAS        | Scripts/ Data / MAS specific                                    |
| ...        |                                                                 |

  
* Control Dashboard
An Excel spreadsheet is updated with each and everyone of the call
to the extract It stores the batch ID, the various parameters used
and a link to the result file That way it is easy to have:
1) A unique name for each and every file created No name ambiguity
   so easy to manage and upload even if unicity constraints are
   required and/or the file is a repeat of a previous extract
2) Now when the files were created and what is the expected contents
   of the file
3) The excel spreadsheet can then be used to check that the expected
   batches have run.


* Parameters
** Source
Indicates the source of the FX Rates
| Values    | Directory | Default | Comments                     |
|-----------+-----------+---------+------------------------------|
| ECB       | ECB       | D       | European Central Bank        |
| MAS       | MAS       |         | Monetary Authority Singapore |
|-----------+-----------+---------+------------------------------|
| BoE       |           | Not Yet | Bank of England              |
| RijksBank |           | Not Yet | Swedish Central Bank         |
|           |           |         |                              |
** Dates
All Dates are string in the following format yyyy-mm-dd
| Parameter  | Default | Comments                        |
|------------+---------+---------------------------------|
| -StartDate | D       | If not populated System Date    |
| -EndDate   | D       | If not populated StartDate -1   |
|------------+---------+---------------------------------|
| -ListDate  |         | List of dates all in yyyy-mm-dd |
|            |         | Not Yet Implemented             |
|------------+---------+---------------------------------|
As a result of the default convention if no StartDate and no
EndDate is indicated then extraction happens only for today.
** BaseCurrency
By default not populated and the Base currency of the Source as
predefined ECB - EUR MAS - SGD is used Base currency is a list of
currency with 1 or more currencies. That implies that the number of
records generated will be n*p where:
- n is the number of currencies extract (cf. List Currencies or the
  list of currencies fron the Source Setup) d
- p is the number of currencies in the BaseCurrency parameter
  In case of using FXRate only 1st value will be used. The currency
  is assume to be different from the default currency of the Source
  and be the pivot currency of the FXRate
That is an extension to be considered
** ListCurrencies
Important in order to be able to automatically indicate a sub set
of currencies By default the ListCurrencies are defined based on
the Source ListCurrencies from ECB will always integrate NOK,SEK
but not THB or IDR ListCurrencies from MAS will include THB,IDR but
not ...  For the default from each source cf. the relevant data for
the corresponding source
** Output
| Values  | Default | Comments                                               |
|---------+---------+--------------------------------------------------------|
| CsvOnly |         | Only a CSV File based on the default separator         |
| CsvXlsx | D       |                                                        |
|---------+---------+--------------------------------------------------------|
| XLS     |         | Generates an xls spreadsheet with the CSV              |
|         |         | Not implemented YET - Only if Import-Excel supports it |
|---------+---------+--------------------------------------------------------|
** CSVSep
A list of possible values addesd ; | whoch should cover the
non-English csv format Please note that TAB is currently not
supported
| Values | Default | Comments             |
|--------+---------+----------------------|
| ,      | D       | Standard CSVSep      |
|--------+---------+----------------------|
| ;      |         |                      |
| ¦      |         | Pipe could be useful |
** Processing
| Values   | Default | Comments                                   |
|----------+---------+--------------------------------------------|
| NoAction | D       | The generated file(s) are not processed    |
|----------+---------+--------------------------------------------|
| F2       |         | Process through F2 mechanism               |
|----------+---------+--------------------------------------------|
| FIS      | Future  | When using the automatic drop down for FIS |
|----------+---------+--------------------------------------------|
** Format
| Values | Default | Comments   |
|--------+---------+------------|
| F2     |         | F2 project |
| FIS    | D       | Investran  |
** FISType
Option only is accepted is Format = FIS
| Values | Default | Comments            |
|--------+---------+---------------------|
| FXPair | D       |                     |
| FXRate |         | Not yet Implemented |
** FISVariant
This is an option used for FIS only if Closing is not used There is no
control about the value. Only a default value *Closing* is provided.
* Date Format
Theoretically precaution has beem taken to convert/handle Date
in the universal format yyyy-MM-dd
That should work for both European and US users although not tested for US users
** If necessary
Possibility to leverage Use-Culture to manage Date and potentially CSV characteristics
Not tested and worked upon as it adds an extra dependemcy to the configuration
Link below is a pointe to the different elements
https://devblogs.microsoft.com/scripting/formatting-date-strings-with-powershell/









