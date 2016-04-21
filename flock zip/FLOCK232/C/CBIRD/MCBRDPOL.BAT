ECHO OFF
REM Microsoft C Batch File for CBIRD.exe in Polled Mode
REM Usage: mcbrdpol [library path]
REM        where library path is of the form D:\MSC600\LIB
REM /c      - Compile only
REM /FPi    - In line x87 Emulation
REM /Ox     - Optimization, speed preference
REM /Gs     - Remove Stack Checking
REM /DMSC   - Define MSC
REM
cl /c /FPi /AS /Gs /Ox /DMSC birdmain.c
cl /c /FPi /AS /Gs /Ox /DMSC birdcmds.c
cl /c /FPi /AS /Gs /Ox /DMSC cmdutil.c
cl /c /FPi /AS /Gs /Ox /DMSC menu.c
cl /c /FPi /AS /Gs /Ox /DMSC serdpcpl.c
cl /c /FPi /AS /Gs /Ox /DMSC rstofbb.c
cl /c /FPi /Ox /AS /Gs /DMSC pctimer.c
link  birdmain birdcmds cmdutil menu serdpcpl rstofbb pctimer,cbird.exe,,%1\slibce,;
