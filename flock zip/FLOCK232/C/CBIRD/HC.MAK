# ***************************************************************************
# Make file for HC
#
# Modification History:
#    10/19/93  jf - created for the HC compiler
#
# ***************************************************************************

CFLAGS  = -DHIGHC -DPHAR386
CC      = hc386

cbird.exe:  birdmain.obj birdcmds.obj cmdutil.obj serdpcin.obj menu.obj \
			rstofbb.obj pctimer.obj hcint.obj
	386link @hccbird

birdmain.obj:   birdmain.c birdmain.h asctech.h compiler.h serial.h rstofbb.h menu.h
	$(CC) -c $(CFLAGS) birdmain.c

birdcmds.obj:   birdcmds.c birdcmds.h asctech.h compiler.h serial.h rstofbb.h menu.h
	$(CC) -c $(CFLAGS) birdcmds.c

cmdutil.obj:    cmdutil.c cmdutil.h asctech.h compiler.h serial.h menu.h
	$(CC) -c $(CFLAGS) cmdutil.c

menu.obj:       menu.c menu.h asctech.h compiler.h
	$(CC) -c $(CFLAGS) menu.c

rstofbb.obj:    rstofbb.c menu.h asctech.h compiler.h rstofbb.h serial.h
	$(CC) -c $(CFLAGS) rstofbb.c

serdpcin.obj:    serdpcin.c menu.h asctech.h compiler.h serial.h
	$(CC) -c $(CFLAGS) serdpcin.c

pctimer.obj:    pctimer.c asctech.h compiler.h
	$(CC) -c $(CFLAGS) pctimer.c

hcint.obj:	    hcint.asm
	386asm -twocase -nolist hcint.asm
