/*
    sercmds.h       - Bird Commands

    Modification History
1/10/96  vk..old file renamed to "sercmds.h" beause serial interface
           was assumed.
         - the new file asuming either ISA or serial interface released.
*/

extern short interface;

#ifndef BIRDCMDS
#define BIRDCMDS


#ifdef KNR
/*
    Prototypes
*/
int 		getsinglebirddata	();
int 		bird_anglealign		();
int 		bird_hemisphere		();
int 		bird_referframe		();
int 		bird_reportrate		();
int 		bird_sleepwake		();
int 		bird_mousebuttons	();
int 		bird_xonxoff		();
int 		bird_examinevalue	();
int 		bird_changevalue	();
int 		bird_crtsync		();
int 		nextxmtrcmd			();
int 		nextmastercmd		();
void		showfbbconfig		();
void		displayflocksys		();
int 		getsamples			();
void		clearbuff			();
void		getbirdstatistics	();  
void 		fbb_reset			();
void		z_commands			();

#else

int 		getsinglebirddata	(short outputmode, unsigned char datamode,
		      						unsigned char displayon, short buttonmode);
int 		bird_anglealign		(void);
int 		bird_hemisphere		(void);
int 		bird_referframe		(void);
int 		bird_reportrate		(void);
int 		bird_sleepwake		(void);
int 		bird_mousebuttons	(void);
int 		bird_xonxoff		(void);
int 		bird_examinevalue	(void);
int 		bird_changevalue	(void);
int 		bird_crtsync		(void);
int 		nextxmtrcmd			(void);
int 		nextmastercmd		(void);
void 		showfbbconfig		(unsigned char * fbbconfig);
void 		displayflocksys		(unsigned char * fbbsystemstatus);
int 		getsamples			(int samplesize, double mean[], double stddev[], 
									double pk_pk[], double maximum[], double minimum[]);
void		clearbuff			(void);
void		getbirdstatistics	(void);
void 		fbb_reset			(void);
void		z_commands			(void);
#endif

#endif /* BIRDCMDS */



