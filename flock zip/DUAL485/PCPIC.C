/****************************************************************************
*****************************************************************************
    pcpic.c         PC programmable Interrupt Controller Code

    written for:    Ascension Technology Corporation
                    PO Box 527
                    Burlington, Vermont  05402

                    802-655-7879


    written by:     Jeff Finkelstein
                    Microprocessor Designs, Inc
                    PO Box 160
                    Shelburne, Vermont  05482

                    802-985-2535

    Modification History:

    9/16/93         jf  - created

           <<<< Copyright 1993 Ascension Technology Corporation >>>>
*****************************************************************************
****************************************************************************/

#include "pcpic.h"

unsigned char oldirqmsk;                /* holds the old interrupt cont msk value */
