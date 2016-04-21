/****************************************************************************
*****************************************************************************
    menu.c  - Menu Routines

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:

    10/18/90       jf  - released
    4/23/91        jf  - cleanup unused variables noticed when compiling
                         on UNIX platform
    4/24/91        jf  - added initconsole and restoreconsole routines
                         for UNIX platform
    3/23/92        jf  - update sendmenu to go to 2 columns if the
                         menucount is greater than 16
    12/29/92       jf  - moved all #ifdefs and #defines to column 1
                         for compiler compatibility
    9/20/93        jf  - added getfilename and getfloat

           <<<< Copyright 1990 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>      /* general I/O */
#include <stdlib.h>     /* atoi */
#include <string.h>     /* string stuff */
#include "compiler.h"   /* Compiler Specific Header */
#include "menu.h"

/*
    For UNIX environments, IOCTL is used to set the console/terminal
    into RAW mode...store the old config to restore when the
    program is exited

                            *** NOTE ***
    For other environments, the User may have to modify the initconsole()
    and restoreconsole() routines for the menuing functions to perform
    properly
*/
#ifdef UNIX_SGTTY
    struct sgttyb oldstdin_sgttyb;  /* storage for the old config */
    struct sgttyb stdin_sgttyb;     /* passed to ioctl for new config */
#endif

#ifdef UNIX_TERMIO
    struct termio oldstdin_termio;  /* storage for the old config */
    struct termio stdin_termio;     /* passed to ioctl for new config */
#endif

/*
    sendmenuhdr         - Send Menu Header

    Prototype in:       menu.h

    Parameters Passed:  hdrstring, the header to be displayed

    Return Value:       void

    Remarks:            Clears the Screen and Displays the Header
*/
void sendmenuhdr(hdrstring)
char * hdrstring;
{
    CLEARSCREEN;
    printf(hdrstring);
}

/*
    clearconsole        - Clear the System Console

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            The Programmer must add the System Specific Call
                        to clear the system console...for now, the code
                        just performs a New Line
*/
void clearconsole()
{
    /*
        Insert System Call to Clear the Console Screen
    */
    printf("\n\r");
}


/*
    clearkey            - Clears the buffer from STDIN

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            clears STDIN

*/
void clearkey()
{
    while (ckkbhit())
        getkey();
}

/*
    ckkbhit            - Check if a Key is Ready

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       TRUE if a key is Ready, else FALSE

    Remarks:            If DOS, then the Keyboard is checked else, if
                        ANSI/UNIX the routine checks STDIN to see if a key is ready
*/
int ckkbhit()
{

#ifdef DOS
     return(kbhit());
#endif

#ifdef UNIX
     int tempint;        /* define a buffer */

     ioctl(fileno(stdin),TIONREAD,&tempint); /* get the number of keys rdy */
     if (tempint > 0)
         return(TRUE);   /* key is ready */

     return(FALSE);      /* key is not ready */
#endif
}

/*
    getkey              - get a key from the system console

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       key code as an integer

    Remarks:
*/
int getkey()
{
#ifdef DOS
    return(getch());
#endif

#ifdef UNIX
    return(getchar());
#endif
}


/*
    sendmenu            - Send Menu

    Prototype in:       menu.h

    Parameters Passed:  menustringptr   - double pointer to selection
                                          list, with header
                        menucount       - number of valid selections

    Return Value:       intanswer       - answer from the menu selection or
                                          ESC_SEL if ESC was hit

    Remarks:            prompts the user with a list of valid selections
                        numbered 0 through menucount-1, with a prompt string
                        prefacing the first selection (first string in list).
*/
int sendmenu(menustringptr,menucount)
char **menustringptr;
short menucount;
{

#define MENULINELENGTH 80

    short tempcount;
    short intanswer;
    short invalid;
    char **tempmenustringptr;
    short i;
    short menusidelength;
    char menulinebuf[MENULINELENGTH+1];


    do
    {
        invalid = FALSE;
        tempmenustringptr = menustringptr;

        /*
            Put up the Menu Selections
        */
        printf("\n\r%s\n\r",*tempmenustringptr++); /* first put up the header */
        if (menucount <= 16)
        {
            for (tempcount = 0; tempcount<menucount;tempcount++)
                printf("\t\t%3d.  %s\n\r",tempcount, *tempmenustringptr++);
        }
        else
        {   
            menusidelength = menucount/2+(menucount & 1);
            for (tempcount = 0; tempcount<menusidelength;tempcount++)
            {
                /* 
                    fill line with spaces 
                */
                for (i=0;i<MENULINELENGTH;i++)
                    menulinebuf[i] = ' ';
                /*
                   Print first half of menu
                */
                sprintf(&menulinebuf[0],"%3d.  %s",
                        tempcount, tempmenustringptr[tempcount]);
                /*
                   Print second half of menu
                */
                if ((tempcount+menusidelength) < menucount)
                {
                    /* remove NULL terminator */
                    menulinebuf[strlen(menulinebuf)] = ' ';
                    sprintf(&menulinebuf[MENULINELENGTH/2 - 4],"%3d.  %s",
                        tempcount+menusidelength, 
                        tempmenustringptr[tempcount+menusidelength]);
                }
                printf("%s\n\r",menulinebuf);   /* send to the console */
            }
        }

        /*
            Get the Menu Answer
        */
        printf("\n\rEnter Selection (0 to %d): ", menucount-1);
        fflush(stdout);

        /*
            Get the answer and do minimal validation
        */
        if ((intanswer = getnumber()) == ESC_SEL)
            return(ESC_SEL);

        if ((intanswer > menucount-1) || (intanswer < 0))
        {
            invalid = TRUE;
            printf("\n\r*** Invalid Input ***\n\r");
            hitkeycontinue();
        }
    }
    while(invalid);

    /*
        Start a fresh line
    */
    printf("\n\r");
    fflush(stdout);
    return(intanswer);
}

/*
    askyesno            -   Ask Yes or No

    Prototype in:       menu.h

    Parameters Passed:  quesstring      - character string used for prompt

    Return Value:       returns TRUE if yes, FALSE if no, and if the
                        ESC key is selected then it returns ESC_SEL

    Remarks:            prompts user with a quesstring and then waits for
                        a Y/y, N/n or ESC.
*/
int askyesno(quesstring)
char * quesstring;
{
    short ch;

    printf("%s (Y/N)?",quesstring);

    while ((ch = getkey()) != ESC)
    {
        if ((ch == 'Y') || (ch == 'y'))
        {
            putchar(ch);
            fflush(stdout);
            return(TRUE);
        }

        if ((ch == 'N') || (ch == 'n'))
        {
            putchar(ch);
            fflush(stdout);
            return(FALSE);
        }
    }
    fflush(stdout);
    return(ESC_SEL);
}


/*
    getnumber           -   Get Number

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       intansw     -   integer corresponding to the number
                                        input by the user or ESC_SEL if the
                                        user hit the ESC key

    Remarks:            the routine allows the user to input numbers 0-9,
                        and terminate with a CR.  If invalid keys are
                        depressed the BEL sound is echoed.
*/
int getnumber()
{
    char answbuf[80];
    char * answbufptr = answbuf;
    char chr;
    short intanswer;

    /*
        Get a decimal number from the console
    */
    while (TRUE)
    {
        fflush(stdout);
        chr = getkey();

        /*
            Escape
        */
        if (chr == ESC)
            return(ESC_SEL);                    /* return with escape selected */

        /*
            Numbers
        */
        if ((chr >= 0x30) && (chr <= 0x39))
        {
            putchar(chr);                       /* echo character */
            *answbufptr++ = chr;                /* store character */
            continue;
        }

        /*
            Backspace
        */
        if (answbufptr > answbuf)               /* characters to runover? */
        {
            if (chr == BS)
            {
                putchar(BS);                    /* backspace */
                putchar(SP);                    /* put up a space */
                putchar(BS);                    /* backspace again */
                *--answbufptr = 0;              /* clear previous character */
                continue;
            }
        }
        else
        {
            putchar(BEL);
            continue;
        }

        /*
            Carrage Return
        */
        if (chr == CR)
        {
            *answbufptr = 0;                    /* terminate string */
            if (strlen(answbuf) == 0)           /* if they CR on nothing */
                return(ESC_SEL);
            putchar(chr);                       /* echo the carriage ret */
            putchar(LF);                        /* send a line feed */
            intanswer = (atoi(answbuf));        /* convert to integer */
            break;
        }

        /*
            Garbage
        */
        putchar(BEL);                           /* beep */
    }

    return(intanswer);                          /* return the integer */
}

/*
    getfloatstring      -   Get float string

    Prototype in:       menu.h

    Parameters Passed:  floatstringbuf, pointer to buffer for the string

    Return Value:       floatstringbuf, if user inputs data OK
                        NULL ptr, if user selects ESC

    Remarks:            the routine allows the user to input numbers 0-9,
                        '.','-','+' and terminate with a CR.  If invalid
                        keys are depressed the BEL sound is echoed.
*/
char * getfloatstring(floatstringbuf)
char * floatstringbuf;
{
    char chr;
    char * floatbufptr = floatstringbuf;

    /*
        Get a string from the console
    */
    while (TRUE)
    {
        fflush(stdout);
        chr = getkey();

        /*
            Escape
        */
        if (chr == ESC)
            return(NULL);                   /* return with escape selected */

        /*
            Numbers
        */
        if ((chr >= 0x30) && (chr <= 0x39))
        {
            putchar(chr);                         /* echo character */
            *floatbufptr++ = chr;               /* store character */
            continue;
        }

        /*
            Backspace
        */
        if (chr == BS)
        {
            if (floatbufptr > floatstringbuf)       /* characters to runover? */
            {
                putchar(BS);                      /* backspace */
                putchar(SP);                      /* put up a space */
                putchar(BS);                      /* backspace again */
                *--floatbufptr = 0;             /* clear previous character */
                continue;
            }
            else
            {
                putchar(BEL);
                continue;
            }
        }

        /*
            Float Point Characters
        */
        if ((chr == '.') || (chr == '+') || ( chr == '-'))
        {
            *floatbufptr++ = chr;               /* store character */
            putchar(chr);                         /* echo */
            continue;
        }

        /*
            Carrage Return
        */
        if (chr == CR)
        {
            *floatbufptr = 0;                /* terminate string */
            if (strlen(floatstringbuf) == 0)    /* if they CR on nothing */
            {
                putchar(BEL);                     /* beepem */
                continue;                       /* ...just continue */
            }
            putchar(chr);                         /* echo the carriage ret */
            putchar(LF);                          /* send a line feed */
            break;
        }

        /*
            Garbage
        */
        putchar(BEL);                             /* beep */
    }

    return(floatstringbuf);                     /* return the integer */
}

/*
    getushort           -   Get Unsigned Short Number with Text Prompt

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       short  answ -   integer corresponding to the number
                                        input by the user or ESC_SEL if the
                                        user hit the ESC key

    Remarks:
*/
short getushort(prompt,min,max)
char * prompt;
short min;
short max;
{
    unsigned short invalid;
    short answ;

    do
    {
        invalid = FALSE;

        printf("\n\r%s ",prompt);
        answ = getnumber();
        if (answ == ESC_SEL)
            return(ESC_SEL);
        if ((answ < min) || (answ > max))
        {
            invalid = TRUE;
            printf("\n\r** ERROR ** illegal entry, please try again\n\r");
        }
    }
    while(invalid);

    return(answ);
}

/*
    getfloat            -   Get float Number with Text Prompt

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       double answ -  float corresponding to the number
                                       input by the user or ESC_SEL if the
                                       user hit the ESC key

    Remarks:
*/
double getfloat(prompt,min,max)
char * prompt;
double min;
double max;
{
    unsigned short invalid;
    double answ;
    char floatbuf[80];

    do
    {
        invalid = FALSE;

        printf("\n\r%s ",prompt);
        answ = atof(getfloatstring(floatbuf));
        if (answ == ESC_SEL)
            return(ESC_SEL);
        if ((answ < min) || (answ > max))
        {
            invalid = TRUE;
            printf("\n\r** ERROR ** illegal entry, please try again\n\r");
        }
    }
    while(invalid);

    return(answ);
}


/*
    hitkeycontinue      - Hit Key to Continue

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            The User is prompted to hit any key and when a key
                        is hit control is returned to the calling routine.
*/
void hitkeycontinue()
{

    printf("\n\r....Hit Any Key to Continue\n\r");
    fflush(stdout);
    while (!ckkbhit());
    clearkey();
}

/*
    initconsole         - Initialize the Console

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       TRUE if initialized, else FALSE

    Remarks:            Routine only has an effect in non-UNIX environments

*/
int initconsole()
{
#ifdef UNIX
#ifdef UNIX_SGTTY
    /*
        Get the old terminal config and store it
    */
    if (ioctl(fileno(stdin),TIOCGETP,&oldstdin_sgttyb) >= 0)
    {
        /*
            Set the terminal to RAW mode (no ECHO and no CHR translation)
        */
        stdin_sgttyb.sg_flags = RAW;
        if (ioctl(fileno(stdin),TIOCSETP,&stdin_sgttyb) >= 0)
            return(TRUE);
    }
#endif
#ifdef UNIX_TERMIO
    /*
        Get the old terminal config and store it
    */
    if (ioctl(fileno(stdin),TCGETA,&oldstdin_termio) >= 0)
    {
        /*
            Set the terminal to RAW mode (no ECHO and no CHR translation)
        */
        stdin_termio.c_iflag = XOFF;
        stdin_termio.c_oflag = 0;
        stdin_termio.c_cflag = oldstdin_termio.c_cflag;
        stdin_termio.c_lflag = 0;
        stdin_termio.c_cc[VMIN] = 1;
        stdin_termio.c_cc[VTIME] = 2;
        if (ioctl(fileno(stdin),TCSETA,&stdin_termio) >= 0)
            return(TRUE);
    }
#endif

    printf("** ERROR ** could not set the Terminal to RAW mode\n\r");
    hitkeycontinue();

    /*
        Return indicating that the Terminal is NOT Configured
    */
    return(FALSE);

#else
    return(TRUE);
#endif

}


/*
    restoreconsole      - Restore the Console to its initial state

    Prototype in:       menu.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:            Routine only has an effect in non-UNIX environments

*/
void restoreconsole()
{
#ifdef UNIX_SGTTY
    /*
        Restore the old terminal configuration
    */
    ioctl(fileno(stdin),TIOCSETP,&oldstdin_sgttyb);
    printf("\n\r");
#endif

#ifdef UNIX_TERMIO
    /*
        Restore the old terminal configuration
    */
    ioctl(fileno(stdin),TCSETA,&oldstdin_termio);
    printf("\n\r");
#endif
}



/*
    getfilename         Get a Filename from the User

    Prototype in:       menu.h

    Parameters Passed:  char * filenamebuf - pointer to the file name buffer

    Return Value:       char * filenamebuf if OK
                        NULL otherwise

    Remarks:

*/
char * getfilename(filenamebuf)
char * filenamebuf;
{
    char chr;
    char tempfilenamebuf[80];
    char * tempfilenamebufptr = tempfilenamebuf;

    strcpy (tempfilenamebuf,filenamebuf);

    printf("\n\r\n\rCurrent data file name is <%s>\n\r",tempfilenamebuf);
    printf("\n\rEnter the New Filename with PATH: ");

    /*
        Get a string from the console
    */
    while (TRUE)
    {
        fflush(stdout);
        chr = getkey();

        /*
            Escape
        */
        if (chr == ESC)
            return(filenamebuf);                   /* return with escape selected */

        /*
            Backspace
        */
        if (chr == BS)
        {
            if (tempfilenamebufptr > tempfilenamebuf)       /* characters to runover? */
            {
                putchar(BS);                      /* backspace */
                putchar(SP);                      /* put up a space */
                putchar(BS);                      /* backspace again */
                *--tempfilenamebufptr = 0;               /* clear previous character */
                continue;
            }
            else
            {
                putchar(BEL);
                continue;
            }
        }

        /*
            Carrage Return
        */
        if (chr == CR)
        {
            *tempfilenamebufptr = 0;             /* terminate string */
            if (strlen(tempfilenamebuf) == 0)    /* if they CR on nothing */
            {
                putchar(BEL);                    /* beepem */
                continue;                        /* ...just continue */
            }
            putchar(chr);                        /* echo the carriage ret */
            putchar(LF);                         /* send a line feed */
            break;
        }

        /*
            Numbers
        */
        putchar(chr);                         /* echo character */
        *tempfilenamebufptr++ = chr;               /* store character */
        continue;
    }

    /*
        Copy the Temp to the original
    */
    strcpy (filenamebuf,tempfilenamebuf);

    return(filenamebuf);
}