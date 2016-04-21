/*****************************************************************************
******************************************************************************
*
*               Real-Time Windows Target error codes
*
*               $Revision: 1.5 $
*               $Date: 2002/04/14 18:54:34 $
*               $Author: batserve $
*
*               Copyright 1994-2002 The MathWorks, Inc.
*
******************************************************************************
*****************************************************************************/


#define ERR_OK               0      // OK, no error
#define ERR_INVFUNCTION      1	    // Invalid function
#define ERR_FEWINARG	     2 	    // Too few input arguments
#define ERR_MANYINARG	     3	    // Too many input arguments
#define ERR_FEWOUTARG	     4	    // Too few output arguments
#define ERR_MANYOUTARG	     5	    // Too many output arguments
#define ERR_OBJDEF	     6	    // Object already defined
#define ERR_OBJNOTDEF	     7	    // Object not defined
#define ERR_INVPROPNAME      8	    // Invalid property name
#define ERR_INVPROPVALUE     9	    // Invalid property value
#define ERR_INVPROPSIZE     10	    // Invalid property size
#define ERR_INVTIMERNUM     11 	    // Invalid timer number
#define ERR_INVTIMERTYPE    12	    // Invalid timer type
#define ERR_INVTIMERPER     13	    // Invalid timer period
#define ERR_INVTF           14	    // Invalid transfer function
#define ERR_INCONSTF        15	    // Inconsistent transfer function degree
#define ERR_TIMLINKED	    16	    // Timer already linked
#define ERR_INVCHANNUM	    17	    // Invalid channel number
#define ERR_INCONSCHANNUM   18	    // Inconsistent number of channels
#define ERR_CHANLINKED	    19	    // Channel already linked
#define ERR_INVHISTNAME	    20	    // Invalid history name
#define ERR_INVHISTDIM	    21	    // Invalid history dimension
#define ERR_HISTLINKED	    22	    // History already linked
#define ERR_DRVNOTFOUND	    23	    // Driver not found
#define ERR_INVDRV	    24	    // Invalid driver
#define ERR_NOVIRTDEV	    25	    // Virtual device not loaded
#define ERR_OUTMEMORY	    26	    // Out of memory
#define ERR_TOOFAST	    27	    // Too fast for this hardware
#define ERR_PROPRDONLY	    28	    // Property is read-only
#define ERR_DIMNOTAGREE	    29	    // Variable dimensions do not agree
#define ERR_INITHW	    30	    // Error initializing hardware
#define ERR_INCORRVER	    31	    // Incorrect version
#define ERR_INVDRVPARM	    32	    // Invalid driver parameter
#define ERR_TIMEOUT	    33	    // Timeout has occured
#define ERR_SIMNOTCREAT	    34	    // SimStruct not created
#define ERR_SIMNOTINIT	    35	    // SimStruct not initialized
#define ERR_STEPNOTDEF	    36	    // Step size not defined
#define ERR_SAMPLNOTINT	    37	    // Sample times are not integer multiples
#define ERR_INCORRCHECK	    38	    // Incorrect model checksum
#define ERR_INTERNAL	    39	    // Internal error
