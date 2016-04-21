ECHO OFF
REM Borland C Batch File for CBIRD.exe with Interrupts
REM Usage: bcbrdint [library path] [Include path]
REM -c          - compile only
REM -O          - Jump Optimization
REM -G          - Speed Optimization
REM -N-         - remove stack overflow checks
REM -DTC        - Define TC
REM -I%2        - Define Include directory Path
REM
bcc -c -O -G -N- -DTC -I%2 birdmain.c
bcc -c -O -G -N- -DTC -I%2 birdcmds.c
bcc -c -O -G -N- -DTC -I%2 cmdutil.c
bcc -c -O -G -N- -DTC -I%2 menu.c
bcc -c -O -G -N- -DTC -I%2 serdpcin.c
bcc -c -O -G -N- -DTC -I%2 rstofbb.c
bcc -c -O -G -N- -DTC -I%2 pctimer.c
tlink %1\c0s @bcbrdint.rsp,cbird.exe,,%1\maths %1\emu %1\cs
