/*
    rstofbb.h       - RS232 to FBB Command Header

    Modification History
     1/26/93  jf    - created from previous version of MULTI232
     7/7/93   jf    - updated the prototype for getmultirecords
     10/20/93 jf    - added RSTOFBB definition

*/

#ifndef RSTOFBB
#define RSTOFBB

/*
    Prototypes
*/
#ifdef KNR

int rs232tofbbcmd();
int rstofbbmenu();
int displaymultidata();
int setdatamode();
int getfbbdestaddress();
int getmultibirddata();
int getmultirecords();
int getsampletime();
int getmaxrs232tofbbrate();

#else

int rs232tofbbcmd(void);
int rstofbbmenu(void);
int displaymultidata(unsigned char datamode,short buttonmode,
                     unsigned char displayon, unsigned char startaddr,
                     unsigned char stopaddr,unsigned char * birddata,
                     FILE * datafilestream);
int setdatamode(unsigned char startaddr,unsigned char stopaddr,
                unsigned char datamode);
int getfbbdestaddress(unsigned char * startaddrptr,
                      unsigned char * stopaddrptr);
int getmultirecords(short outputmode, short buttonmode, unsigned char datamode,
                 unsigned char startaddr, unsigned char stopaddr,
                 unsigned char * recorddataptr);
int getmultibirddata(short outputmode,unsigned char datamode,
                     unsigned char displayon,short buttonmode);
int getsampletime(void);
int getmaxrs232tofbbrate(void);



#endif

#endif /* RSTOFBB */



