/*
    birdmain.h      -   Bird Main

    Modification History
		10/18/90    jf  -   created
		4/23/91         jf      - added KNR prototypes
	7/19/91     jf  - add operate menu and config menu
	12/22/91    jf  - updated prototypes
	10/20/93    jf  - added BIRDMAIN definition
	1/5/94      sw  - added alltests definition
1/9/96   vk..interfaceinit declaration added
1/10/96  vk..nextmastercmd(),nextxmtrcmd() declarations moved from here
	 to birdcmds.h
*/

#ifndef BIRDMAIN
#define BIRDMAIN

#ifdef KNR
/*
    Prototypes
*/
int main();
int get_output_mode();
int serialinit();
int alltests();
int systests();
int hostechotest();
int hostreadtest();
int hostreadblocktest();
int setxmtrtype();
int birdoutputtest();
int birdechotest();
int getbirddata();
int displistinit();
int interfaceinit();
#else

int main(void);
int get_output_mode(void);
int serialinit(void);
int alltests(void);
int systests(void);
int hostechotest(void);
int hostreadtest(void);
int hostreadblocktest(void);
int setxmtrtype(void);
int birdoutputtest(void);
int birdechotest(void);
int getbirddata(unsigned char datamode, short buttonmode);
int displistinit(void);
int interfaceinit(void);

#endif
extern short little_endian;
#endif /* BIRDMAIN */
