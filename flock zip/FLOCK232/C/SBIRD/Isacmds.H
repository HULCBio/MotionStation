/*
    isacmds.h      - Bird ISA Commands
    All definitions are done with ifdefs
    #ifdef KNR
       to compile with standart C compilers
    #else
       to compile with Boland Turbo C/C++, Microsoft C
    #endif


    Modification History
1/10/96  vk..created
*/

/* Miscelaneous definitions */
#define ILLEGAL_PARAMETER_VALUE (-1)    /* return value if user specifies
                                          illegal value for the parameter
                                        */

#ifndef ISACMDS
#define ISACMDS
extern unsigned short isa_base_addr;
extern short rs232tofbbaddr;         /* RS232 to FBB address */
#ifdef KNR
/*
    Prototypes
*/
int bird_anglealign_isa();
int bird_hemisphere_isa();
int bird_referframe_isa();
int bird_reportrate_isa();
int bird_sleep_isa();
int bird_wakeup_isa();
int bird_buttonmode_isa();
int bird_buttonread_isa();
int bird_xonxoff_isa();
int bird_changevalue_isa();
int bird_examinevalue_isa();
int bird_crtsync_isa();
int bird_nextmaster_isa();
int bird_nextxmtr_isa();
void bird_clearoutputbuffer_isa();

#else

int bird_anglealign_isa(float azim, float elev, float roll);
int bird_hemisphere_isa(int hemisphere);
int bird_referframe_isa(float azim, float elev, float roll);
int bird_reportrate_isa(unsigned char rate_cdata);
int bird_sleep_isa(void);
int bird_wakeup_isa(void);
int bird_buttonmode_isa(short buttonmode);
int bird_buttonread_isa(void);
int bird_xonxoff_isa(unsigned char birdflowcmd);
int bird_changevalue_isa(int parameter_number, unsigned char * parameter_data_ptr);
int bird_examinevalue_isa(int parameter_number,unsigned char * examine_value_data_ptr);
int bird_crtsync_isa(unsigned char birdcrtsyncmode, unsigned char * birdcrtsyncdata);
int bird_nextmaster_isa(int nextmaster);
int bird_nextxmtr_isa(int nextxmtraddr, int nextxmtrnum);
void bird_clearoutputbuffer_isa(void);

#endif

#endif /* SPADCMDS */
