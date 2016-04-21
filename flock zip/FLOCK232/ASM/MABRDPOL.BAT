ECHO OFF
REM Microsoft Assembler Batch File for ABIRD.exe in Polled Mode
REM Usage: mabrdpol
REM 
masm birdmain.asm;
masm menu.asm;
masm birdcmds.asm;
masm cmdutil.asm;
masm serdpcpl.asm;
link birdmain + menu + birdcmds + cmdutil + serdpcpl,abird,,,;
