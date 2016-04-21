ECHO OFF	
REM Turbo Assembler Batch File for ABIRD.exe in Polled Mode
REM Usage: tabrdpol
REM 
tasm birdmain.asm
tasm menu.asm
tasm birdcmds.asm
tasm cmdutil.asm
tasm serdpcpl.asm
tlink birdmain + menu + birdcmds + cmdutil + serdpcpl,abird
