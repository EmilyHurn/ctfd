@echo off
setlocal

REM Check if the user provided a filename
if "%~1"=="" (
    echo Usage: ltdis.bat ^<program-file^>
    exit /b 1
)

REM Define the input file and output files
set "input_file=%~1"
set "strings_output=%input_file%.ltdis.strings.txt"
set "hex_dump_output=%input_file%.hex_dump.txt"

echo Attempting to analyze %input_file% ...

REM Use PowerShell to create a hex dump of the binary file
REM Note: Ensure PowerShell is available on your system
echo Running PowerShell to generate hex dump...
powershell -Command "Get-Content -Path '%input_file%' -Encoding Byte | ForEach-Object { $_.ToString('X2') } | Out-File -FilePath '%hex_dump_output%' -Encoding ASCII"

REM Check if the hex dump output file is non-empty
if exist "%hex_dump_output%" (
    for %%A in ("%hex_dump_output%") do if %%~zA neq 0 (
        echo Hex dump successful! Available at: %hex_dump_output%

        echo Ripping strings from binary with file offsets...
        REM Use PowerShell to extract strings
        powershell -Command "Add-Content -Path '%strings_output%' -Value (Get-Content -Path '%input_file%' -Raw | Select-String -Pattern '[ -~]{4,}' | ForEach-Object { $_.Line })"
        echo Any strings found in %input_file% have been written to %strings_output% with file offset
    ) else (
        echo Analysis failed!
        echo The output file is empty.
        echo Usage: ltdis.bat ^<program-file^>
        echo Bye!
    )
) else (
    echo Analysis failed!
    echo Usage: ltdis.bat ^<program-file^>
    echo Bye!
)

endlocal
