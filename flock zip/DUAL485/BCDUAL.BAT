ECHO OFF
REM Borland C Batch File for DUAL485.exe
REM Usage: bcdual [Include path] [library path] 
REM         i.e. bcdual c:\borlandc\include f:\borlandc\lib
REM
REM -c          - compile only
REM -O          - Jump Optimization
REM -G          - Speed Optimization
REM -N-         - remove stack overflow checks
REM -DTC        - Define TC
REM -I%1        - Define Include directory
REM
bcc -c -O -G -N- -DTC -I%1 dual485.c
bcc -c -O -G -N- -DTC -I%1 fbbcmds.c
bcc -c -O -G -N- -DTC -I%1 cube.c
bcc -c -O -G -N- -DTC -I%1 menu.c
bcc -c -O -G -N- -DTC -I%1 pcpic.c
bcc -c -O -G -N- -DTC -I%1 pctimer.c
bcc -c -O -G -N- -DTC -I%1 ser_gen.c
bcc -c -O -G -N- -DTC -I%1 xms.c
tasm callxms.asm
tlink %2\c0s @bcdual.rsp,%2\graphics %2\maths %2\emu %2\cs
