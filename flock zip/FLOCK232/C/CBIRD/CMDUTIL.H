/*
	cmdutil.h               - BIRD Command Utility Header

    Modification History
		4/29/91         jf - created from BIRDCMDS.h
	9/16/91     jf - added showfbbconfig prototype
	2/25/92     jf - removed showfbbconfig prototype
	4/7/92      jf - added fprintmatrix
	4/20/92     mo - added fprintquaternions()
	1/26/93     jf - fixed up for new release
	2/24/93     jf - added getaddrmode()
	10/20/93    jf - added CMDUTIL definition

*/

#ifndef CMDUTIL
#define CMDUTIL

#ifdef KNR
/*
    Prototypes
*/
int readbirddata();
int dumpbirdarray();
int check_done();
int checkerrorstatus();
int displaybirddata();
void displayerror();
int printarray();
int getangles();
int getaddrmode();
int getcrystalfreq();
int getsystemstatus();
int printposition();
int printangles();
int printmatrix();
int printquaternions();
int printposmatrix();
int printposangles();
int printposquaternions();


#else

int readbirddata(short * birddata,short numwords,short outputmode,short buttonmode);
int dumpbirdarray(unsigned short address,unsigned char * array);
int check_done(short outputmode);
int checkerrorstatus(unsigned char displayon);
int displaybirddata(short * birddata, unsigned char datamode,
		    short buttonmode, unsigned char displayon,
		    unsigned char displayaddr, FILE * datafilestream);
void displayerror(unsigned char errnum,unsigned char exterrnum,
		  unsigned char dispexpandedinfo);
int printarray(char * dataarray,short size);
int getangles(char * promptstrg,float * angle);
int getaddrmode(void);
int getcrystalfreq(void);
int getsystemstatus(void);
int printposition(short * birddata,short buttonmode,
		  unsigned char displayon,FILE * datafilestream);
int printangles(short * birddata,short buttonmode,
		unsigned char displayon,FILE * datafilestream);
int printmatrix(short * birddata,short buttonmode,
		unsigned char displayon,FILE * datafilestream);
int printquaternions(short * birddata,short buttonmode,
		     unsigned char displayon,FILE * datafilestream);
int printposmatrix(short * birddata,short buttonmode,
		   unsigned char displayon,FILE * datafilestream);
int printposangles(short * birddata,short buttonmode,
		   unsigned char displayon,FILE * datafilestream);
int printposquaternions(short * birddata,short buttonmode,
			unsigned char displayon,FILE * datafilestream);

#endif

#endif /* CMDUTIL */



