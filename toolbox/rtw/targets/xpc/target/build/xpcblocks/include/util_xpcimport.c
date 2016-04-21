/* $Revision: 1.4 $ */
/* $Date: 2002/03/25 04:14:26 $ */

/* Abstract: Utility functions imported from kernel.
 *
 *  Copyright 1996-2002 The MathWorks, Inc.
 *
 */


xpceIsModelInit = (void*) GetProcAddress(GetModuleHandle(NULL),
                                         "xpceIsModelInit");
if (xpceIsModelInit == NULL) {
        printf("xpceIsModelInit not found\n");
        return;
}
