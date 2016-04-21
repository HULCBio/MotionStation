/* $Revision: 1.5 $ */
/* $Date: 2002/03/25 03:57:11 $ */

/* 
 * Abstract: shared data for xPC Target driver s-functions
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 *
*/
 
 
// static data pool for digital section of the BB PCI-20041C carrier board
int pci20041digout=0x8f;

// static data pool for digital section of the BB PCI-20098C carrier board
int pci20098PortA=0;
int pci20098PortB=0;

// static data pool for PowerCAN-board from SiE
int siepowercan_firmware_initialized=0;
int siepowercan_port1_configured=0;
int siepowercan_port2_configured=0;
double siepowercan_can_object_buffer_port1[2048];
double siepowercan_can_object_buffer_port2[2048];


#define MAX_OBJECTS 				200

int CANAC2_FIRMWARE_LOADED=0;

int CANAC2_1_send[MAX_OBJECTS];
int CANAC2_1_receive[MAX_OBJECTS];
int CANAC2_2_send[MAX_OBJECTS];
int CANAC2_2_receive[MAX_OBJECTS];
int CANAC2_1_sendmaxindex;
int CANAC2_1_sendindex[MAX_OBJECTS];
int CANAC2_1_receivemaxindex;
int CANAC2_1_receiveindex[MAX_OBJECTS];
int CANAC2_2_sendmaxindex;
int CANAC2_2_sendindex[MAX_OBJECTS];
int CANAC2_2_receivemaxindex;
int CANAC2_2_receiveindex[MAX_OBJECTS];

int rs232ports[]={0,0,0,0};

int NI_AT_MIO_16F_5_commreg2=0x0;

int RTD_DM6430_init=0;
int RTD_DM6420_init=0;

int nipcdio24cnfg=0xff;

int rtddm6604cnfg=0xff;

#include "canac2pci_mb.h"
