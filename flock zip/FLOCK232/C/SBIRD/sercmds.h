/*
    sercmds.h       - Bird Serial Commands

    Modification History
	10/18/90    jf  - created
		2/4/91      jf  - added buttonvalue parameter to printmatrix
		4/23/91         jf      - added KNR prototypes
		4/28/91         jf  - renamed bird_positionand.. to bird_posand..
	4/7/92      jf  - added extern for posk
	4/20/92     mo  - added new functions bird_quaternions(),
			  bird_posquaternions() and printquaternions().
	11/3/92     jf  - added showfbbconfig proto
	10/20/93    jf  - added BIRDCMDS definition
1/10/96  vk..nextmastercmd(),nextxmtrcmd() declarations moved to here
         form birdmain.h
         - file renamed from "birdcmds.h" to "sercmds.h"
*/

/* Miscelaneous definitions */
#define ILLEGAL_PARAMETER_VALUE (-1)    /* return value if user specifies
                                          illegal value for the parameter
                                        */
#ifndef SERCMDS
#define SERCMDS

/*
   Publics
*/
extern float posk;
extern unsigned char fbbgroupdataflg;

#ifdef KNR
/*
    Prototypes
*/
//int bird_anglealign_serial();
int bird_hemisphere_serial();
//int bird_referframe_serial();
//int bird_reportrate_serial();
int bird_sleep_serial();
int bird_wakeup_serial();
//int bird_buttonmode_serial();
int bird_buttonread_serial();
int bird_xonxoff_serial();
int bird_changevalue_serial();
int bird_examinevalue();
int bird_examinevalue_serial();
int bird_crtsync_serial();
int bird_nextmaster_serial();
int bird_nextxmtr_serial();

#else

int bird_anglealign_serial(float azim, float elev, float roll);
int bird_hemisphere_serial(int hemisphere);
int bird_referframe_serial(float azim, float elev, float roll);
int bird_reportrate_serial(unsigned char rate_cdata);
int bird_sleep_serial(void);
int bird_wakeup_serial(void);
int bird_buttonmode_serial(short buttonmode);
int bird_buttonread_serial(void);
int bird_xonxoff_serial(unsigned char birdflowcmd);
int bird_changevalue_serial(int parameter_number, unsigned char * parameter_data_ptr);
int bird_examinevalue_serial(int parameter_number,unsigned char * examine_value_data_ptr);
int bird_crtsync_serial(unsigned char birdcrtsyncmode, unsigned char * birdcrtsyncdata);
int bird_nextmaster_serial(int nextmaster);
int bird_nextxmtr_serial(int nextxmtraddr, int nextxmtrnum);
#endif

#endif /* SERCMDS */
