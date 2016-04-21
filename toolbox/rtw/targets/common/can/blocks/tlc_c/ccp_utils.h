/*
 * File: filename.c
 *
 * Abstract:
 *    CCP utility functions
 *
 *
 * $Revision: 1.12.4.4 $
 * $Date: 2004/04/19 01:19:48 $
 *
 * Copyright 2001-2003 The MathWorks, Inc.
 */

#ifndef _CCP_UTILS_H
#define _CCP_UTILS_H

#include "tmwtypes.h"
#include "ccp_shared_data.h"
#include "ccp_build_mode.h"

/* real time code generation extras */
#ifdef CCP_MEMORY_OPERATIONS
   /* auto generated header file
    * specifying the number of DAQ lists etc */   
   #include "ccp_auto_defs.h"
   #ifndef CCP_DAQ_LIST_ENABLED
      #define C_NUMBER_OF_DAQ_LISTS 0
   #endif
#endif

/***********
 * DEFINES *
 ***********/

/* real time code generation extras */
#ifdef CCP_MEMORY_OPERATIONS
   #ifdef CCP_DAQ_LIST_ENABLED
      /* DAQ list specific */
      #define BYTE_ELEMENT 1
      #define WORD_ELEMENT 2
      #define LONG_ELEMENT 4
   #endif
#endif


/*********************
 * MACRO DEFINITIONS *
 *********************/

/* Macro to read the individual bytes of a uint32 */
#define c_getUINT32bytes(src_uint32_ptr, dest_ptr) \
{                                                  \
   uint8_T * src = (uint8_T *) (src_uint32_ptr);   \
   (dest_ptr)[0] = src[0];                         \
   (dest_ptr)[1] = src[1];                         \
   (dest_ptr)[2] = src[2];                         \
   (dest_ptr)[3] = src[3];                         \
}

/* Macro to write the individual bytes of uint32  */
#define c_setUINT32bytes(dest_uint32_ptr, src_ptr) \
{                                                  \
   uint8_T *dest = (uint8_T *) (dest_uint32_ptr);  \
   dest[0] = (src_ptr)[0];                         \
   dest[1] = (src_ptr)[1];                         \
   dest[2] = (src_ptr)[2];                         \
   dest[3] = (src_ptr)[3];                         \
}

/************
 * TYPEDEFS *
 ************/

/* real time code generation extras */
#ifdef CCP_MEMORY_OPERATIONS 
   #ifdef CCP_DAQ_LIST_ENABLED
      enum {DAQ_STOP=0, DAQ_START, DAQ_PREPARE};
      enum {DAQ_STOP_ALL=0, DAQ_START_SYNCHRONIZED};

      typedef struct {
         /* ecu memory address */
         uint32_T address;
         /* length of the element - 1, 2 or 4 bytes only
          * length of 0 indicates element is not used */
         uint8_T length;
      } C_DaqElement;
   
      typedef struct {
         /* each ODT fits into a single CAN message. 
          * the first byte is for the PID, the other 7 are
          * for DAQ data.
          *
          * So, an ODT can contain up to 7 single byte elements,
          * 1 single (4 byte) element + 3 single byte elements,
          * 3 uint16's + 1 single byte element etc, etc.
          *
          */
         C_DaqElement element[7];
      } C_DaqODT;

      typedef struct {
         /* ODT's in this DAQ list */
         C_DaqODT odt[C_NUMBER_OF_ODTS_PER_DAQ];
         /* stop==0 | start==1 | prepare transmission for synch. start == 2 */
         uint8_T daq_mode;
         /* last odt number to transmit */
         uint8_T last_odt;
         /* event channel used for this daq */
         uint8_T event_channel;
      } C_DaqList;

      typedef struct {
         /* DAQ List number 0 .. C_NUMBER_OF_DAQ_LISTS - 1 */
         uint8_T daq;
         /* ODT Number 0 .. C_NUMBER_OF_ODTS_PER_DAQ - 1 */
         uint8_T odt;
         /* Element number 0..7 */
         uint8_T element;
      } C_Element_Pointer; 

      /* DAQ message send function */
      extern void exported_ccp_daq_trigger(uint8_T *);
   #endif
#endif
 

/***********************
 * FUNCTION PROTOTYPES *
 ***********************/

/* read 'length' uint8's from memory at 'address' into 'dest' */
void c_read_uint8s(uint8_T * dest, uint8_T length, uint32_T * address);

/* write 'length' uint8's to memory at 'address' from 'source' */
void c_write_uint8s(const uint8_T * source, uint8_T length, uint32_T *address); 

/* move some memory */
uint8_T c_move(uint32_T st_addr,uint32_T end_addr,uint32_T to_move);

/* DAQ list implementation */
void c_init_daq_list(uint8_T);
void c_set_element_pointer(uint8_T, uint8_T, uint8_T);
void c_write_daq(uint8_T, uint32_T);
void c_start_stop(uint8_T, uint8_T, uint8_T, uint8_T, uint16_T);
void c_fireDAQs(uint8_T);
void c_start_stop_all(uint8_T);
void c_reset_all_DAQ_lists(void);
void c_reset_single_DAQ_list(uint8_T);

/* END CCP_UTILS_H */
#endif
