/*
    birdcmds.h      - Bird Commands

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

*/

#ifndef BIRDCMDS
#define BIRDCMDS

/*
   Publics
*/
extern float posk;
extern unsigned char fbbgroupdataflg;

#ifdef KNR
/*
    Prototypes
*/
int getsinglebirddata();
int bird_anglealign();
int bird_hemisphere();
int bird_referframe();
int bird_reportrate();
int bird_sleepwake();
int bird_mousebuttons();
int bird_xonxoff();
int bird_examinevalue();
int bird_changevalue();
int bird_crtsync();
void showfbbconfig();
void displayflocksys();
int getsamples();
void clearbuff();
void getbirdstatistics(void);

#else

int getsinglebirddata(short outputmode, unsigned char datamode,
		      unsigned char displayon, short buttonmode);
int bird_anglealign(void);
int bird_hemisphere(void);
int bird_referframe(void);
int bird_reportrate(void);
int bird_sleepwake(void);
int bird_mousebuttons(void);
int bird_xonxoff(void);
int bird_examinevalue(void);
int bird_changevalue(void);
int bird_crtsync(void);
void showfbbconfig(unsigned char * fbbconfig);
void displayflocksys(unsigned char * fbbsystemstatus);
int getsamples(int samplesize, double mean[], double stddev[], double pk_pk[], double maximum[], double minimum[]);
void clearbuff(void);
void getbirdstatistics(void);
#endif

#endif /* BIRDCMDS */



