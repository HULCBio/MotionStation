/*
    ser_gen.h        Serial Include File for Generic Serial Routine

    Modification History

        9/16/93     jf  - created from serial.h
        12/30/93    jf  - updated to allow the Use of an RS232 Port
*/


/*
    Misc
*/
#define NUMCOMPORTS     4
#define RXTIMEOUTINSECS 1       /* Receive Timeout Period in seconds */

/*
    Serial Port Types
*/
#define RS232_PORT      1
#define RS485_PORT      2

/*
    Serial (8250) Port Base Addresses on PC compatibles
    DEFAULTS...modify if you switch Quatech addresses
*/
#define COM1BASE 0x3f8          /* base address of COM1 on PC/PCAT */
#define COM2BASE 0x2f8          /* base address of COM2 on PC/PCAT */
#define COM3BASE 0x3e8          /* base address of COM3 on PC/PCAT */
#define COM4BASE 0x2e8          /* base address of COM4 on PC/PCAT */


/*
    RX and TX buffers
*/
#define RXBUFSIZE 0x200         /* size of RX circular buffer */
#define TXBUFSIZE 0x400         /* size of TX buffer */

/*
    Labels for the Com Ports
*/
#define COM1 0                      /* com port 1 */
#define COM2 1                      /* com port 2 */
#define COM3 2                      /* com port 3 */
#define COM4 3                      /* com port 4 */

/*
    Serial Port Control Register offsets from com_base address
*/
#define MODEMSTATUS     6           /* modem status register */
#define LINESTATUS      5           /* line status register */
#define MODEMCONT       4           /* modem control register */
#define LINECONT        3           /* line control register */
#define INTERIDENT      2           /* Interupt Identification register */
#define FCR             2           /* FIFO Control Register */
#define INTERENABLE     1           /* interrupt register */
#define DIVISORHIGH     1           /* baud rate divisor reg high */
#define DIVISORLOW      0           /* baud rate divisor reg low */
#define TXBUF           0           /* transmit register */
#define RXBUF           0           /* receive register */

/*
    Serial Port Bit Specifics
*/
#define DLAB        0x80            /* bit 7 of Line Control Reg, DLAB  */
#define DATARDY     0x01            /* bit 0 of Line Status Reg, DR */
#define FIFORCVERR  0x80            /* bit 7 of the Line Status Reg */
#define TXHOLDEMPTY 0x20            /* bit 5 of Line Status Reg, THRE */
#define TXSHIFTEMPTY 0x40           /* bit 6 of Line Status Reg, TEMT */
#define DTRON       0x01            /* bit 0 of Modem Control Reg, DTR */
#define RTSON       0x02            /* bit 1 of Modem Control Reg, RTS */
#define OUT2        0x08            /* bit 3 of Modem Control Reg, OUT2 */
#define RXERRORMSK  0x0e            /* Rx Error Mask, bits 1,2,3 on */

/*
    UART Interrupt Enable Register
*/
#define RXDATAAVAILINTENABLE    0x01
#define TXHOLDINTENABLE         0x02
#define RXLINESTATUSINTENABLE   0x04
#define MODEMSTATUSINTENABLE    0x08

/*
    Serial Port Return Values
*/
#define NODATAAVAIL     -1
#define RXERRORS        -2
#define RXTIMEOUT       -3
#define RXBUFOVERRUN    -4
#define TXBUFOVERRUN    -5
#define TXNOTEMPTY      -6
#define RXPHASEERROR    -7
#define TXBUFFERFULL    -8

/*
    UART Identification Register definition
    ....lsb = 0 implies interrupt pending = TRUE
*/
#define FIFORECV        0x0c
#define RXLINESTATUS    0x06
#define RXDATAAVAIL     0x04
#define TXEMPTY         0x02
#define MODEMSTATUSCHG  0x00

/*
    Serial Port Configuration Constants
*/
#define STOP_WORDLEN_PARITY      0x3   /* 1 start, 8 data, 1 stop, no parity */
#define STOP_WORDLEN_SPACEPARITY 0x3b  /* 1 start, 8 data, 1 stop, SPACE parity */
#define STOP_WORDLEN_MARKPARITY  0x2b  /* 1 start, 8 data, 1 stop, MARK parity */


#define COM1IRQ         IRQ4    /* COM1 Interrupt Bit Pos */
#define COM2IRQ         IRQ3    /* COM2 Interrupt Bit Pos */
#define COM3IRQ         IRQ5    /* COM3 Interrupt Bit Pos */
#define COM4IRQ         IRQ2    /* COM4 Interrupt Bit Pos */

#define COM1INTERRUPT   IRQ4_VEC    /* vector # for COM1 */
#define COM2INTERRUPT   IRQ3_VEC    /* vector # for COM2 */
#define COM3INTERRUPT   IRQ5_VEC    /* vector # for COM3 */
#define COM4INTERRUPT   IRQ2_VEC    /* vector # for COM4 */

#define DISABLESERIALMSK (COM1IRQ + COM2IRQ) /* MSK to disable serial Interrupts on 8259 */

/*
    External Global Definition
*/
extern short phaseerror_count[NUMCOMPORTS];   /* holds the phase errors */
extern short rxerrors[NUMCOMPORTS];           /* holds the rx line errors */
extern short serialconfigsaved[NUMCOMPORTS];  /* indicates config saved */
extern long baud;                    /* holds the current baud rate */
extern short baudspeedbits;          /* holds the baud speed in bits */
extern short baudspeedbittable[];    /* the baud speed in bit table */
extern short comport;                /* holds the comport # */
extern long baudratetable[];         /* holds the baud rate selections */
extern short rs232tofbbaddr;         /* RS232 to FBB address */
extern char * sys_com_port[];        /* comport names */

/*
    Prototypes
*/
void clear_rx(short comport);
int configserialport(short comport,long baud, short type);
int get_serial_char(short comport);
int get_serial_record(short comport, unsigned char * rxbuf, short recsize, short outputmode);
void restoreserialconfig(short comport);
int saveserialconfig(short comport);
int send_serial_cmd(short comport, unsigned char * cmd, short cmdsize);
int send_serial_cmdchar(short comport, unsigned char chr);
int send_serial_datachar(short comport, unsigned char chr);
int waitforchar(short comport);
int waitforphase(short comport);
long getticks(void);



