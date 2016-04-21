/*
    dual485.h      dual RS-485 Header File

    Modification History

    9/15/93   jf    created
    3/15/94   sw    Add 4 byte header to systemconfigstruct for file output

*/

#include "xms.h"

#define TEXTMODE 0
#define GRAPHICSMODE 1

/*
    Define a structure for each group of bird devices
*/
#define MAXNUMGROUPS 4
#define MAXNUMADDR 30
struct groupconfigstruct
{
    unsigned char active;
    unsigned char addrlist[MAXNUMADDR];
    unsigned char comport;
    unsigned char pc_irq;
};

/*
    Define a structure for multiple group systems
*/
struct systemconfigstruct
{
    unsigned char leader[4];    /* 4 bytes hearder prefix */
    long datafileversion;
    unsigned char datastore_flg;
    long filedatasize;
    char datafile[81];
    char usernote[81];
    struct date datecreated;
    struct time timecreated;
    long test_msec;
    unsigned short tick_msec;
    unsigned char flocksize;
    unsigned char numgroups;
    unsigned char datamode;
    unsigned char recsize;
    unsigned char masteraddr;
    unsigned char transmitteraddr;
    unsigned char transmitternum;
    unsigned char filteronoff;
    struct groupconfigstruct groupconfig[MAXNUMGROUPS];
    /* extra header values used in program */
    unsigned char rs232upload_flg;
    unsigned char rs232header_flg;
};

/*
    Globals
*/
extern unsigned char exit_flg;
extern struct systemconfigstruct systemconfig;


/*
    Prototypes
*/
void getsysconfig(void);
void showsysconfig(void);
short runtest(void);
short pctimer_init(short millisecs);
void pctimer_restore(void);
void interrupt far pctimer_irq0(void);
short getusercmd(void);
void exit_cleanup(void);
short updatedatafile(short datafilehandle, LPTR xmsstrtptr,
                     long xmsdatasize);
unsigned char cktestmemavail(void);
unsigned char getnumdevices(struct systemconfigstruct * configptr);
unsigned char review_datafile(unsigned char mode);
unsigned char viewdata(unsigned char * dosdataptr, unsigned char datamode,short displaymode, float *distance);
unsigned char graphdata(unsigned char * dosdataptr, unsigned char datamode);
int printpos(short * birddata,short buttonmode,short displaymode, float *distance);
int printangles(short * birddata,short buttonmode,short displaymode, float *distance);
int printmatrix(short * birddata,short buttonmode,short displaymode, float *distance);
int printquaternions(short * birddata,short buttonmode,short displaymode, float *distance);
int printposangles(short * birddata,short buttonmode,short displaymode, float *distance);
int printposmatrix(short * birddata,short buttonmode,short displaymode, float *distance);
int printposquaternions(short * birddata,short buttonmode,short displaymode, float *distance);
