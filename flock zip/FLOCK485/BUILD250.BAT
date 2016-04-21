ECHO OFF  
REM Microsoft Assembler Batch File for FBBTEST at 250 Kbaud
REM with the Quatech card a 8Mhz
REM Usage: build 
REM
REM 
tasm /DQUATECH_8MHZ fbbtest.asm;
tasm /DQUATECH_8MHZ hostcom.asm;
tasm fbbhost.asm;
tasm menu.asm;
tasm birdcmds.asm;
tasm cmdutil.asm;
tlink fbbtest + fbbhost + hostcom + menu + birdcmds + cmdutil, fbb250;
