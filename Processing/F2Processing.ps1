# ------------------------------------------------------------------------------
#                     Author    : FIS - JPD
#                     Time-stamp: "2021-03-30 11:48:24 jpdur"
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Method to process the generated spreadsheet accordingly
# We use the copied CSV version to the Data directory with the BatchID reference
# in order to be sure that the copied version is unique
# ------------------------------------------------------------------------------

# Create the object that will be returned afterwards
$ProcessingDef = ProcessingDef -Name "F2"

# Create the Line for the CSV File 
$ProcessingFct = {

    # Command to activate the server
    $cmd = "f:/proto/import/import -c FXRate -s http://localhost:8090 -f "+ $Exec_Dir +"\Data\FXRate"+$BatchId +".csv" + " -u xx -p zz -o ""./ResultsF2Processing.xlsx"""

    # Store the command in a .bat file (Encoding ASCII guarantees that there is no odd character
    $cmd | Out-File -Encoding ASCII "./goproc.bat"

    # Execute the command
    & "./goproc.bat"

    # Delete the created .bat file 
    rm goproc.bat
}

# Add the method to the object
$ProcessingDef | Add-Member -MemberType ScriptMethod -Name "Process" -Value $ProcessingFct

# return the object created with the associated functions and Data
return $ProcessingDef
