ECHO OFF	
REM Turbo Assembler Batch File for ABIRD.exe in Interrupt Mode
REM Usage: tabrdint
REM 
tasm birdmain.asm
tasm menu.asm
tasm birdcmds.asm
tasm cmdutil.asm
tasm serdpcin.asm
tlink birdmain + menu + birdcmds + cmdutil + serdpcin,abird
