REM     
REM QuickBasic Batch File for BBIRD.exe 
REM Usage: bbird [library path]
REM
REM /O - Use the BCOM*.lib
REM /V - Enable Event Trapping
REM /X - Enable 'ON ERROR','RESUME..'
REM
bc /O/V/X bbird.bas;
link bbird,bbird,,%1,;
