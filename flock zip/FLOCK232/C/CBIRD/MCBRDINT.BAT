ECHO OFF
REM Microsoft C Batch File for CBIRD.exe with Interrupts
REM Usage: mcbrdint [library path]
REM /c      - Compile only
REM /Ox     - Optimization, speed preference
REM /Gs     - Remove Stack Checking
REM /DMSC   - Define MSC
REM
cl /c /Ox /AS /Gs /DMSC birdmain.c
cl /c /Ox /AS /Gs /DMSC birdcmds.c
cl /c /Ox /AS /Gs /DMSC cmdutil.c
cl /c /Ox /AS /Gs /DMSC menu.c
cl /c /Ox /AS /Gs /DMSC serdpcin.c
cl /c /Ox /AS /Gs /DMSC rstofbb.c
cl /c /Ox /AS /Gs /DMSC pctimer.c
link birdmain birdcmds cmdutil menu serdpcin rstofbb pctimer,cbird.exe,,%1\slibce,;
