/*
 * File: ccp_utils.c
 *
 * Abstract:
 *    Description of file contents and purpose.
 *
 *
 * $Revision: 1.13.4.5 $
 * $Date: 2004/04/19 01:19:47 $
 *
 * Copyright 2001-2004 The MathWorks, Inc.
 */

#include "ccp_utils.h"

/* real time code generation extras */
#ifdef CCP_MEMORY_OPERATIONS 
   #ifdef CCP_DAQ_LIST_ENABLED
      /* The DAQ Lists */
      static C_DaqList c_dlist[C_NUMBER_OF_DAQ_LISTS];

      /* Pointer to the currently selected ODT element */
      static C_Element_Pointer eptr; 
   #endif
#endif

#ifdef CCP_STRUCT
   /* Shared data structure */
   /* Declared as extern in canlibCCP.h */
   struct ccp_shared_data ccp = {{0,0}, {0,0}, {0,0}, {0,0}, 0, {0,0,0,0,0,0,0,0}, 0, CCP_DISCONNECTED_STATE};
#endif
   
/*************************/
/* RUNNING IN SIMULATION */
/*************************/

#ifndef CCP_MEMORY_OPERATIONS
   /* dummy return values so simulation functions correctly. */

   void c_read_uint8s(uint8_T * dest, uint8_T length, uint32_T * address) {
      /* increment address only in simulation */
      int i;
      for (i=0; i<length; i++) {
         (*address)++;
      }
      return;
   }

   void c_write_uint8s(const uint8_T * source, uint8_T length, uint32_T *address) {
      /* increment address only in simulation */
      int i;
      for (i=0; i<length; i++) {
         (*address)++;
      }
      return;
   }

   uint8_T c_move(uint32_T st_addr,uint32_T end_addr,uint32_T to_move) {return 0;} 

   void c_init_daq_list(uint8_T daq_number) {
      return;
   }

   void c_set_element_pointer(uint8_T daq_number, uint8_T odt_number, uint8_T element_number) {
      return;
   }

   void c_write_daq(uint8_T element_size, uint32_T element_address) {
      return;
   }

   void c_start_stop(uint8_T daq_mode, uint8_T daq_number, uint8_T last_odt, uint8_T event_channel, uint16_T prescaler) {
      return;
   }

   void c_start_stop_all(uint8_T start_stop) {
      return;
   }

   void c_fire_DAQs(uint8_T event_channel) {
      return;
   }

   void c_init(void) {
      return;
   }
   
   void c_reset_all_DAQ_lists(void) {
      return;
   }
#else

/*********************/
/*RUNNING ON HARDWARE*/
/*********************/

   void c_read_uint8s(uint8_T * dest, uint8_T length, uint32_T * address) {
      int i;
      for (i=0; i<length; i++) {
         dest[i] = *((uint8_T *) (*address));
         (*address)++;
      }
   }

   void c_write_uint8s(const uint8_T * source, uint8_T length, uint32_T *address) {
      int i;
      for (i=0; i<length; i++) {
         *((uint8_T *) (*address)) = source[i];
         (*address)++;
      }
   }

   uint8_T c_move(uint32_T st_addr, uint32_T end_addr, uint32_T to_move) {
      int i;
      for (i=0 ; i<to_move ; i++) {
         *(uint8_T *) end_addr=st_addr;
         st_addr++;
         end_addr++;
      }
      return 1;
   }

void c_reset_all_DAQ_lists(void) {
   int i;
   /* loop through each DAQ list and reset them */
   for (i=0; i<C_NUMBER_OF_DAQ_LISTS; i++) {
      /* call function to reset the daq list */
      c_reset_single_DAQ_list(i);
   }
}

/* resets the daq list specified by daq_number
 * resets all elements in the list and sets the 
 * daq_mode to DAQ_STOP */
void c_reset_single_DAQ_list(uint8_T daq_number) {
   /* test to see if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      int i, j; /* loop counters */
   
      /* get pointer to single DAQ List */
      C_DaqList* daq_ptr = &(c_dlist[daq_number]); 
      /* set daq mode to STOP */
      daq_ptr->daq_mode = DAQ_STOP;
   
      for (i=0; i < C_NUMBER_OF_ODTS_PER_DAQ; i++) {
         /* get pointer to single ODT */
         C_DaqODT* odt_ptr = &(daq_ptr->odt[i]);     
         for (j=0; j<7; j++) {
            /* zero the length of each element */
            odt_ptr->element[j].length = 0;
         }
      }
   #endif
}

/* Initialise a DAQ list */
/* This function is responsible for setting bytes 3 and 4 of the 
 * DTO for GET_DAQ_SIZE */
void c_init_daq_list(uint8_T daq_number) {
   /* check the daq_number is valid 
    * valid daq number --->    0 <= daq_number < C_NUMBER_OF_DAQ_LISTS */
   if ((daq_number < 0)  || (daq_number >= C_NUMBER_OF_DAQ_LISTS)) {
      /* return zero list size */
      ccp.data[3] = 0;
      /* set pid to 0 */
      ccp.data[4] = 0;
      return;
   }
 
   /* this part is only applicable if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      /* call function to reset the daq list */
      c_reset_single_DAQ_list(daq_number);
   
      /* set DAQ list size */
      ccp.data[3] = C_NUMBER_OF_ODTS_PER_DAQ;
      /* calculate first PID of DAQ list */
      ccp.data[4] = daq_number * C_NUMBER_OF_ODTS_PER_DAQ;
   #endif
}

/* Set the pointer to the current element */
void c_set_element_pointer(uint8_T daq_number, uint8_T odt_number, uint8_T element_number) {
   /* only valid if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      eptr.daq = daq_number;
      eptr.odt = odt_number;
      eptr.element = element_number;
   #endif
}

/* Write an entry to the DAQ list in a position pointed to by the C_Element_Pointer */
void c_write_daq(uint8_T element_size, uint32_T element_address) {
   /* only valid if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      c_dlist[eptr.daq].odt[eptr.odt].element[eptr.element].length = element_size;
      c_dlist[eptr.daq].odt[eptr.odt].element[eptr.element].address = element_address;
   #endif
}
 
/* Start / stop data acquisition */
void c_start_stop(uint8_T daq_mode, uint8_T daq_number, uint8_T last_odt, uint8_T event_channel, uint16_T prescaler) {
   /* only valid if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      c_dlist[daq_number].daq_mode = daq_mode;
      c_dlist[daq_number].last_odt = last_odt;
      c_dlist[daq_number].event_channel = event_channel;
   #endif
}

void c_start_stop_all(uint8_T start_stop) {
   /* 
    * if start_stop == DAQ_START_SYNCHRONIZED then start all DAQ lists that have daq_mode == DAQ_PREPARE 
    * if start_stop == DAQ_STOP_ALL then stop all DAQ lists
    */
   /* only valid if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      if (start_stop == DAQ_START_SYNCHRONIZED) {
         /* loop through all DAQ lists looking for DAQ_MODE == DAQ_PREPARE */
         int dlist_ptr;
         for (dlist_ptr=0; dlist_ptr < C_NUMBER_OF_DAQ_LISTS; dlist_ptr++) {
            if (c_dlist[dlist_ptr].daq_mode == DAQ_PREPARE) {
               c_dlist[dlist_ptr].daq_mode = DAQ_START;
            }
         }
      }
      else {
         /* stop all DAQ lists */
         int dlist_ptr;
         for (dlist_ptr=0; dlist_ptr < C_NUMBER_OF_DAQ_LISTS; dlist_ptr++) {
            c_dlist[dlist_ptr].daq_mode = DAQ_STOP;
         }
      }
   #endif
}

void c_fire_DAQs(uint8_T event_channel) {
   /* only valid if DAQ lists are configured */
   #ifdef CCP_DAQ_LIST_ENABLED
      /* loop through all ODT's sending appropriate data */
      int dlist_ptr;
      for (dlist_ptr=0; dlist_ptr < C_NUMBER_OF_DAQ_LISTS; dlist_ptr++) {
         /* check the mode for the current list */
         if (c_dlist[dlist_ptr].daq_mode == DAQ_START) {
            /* check the event channel for the current list */
            if (c_dlist[dlist_ptr].event_channel == event_channel) {
               int odt_ptr;
               /* loop over appropriate ODT's */
               for (odt_ptr=0; odt_ptr <= c_dlist[dlist_ptr].last_odt; odt_ptr++) {
                  /* construct a message for the current odt by 
                   * looping through the elements */
                  int element_ptr;
                  int msg_ptr = 0;
                  uint8_T msg[8];
                  /* set the pid for the message */
                  msg[msg_ptr] = (dlist_ptr * C_NUMBER_OF_ODTS_PER_DAQ) + odt_ptr;
                  msg_ptr++;
                  for (element_ptr=0; element_ptr < 7; element_ptr++) {
                     C_DaqElement element = c_dlist[dlist_ptr].odt[odt_ptr].element[element_ptr];
                     
                     /* element.address is a pointer to the desired element
                        add element to the message depending the element le0ngth */
                     switch (element.length) {
                        case BYTE_ELEMENT: 
                                     {
                                         /* get a byte pointer to this address */
                                         uint8_T * bytesrc = (uint8_T *) element.address;
                                         msg[msg_ptr++] = bytesrc[0]; 
                                         break;
                                     }
                        case WORD_ELEMENT:
                                     {
                                         /* 16 bit pointer to address */
                                         uint16_T * wordsrc = (uint16_T *) element.address;
                                         /* atomic element copy in case of interruption
                                          * by a faster task that changes the data
                                          * NOTE: 16 bit copy instruction required 
                                          * NOTE: This is only an issue if DAQ element
                                          * is assigned to incorrect DAQ list! */
                                         uint16_T temp = *wordsrc; 
                                         
                                         /* byte copy to deal with alignment issues in
                                          * output message - we do not know where elements
                                          * will be placed */
                                         uint8_T * bytesrc = (uint8_T *) &temp;
                                         
                                         /* read 2 bytes into msg */
                                         msg[msg_ptr++] = bytesrc[0];
                                         msg[msg_ptr++] = bytesrc[1];
                                         break;
                                     }
                        case LONG_ELEMENT:
                                     { 
                                         /* 32 bit pointer to address */
                                         uint32_T * longsrc = (uint32_T *) element.address;
                                         /* atomic element copy in case of interruption
                                          * by a faster task that changes the data 
                                          * NOTE: 32 bit copy instruction required 
                                          * NOTE: This is only an issue if DAQ element 
                                          * is assigned to incorrect DAQ list! */
                                         uint32_T temp = *longsrc;

                                         /* byte copy to deal with alignment issues in
                                          * output message - we do not know where elements
                                          * will be placed */
                                         uint8_T * bytesrc = (uint8_T *) &temp;
                                         
                                         /* read 4 bytes into msg */
                                         msg[msg_ptr++] = bytesrc[0];
                                         msg[msg_ptr++] = bytesrc[1];
                                         msg[msg_ptr++] = bytesrc[2];
                                         msg[msg_ptr++] = bytesrc[3];
                                         break;    
                                     }
                     } /* end switch */
                  } /* end element for */     
                  /* send the message for the ODT 
                   * exported_ccp_daq_trigger is exported by a block in the model */
                  exported_ccp_daq_trigger(&msg[0]);
               } /* end odt for */
            } /* end event_channel if */
         } /* end daq_mode if */
      } /* end dlist for */
   #endif
} /* end function */
#endif
