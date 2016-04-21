/***************************************************************
 *                                                             *
 * File: XMS.H                                                 *
 *                                                             *
 * Description:                                                *
 *                                                             *
 * Header file for CXMS.c.  CEXT manages allocation and        *
 * access of extended memory.                                  *
 *                                                             *
 ***************************************************************/


typedef unsigned long LPTR;


/* convert segmented address to linear address */
#define SEG_TO_LINEAR(fp)(((LPTR) FP_SEG(fp)<<4)+FP_OFF(fp))


unsigned int xms_size(void);
LPTR xms_alloc(unsigned size);
LPTR xms_realloc(unsigned size);
int xms_free(int exitflag);
int xms_memcpy(LPTR dst,LPTR src,unsigned int wc);
