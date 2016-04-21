# ***************************************************************************
# unix.mak      - Make File for UNIX
#
# Modification History:
#    1/27/93  jf - created
#
# ***************************************************************************

#
# UNCOMMENT the OS macro for the correct Operating System
#
#OS      = COHERENT
OS      = IRIX
#OS      = SUNOS
#OS      = AIX
#OS      = ULTRIX

CFLAGS  = -DKNR -D$(OS)
CC      = cc

cbird:        birdmain.o birdcmds.o cmdutil.o serknr.o menu.o rstofbb.o
	$(CC) birdmain.o birdcmds.o cmdutil.o serknr.o menu.o rstofbb.o -lm -o cbird

birdmain.o:   birdmain.c birdmain.h asctech.h compiler.h serial.h rstofbb.h
	$(CC) -c $(CFLAGS) birdmain.c

birdcmds.o:   birdcmds.c birdcmds.h asctech.h compiler.h serial.h rstofbb.h
	$(CC) -c $(CFLAGS) birdcmds.c

cmdutil.o:    cmdutil.c cmdutil.h asctech.h compiler.h serial.h
	$(CC) -c $(CFLAGS) cmdutil.c

serknr.o:     serknr.c serial.h asctech.h compiler.h
	$(CC) -c $(CFLAGS) serknr.c

menu.o:       menu.c menu.h asctech.h compiler.h
	$(CC) -c $(CFLAGS) menu.c

rstofbb.o:    rstofbb.c menu.h asctech.h compiler.h rstofbb.h
	$(CC) -c $(CFLAGS) rstofbb.c
