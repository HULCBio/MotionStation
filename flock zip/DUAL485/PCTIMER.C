
/****************************************************************************
*****************************************************************************

    pctimer.c       PC Timer Routines

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:
       9-15-93   jf      created

       <<<< Copyright 1991,92,93 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/
#include <stdio.h>          /* general I/O */
#include <stdlib.h>         /* for exit() */
#include "asctech.h"        /* Ascension Technology definitions */
#include "compiler.h"       /* Compiler Specific Header */
#include "menu.h"           /* Ascension Technology Menu Routines */
#include "dual485.h"
#include "pcpic.h"
#include "pctimer.h"

unsigned long numirqticks;      /* number of Ticks that occurred */
unsigned short numirqclocks;    /* number of clocks per IRQ0 Tick */
unsigned char pctimerstored_flg = FALSE;
extern unsigned char irq0_flg = 0;

void (interrupt far * oldpcirq0_intvect)();  /* old PC IRQ0 interrupt vector */

/*
    Local Prototypes
*/
int new_ctrlbrk(void);

/*
    pctimer_init        Init the PC Timer

    Prototype in:       pctimer.h

    Parameters Passed:  short millisecs - number of milliseconds for the
                                          timer value

    Return Value:       void

    Remarks:

*/
short pctimer_init(millisecs)
short millisecs;
{
    DISABLE();

    /*
        Setup the new IRQ0 vector
    */
    oldpcirq0_intvect = GETVECT(PCTIMER_INTERRUPT);
    SETVECT(PCTIMER_INTERRUPT,pctimer_irq0);

    /*
        Setup Control Break to point to this routine
    */
    setcbrk(1); /* check on all DOS calls*/
    ctrlbrk(new_ctrlbrk);


    /*
        Setup the new time
    */
    numirqclocks = 1190 * millisecs;       /* number of 1.19 MHz clock ticks */
    OUTPORTB(PCTIMER_CTLREG, 0x36);
    OUTPORTB(PCTIMER_TIMER0, numirqclocks & 0xff);             /* LSB */
    OUTPORTB(PCTIMER_TIMER0, (numirqclocks & 0xff00) >> 8);    /* MSB */

    /*
        Zero the counter for the number of Timer Interrupts
    */
    numirqticks = 0;

    pctimerstored_flg = TRUE;

    ENABLE();
    return(TRUE);
}

/*
    pctimer_restore     Restore the PC TIMER to its original State

    Prototype in:       pctimer.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
void pctimer_restore()
{
    unsigned long numdosticks;

    DISABLE();

    SETVECT(PCTIMER_INTERRUPT,oldpcirq0_intvect);

    /*
        Disable the Timer
    */
    OUTPORTB(PCTIMER_CTLREG, 0x38); /* mode 4 (software trigger w/o trigger),
                                       counter 0 */

    /*
        Update the DOS Clock
    */
    numdosticks = ((long)numirqclocks * (long) numirqticks)/65536;
    while (numdosticks--);
        asm int 0x8  /* IRQ0 interrupt number */


    /*
        Restore the time for 18.2 ticks/sec via a Timer Square Wave
    */
    OUTPORTB(PCTIMER_CTLREG, 0x36);  /* mode 3, counter 0 */
    OUTPORTB(PCTIMER_TIMER0, 0);
    OUTPORTB(PCTIMER_TIMER0, 0);

    pctimerstored_flg = FALSE;
    ENABLE();
}


/*
    new_ctrlbrk         Control break handler

    Prototype in:       pctimer.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
int new_ctrlbrk()
{
    pctimer_restore();
    exit_cleanup();
    printf("\n\r** USER CONTROL BREAK **\n\r");
    return(0); /* ABORT */
}

/*
    pctimer_irq0        Interrupt Routine for the PC Timer

    Prototype in:       pctimer.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
extern long dataavailsize;
void interrupt far pctimer_irq0()
{

    numirqticks++;

    ++irq0_flg;

    dataavailsize += 200L;

    /*
        Send End of Interrupt Command to the 8259
    */
    OUTPORTB(INT_CNTRL_OCW2,INT_EOI);
    return;
}

