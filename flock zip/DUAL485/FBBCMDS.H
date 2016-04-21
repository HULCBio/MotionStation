/*
    fbbcmds.h       FBB Commands Header File

    Modification History

    9-20-93      jf     created
*/


/*
    Prototype
*/
short fbbconfig(void);
short sendfbbdatacmd(unsigned char fbbaddr, unsigned char comport);
short sendfbboutmodecmd(unsigned char fbbaddr, unsigned char comport, unsigned char mode);
short sendfbbfiltercmd(unsigned char fbbaddr, unsigned char comport, unsigned char filteronoff);
short getfbbdata(unsigned char fbbaddr, unsigned char comport,
                 unsigned char * rxbufptr,unsigned char recsize);

