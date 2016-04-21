ECHO OFF
REM Microsoft Assembler Batch File for ABIRD.exe in Interrupt Mode
REM Usage: mabrdint 
REM 
masm birdmain.asm;
masm menu.asm;
masm birdcmds.asm;
masm cmdutil.asm;
masm serdpcin.asm;
link birdmain + menu + birdcmds + cmdutil + serdpcin,abird,,,;
