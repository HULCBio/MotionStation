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
#include "pcpic.h"
#include "pctimer.h"

#ifdef DOS                      /* DOS Platforms ONLY */

unsigned long numirqticks;      /* number of Ticks that occurred */
unsigned short numirqclocks;    /* number of clocks per IRQ0 Tick */
unsigned char pctimerstored_flg = FALSE;
extern unsigned char irq0_flg = 0;

#ifdef DPMC                            /* DOS Protected Mode Compiler */
    RINTTYPE oldpcirq0_intvect;        /* REAL old PC IRQ0 interrupt vector */
    INTTYPE (* oldpcirq0_pintvect)();  /* PROT old PC IRQ0 interrupt vector */
#ifdef HIGHC
    void pctimer_irq0(void);
    extern _INTERRPT void hc_pctimerisr(void);
#else
    INTTYPE pctimer_irq0(void);
#endif

#else
    INTTYPE (* oldpcirq0_intvect)();  /* old PC IRQ0 interrupt vector */
    INTTYPE pctimer_irq0(void);
#endif

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
        Get the Old IRQ0 Vector(s)
    */
    oldpcirq0_intvect = GETVECT(PCTIMER_INTERRUPT);
#ifdef DPMC
    oldpcirq0_pintvect = GETPVECT(PCTIMER_INTERRUPT);
#endif
    /*
        Setup the new IRQ0 vector
    */
#ifdef DPMC
#ifdef HIGHC
    SETRPVECT(PCTIMER_INTERRUPT,hc_pctimerisr);
#else
    SETPVECT(PCTIMER_INTERRUPT,pctimer_irq0);
#endif
#else
    SETVECT(PCTIMER_INTERRUPT,pctimer_irq0);
#endif

    /*
        Setup Control Break to point to this routine
    */
#ifdef TC
    setcbrk(1); /* check on all DOS calls*/
    ctrlbrk(new_ctrlbrk);
#endif


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
    union REGS regs;

    DISABLE();

    /*
        Disable the Timer
    */
    OUTPORTB(PCTIMER_CTLREG, 0x38); /* mode 4 (software trigger w/o trigger),
                                       counter 0 */

#ifdef DPMC
    SETPVECT(PCTIMER_INTERRUPT,oldpcirq0_pintvect);
#endif
    SETVECT(PCTIMER_INTERRUPT,oldpcirq0_intvect);

    /*
        Update the DOS Clock
    */
    numdosticks = ((unsigned long)numirqclocks * (unsigned long) numirqticks)/65536;
    while (numdosticks--)
         int86(IRQ0_VEC,&regs,&regs); /* Software Interrupt for IRQ0 */

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
    printf("\n\r** USER CONTROL BREAK **\n\r");
    return(0);
}

/*
    pctimer_irq0        Interrupt Routine for the PC Timer

    Prototype in:       pctimer.h

    Parameters Passed:  void

    Return Value:       void

    Remarks:

*/
#ifdef HIGHC
void pctimer_irq0()  /* called from the assembly code */
#else
INTTYPE pctimer_irq0()
#endif
{
    /*
        Update a Counter of the Number of Ticks
    */
    numirqticks++;

    /*
        Set/Inc the Interrupt Flag
    */
    ++irq0_flg;

    /*
        Send End of Interrupt Command to the 8259
    */
    OUTPORTB(INT_CNTRL_OCW2,INT_EOI);
    return;
}

#endif /* DOS */
