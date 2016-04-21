/*
    isabus.h      -   ISAbus header
    All definitions are done with ifdefs
    #ifdef KNR
       to compile with standart C compilers
    #else
       to compile with Boland Turbo C/C++, Microsoft C
    #endif


    Modification History
4/27/95  vk..created
10/5/95  vk..definitions added for TXTIMEOUTINSECS, TXTIMEOUT constants
1/9/96   vk..ISA_BASE_ADDR_DEFAULT definition added
*/

/*
 Misc
*/
#define ISA_BASE_ADDR_DEFAULT     0x304 /* default base address = 304hex */
#define RXSTATISTICSTIMEOUTINSECS 20    /* approximately 20 seconds */
#define RXTIMEOUTINSECS 4               /* approximately 4 seconds */
#define TXTIMEOUTINSECS 4               /* approximately 4 seconds */
#define ISA_BASE_MASK 0xFC03            /* ISA BUS base address mask */
#define ISAOKTOWRITE   1                /* it's OK to send from HOST through
                                           ISA when BIT0 of status word is set
                                         */
#define ISAOKTOREAD    2                /* it's OK for HOST to read from
                                           ISA when BIT1 of status word is set
                                         */


/*
    Isa Bus Return Values
*/
#define NODATAAVAIL     -1
#define RXERRORS        -2
#define RXTIMEOUT       -3
#define TXTIMEOUT       -4
#define RXPHASEERROR    -7


/*
    External Global Definition
*/
extern short phaseerror_count;       /* holds the phase errors */

/*
    Prototypes
*/

#ifndef ISABUS
#define ISABUS

#ifdef KNR
/*
    Prototypes
*/
int isa_init();
int send_isa_cmd();
int send_isa_word();
int read_isa_status();
long waitforword();
long get_isa_word();
int get_isa_record();
void reset_through_isa();
int wait_tosend_word();

#else

int isa_init(void);
int send_isa_cmd(unsigned char * cmd, short cmdsize);
int send_isa_word(unsigned short word);
int read_isa_status(void);
long waitforword(void);
long get_isa_word(void);
int get_isa_record(short * rxbuf, short recsize, short outputmode);
void reset_through_isa(void);
int wait_tosend_word(unsigned short word);
#endif

#endif /* ISABUS */
