/* Abstract: Asynchronous interrupt functions imported from kernel
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */

/* $Revision: 1.3 $  $Date: 2002/03/25 04:13:20 $ */


xpceRegisterISR = (void*) GetProcAddress(GetModuleHandle(NULL),
                                         "xpceRegisterISR");
if (xpceRegisterISR==NULL) {
    printf("xpceRegisterISR not found\n");
    return;
}

xpceDeRegisterISR = (void*) GetProcAddress(GetModuleHandle(NULL),
                                           "xpceDeRegisterISR");
if (xpceDeRegisterISR==NULL) {
    printf("xpceDeRegisterISR not found\n");
    return;
}
