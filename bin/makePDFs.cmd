@echo off
:: record folder name containing this run script
set BINDIR=%~d0%~p0
:: Check miramo is installed and on the path
miramo -v >NUL:
if ERRORLEVEL 1 goto :NOMIRAMO
echo Creating MiramoXML file example_miramo.xml from generic example.xml using XSL stylesheet example.xsl ... 
@echo on
:: call makeMiramoXML to map example XML to MiramoXML
cmd /c %BINDIR%\makeMiramoXML.cmd example.xml example_miramo.xml

:: Render the intermediate miramoXML file to PDF using the formatting information in template.mfd
:: To produce the final PDF with no PDF tooltips, remove '-showProperties Y' from the line below
@echo Creating example.pdf and example_dev.pdf from MiramoXML using formatting information from template.mfd GUI template ...
miramo -showProperties Y -composer mmc -Opdf example_dev.pdf -mfd ../mmtemplates/template.mfd example_miramo.xml
@if ERRORLEVEL 1 goto :FAIL
@echo PDF file example_dev.pdf created successfully!
miramo -composer mmc -Opdf example.pdf -mfd ../mmtemplates/template.mfd example_miramo.xml
@if ERRORLEVEL 1 goto :FAIL
@echo PDF file example.pdf created successfully!
goto :EOF
:FAIL
echo Failed to create PDF - is the PDF file locked? Is MiramoPDF or MiramoEnterprise installed?
goto :EOF
:NOMIRAMO
echo miramo does not appear to be installed, or is not available on the path. Please reinstall and try again
goto :EOF