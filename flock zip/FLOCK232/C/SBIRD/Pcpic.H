/*
    pcpic.h         PC Programmable Interrupt Controller Header

    Modification History

        9/16/93     jf  - created from serial.h
        10/20/93    jf  - added PCPIC and DOS ifdefs
*/

#ifdef DOS

#ifndef PCPIC
#define PCPIC

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

/*
    Interrupt Register (8259) definitions
*/
#define IRQ0            0x01    /* bit pos for IRQ 0 */
#define IRQ1            0x02    /* bit pos for IRQ 1 */
#define IRQ2            0x04    /* bit pos for IRQ 2 */
#define IRQ3            0x08    /* bit pos for IRQ 3 */
#define IRQ4            0x10    /* bit pos for IRQ 4 */
#define IRQ5            0x20    /* bit pos for IRQ 5 */
#define IRQ6            0x40    /* bit pos for IRQ 6 */
#define IRQ7            0x80    /* bit pos for IRQ 7 */

/*
    Interrupt Vector Numbers
*/
#define IRQ0_VEC        0x08    /* Master PIC starting Vector # */
#define IRQ1_VEC        IRQ0_VEC+1
#define IRQ2_VEC        IRQ0_VEC+2
#define IRQ3_VEC        IRQ0_VEC+3
#define IRQ4_VEC        IRQ0_VEC+4
#define IRQ5_VEC        IRQ0_VEC+5
#define IRQ6_VEC        IRQ0_VEC+6
#define IRQ7_VEC        IRQ0_VEC+7


extern unsigned char oldirqmsk;

#define PCPIC_MASK(maskval) OUTPORTB(INT_MSK_REG, INPORTB(INT_MSK_REG) | maskval)
#define PCPIC_UNMASK(maskval) OUTPORTB(INT_MSK_REG, INPORTB(INT_MSK_REG) & ~maskval)
#define PCPIC_SAVEMASK INPORTB(INT_MSK_REG)
#define PCPIC_RESTOREMASK(maskval) OUTPORTB(INT_MSK_REG, maskval)
#define PCPIC_OUTEOI OUTPORTB(INT_CNTRL_OCW2,INT_EOI)


#endif /* PCPIC */

#endif /* DOS */



