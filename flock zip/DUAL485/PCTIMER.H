/*
    pctimer.h      PC Timer Header File

    Modification History

    9/15/93   jf    created

*/

#define PCTIMER_INTERRUPT IRQ0_VEC   /* IRQ0 on a PCAT/compatible */
#define PCTIMER_CTLREG 0x43     /* Programmable Timer Control Reg */
#define PCTIMER_TIMER0 0x40     /* Programmable Timer 0 Reg */

/*
    Interrupt Controller (8259) Definitions
*/
#define INT_CNTRL_OCW1 0x21       /* operational control addresses */
#define INT_CNTRL_OCW2 0x20
#define INT_CNTRL_OCW3 0x20
#define INT_MSK_REG INT_CNTRL_OCW1  /* mask register address */
#define INT_EOI 0x20               /* end of interrupt command */
#define INT_RD_IRR 0x0a             /* read Interrupt request register */
#define INT_RD_ISR 0x0b             /* read Interrupt service register */

extern unsigned long numirqticks;
extern unsigned char irq0_flg;
extern unsigned char pctimerstored_flg;

#define GETTICKS numirqticks

/*
    Prototypes
*/
short pctimer_init(short millisecs);
void pctimer_restore(void);
void interrupt far pctimer_irq0(void);
