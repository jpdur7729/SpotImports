# ------------------------------------------------------------------------------
#                     Author    : F2 - JPD
#                     Time-stamp: "2021-02-21 18:42:08 jpdur"
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
    $cmd | Out-File -Encoding ASCII "./go.bat"

    # Execute the command
    & "./go.bat"

    # Delete the created .bat file 
    rm go.bat
}

# Add the method to the object
$ProcessingDef | Add-Member -MemberType ScriptMethod -Name "Process" -Value $ProcessingFct

# return the object created with the associated functions and Data
return $ProcessingDef
