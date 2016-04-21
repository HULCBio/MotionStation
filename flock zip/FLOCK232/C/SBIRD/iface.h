/*
    iface.h         -   Bird Main

    Modification History
1/10/96    vk..created

*/

/*
 Misc
*/
#define ISA_BUS TRUE                    /* ISA Bus interface */
#define RS232 !ISA_BUS                  /* RS232 interface */

/*
External Global variables
*/
extern unsigned short isa_base_addr;

#ifndef IFACE
#define IFACE

/*
    Prototypes
*/
#ifdef KNR

int interfaceinit();
int send_cmd();
int readbirddata();
int waitfordata();

#else

int interfaceinit(void);
int send_cmd(unsigned char * cmd, short cmdsize);
int readbirddata(short * birddata,short numwords,short outputmode,short buttonmode);
int waitfordata(void);

#endif

#endif /* IFACE */
