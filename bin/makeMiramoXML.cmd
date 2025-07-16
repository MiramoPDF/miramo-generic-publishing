@echo off
:: usage: makeMiramoXML input.xml miramooutput.xml
:: cd to the working folder
IF "%~2"=="" (
    echo Usage: %~nx0 input.xml output.xml
    exit /b 1
)

REM Check if the input file exists
IF NOT EXIST "%~1" (
    echo Error: Input file "%~1" does not exist.
    exit /b 1
)
pushd .
cd /d %~d0%~p0/../workingFolder
set XSL=../xsl/example.xsl
:: Check miramo is installed and on the path
miramo -v >NUL:
if ERRORLEVEL 1 goto :NOMIRAMO
echo Creating MiramoXML file %2 from %1 using XSL stylesheet %XSL% ... 
:: use mmxslt (the Miramo xsl stylesheet processor) to apply medtronic2miramo.xsl to map from the input XML to the intermediate MiramoXML
:: Note that you are free to substitute any XSLT processor in the line below
mmxslt -Xxsl %XSL% -in %1 -out %2

@if ERRORLEVEL 1 goto :FAIL
@echo MiramoXML %2 created successfully!
goto :EOF

:FAIL
echo Failed to create MiramoXML - is the XSL stylesheet installed?
goto :EOF
:NOMIRAMO
echo miramo does not appear to be installed, or is not available on the path. Please reinstall and try again
goto :EOF