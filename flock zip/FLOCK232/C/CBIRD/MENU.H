/*
    menu.h  - Menu Include

    Modification History

	 10/18/90       jf  - created
	 4/23/91                jf      - added KNR prototypes
     4/24/91            jf      - added ckkbit(),clearkey(),getkey() prototypes
					jf  - added initconsole and restoreconsole prototypes
     7/21/91        jf  - added YES and NO definitions
     9/20/93        jf  - added getfilename and getfloat
     10/20/93       jf  - added MENU definition
*/

#ifndef MENU
#define MENU

#define TRUE 1
#define FALSE 0
#define YES TRUE
#define NO FALSE

/*
    Character codes
*/
#define ESC_SEL -1
#define BEL     0x07
#define BS      0x08
#define LF      0x0a
#define CR      0x0d
#define XON     0x11
#define XOFF    0x13
#define ESC     0x1b
#define SP      0x20

/*
    Prototypes
*/
#ifdef KNR

int askyesno();
void clearconsole();
void clearkey();
int ckkbhit();
int getkey();
int getnumber();
char * getfloatstring();
void hitkeycontinue();
int     initconsole();
void sendmenuhdr();
int sendmenu();
void restoreconsole();
char * getfilename();
short getushort();
double getfloat();

#else

int askyesno(char * quesstring);
void clearconsole(void);
void clearkey(void);
int ckkbhit(void);
int getkey(void);
int getnumber(void);
char * getfloatstring(char * floatstringbuf);
void hitkeycontinue(void);
int     initconsole(void);
void sendmenuhdr(char * hdrstring);
int sendmenu(char ** menuptr, short menucount);
void restoreconsole(void);
char * getfilename(char * filenamebuf);
short getushort(char * prompt, short min, short max);
double getfloat(char * prompt, double min, double max);

#endif

#endif /* MENU */


