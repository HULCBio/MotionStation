/* Abstract: Signal monitoring/Parameter tuning routine.
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */

/* $Revision: 1.2 $  $Date: 2002/03/25 04:14:08 $ */


xpceGetSignalValue = (void*) GetProcAddress(GetModuleHandle(NULL),
                                            "xpceGetSignalValue");
if (xpceGetSignalValue == NULL) {
    printf("xpceGetSignalValue not found\n");
    return;
}

xpceSetParameter = (void *) GetProcAddress(GetModuleHandle(NULL),
                                           "xpceSetParameter");
if (xpceSetParameter == NULL) {
    printf("xpceSetParameter not found\n");
    return;
}

xpceGetParameter = (void *) GetProcAddress(GetModuleHandle(NULL),
                                           "xpceGetParameter");
if (xpceGetParameter == NULL) {
    printf("xpceGetParameter not found\n");
    return;
}
