/****************************************************************************
*****************************************************************************

    xms.c           Extended Memory Interface Routines

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879

    written by:     Jeff Finkelstein

    Modification History:
       9-15-93   jf      created from the DOS 6 Users Guide by Al Williams
                         M&T Books, 1993
       11/8/93   jf      commented

*****************************************************************************
****************************************************************************/
#include <dos.h>
#include "xms.h"

/*
    XMS handle
*/
static int handle=0;

/*
    externals from CALLXMS.ASM
*/
extern long xms_addr;
extern int xms_init(void);
extern void xms_call(union REGS *r);
extern int xms_copy(int handle1,LPTR off1,int handle2,
          LPTR off2,unsigned long len);

/*
    xms_size            Determine the Size of XMS Memory

    Prototype in:       xms.h

    Parameters Passed:  void

    Return Value:       unsigned int the size of XMS memory

    Remarks:

*/
unsigned int xms_size()
{
    union REGS r;
    if (!xms_addr)
        xms_init();
    r.h.ah=8;
    xms_call(&r);
    return r.x.dx;
}


/*
    xms_alloc           Allocate XMS Memory

    Prototype in:       xms.h

    Parameters Passed:  unsigned size - size of the XMS memory to alloc

    Return Value:       LPTR 100000L to the new block if sucessful
                        LPTR -1L if unsucessfull
    Remarks:

*/
LPTR xms_alloc(unsigned size)
{
    union REGS r;
    if (!xms_addr)
        xms_init();
    if (handle)
        xms_free(1);
    r.h.ah=9;
    r.x.dx=size;
    xms_call(&r);
    if (!r.x.ax)
        return (LPTR)-1L;
    handle=r.x.dx;
    return (LPTR)0x100000L;
}

/*
    xms_realloc         Resize the XMS Block

    Prototype in:       xms.h

    Parameters Passed:  unsigned size - size of the XMS block

    Return Value:       LPTR 100000L to the new block if sucessful
                        LPTR -1L if unsucessfull

    Remarks:

*/
LPTR xms_realloc(unsigned size)
{
    union REGS r;
    if (!xms_addr)
        xms_init();
    if (!handle)
        return xms_alloc(size);
    r.h.ah=0xf;
    r.x.bx=size;
    r.x.dx=handle;
    xms_call(&r);
    if (!r.x.ax)
        return (LPTR)-1L;
    return (LPTR)0x100000L;
}

/*
    xms_free            Free the XMS Memory

    Prototype in:       xms.h

    Parameters Passed:  int exitflag

    Return Value:       int 0

    Remarks:

*/
int xms_free(int exitflag)
{
    union REGS r;
    if (!xms_addr)
        xms_init();
    if (handle)
    {
        r.x.dx=handle;
        r.h.ah=0xa;
        xms_call(&r);
        handle=0;
    }
    return 0;
}


/*
    xms_memcpy          Move XMS memory around

    Prototype in:       xms.h

    Parameters Passed:  LPTR dst - destination address
                        LPTR src - source address
                        unsigned wc - byte count

    Return Value:       int 0 if Success
                        int -1 if Error

    Remarks:

*/
int xms_memcpy(LPTR dst,LPTR src,unsigned wc)
{
    int h1,h2;

    if (!xms_addr)
        xms_init();
    if (dst<0x100000)
    {
        h1=0;
        dst=((dst>>4)<<16)+(dst&0xF);
    }
    else
    {
        h1=handle;
        dst-=0x100000;
    }
    if (src<0x100000)
    {
        h2=0;
        src=((src>>4)<<16)+(src&0xF);
    }
    else
    {
        h2=handle;
        src-=0x100000;
    }
    return xms_copy(h1,dst,h2,src,wc);
}

