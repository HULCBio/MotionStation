#ifndef __COMM_HS_ERR__
#define __COMM_HS_ERR__

/* COMM_HS_ERR.h Common handshake error messages used in Comms Blockset Sfunctions
 * Copyright 1996-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/20 23:15:49 $
 */

/* Note: add to the list as you create more common messages.
 * 
 */

/* --  Related to Frame status time propagation 
 */
 
 #define COMM_EMSG_INVALID_FRAME 	"Invalid frame status specified for the" \
 									" input or output port."
 									
/* --  Related to Sample time propagation 
 */ 
 
#define COMM_EMSG_RST_TS_OUT	"The reset port's sample time must be the" \
                              	" same as the output port's sample time."
#define COMM_EMSG_RST_TS_IN   	"The reset port's frame time must be the" \
                              	" same as the input port's frame time."
#define COMM_EMSG_RST_TS_SYMB  	"The reset port's sample time must be" \
                          		" the same as the symbol period."
#define COMM_EMSG_RST_OPTION  	"Invalid resetting option for" \
								" sample-based input."
								
#define COMM_EMSG_DISCRETE_SIGNALS  	"All signals must be discrete."
#define COMM_EMSG_NONZERO_OFFSET_TIME  	"Non-zero sample time offsets are" \
                                  		" not allowed."  
#define COMM_EMSG_INVALID_SAMPLE_TIME	"Invalid sample time specified for" \
										" the input or the output port."                                  		       
                                       
/* --  Related to Dimensions propagation 
 */
 
#define COMM_EMSG_INVALID_DIMS         "Invalid dimensions are specified for" \
                                       " the input or output port."
#define COMM_EMSG_SCALAR_RST_SIGNAL    "The reset signal must be a scalar."
#define COMM_EMSG_NO_MULTICHAN_SIGNAL  "This block does not allow"\
                                       " multi-channel signals."

#define COMM_EMSG_SCALAR_INPUT         "The input must be a scalar in" \
									   " sample-based mode."
#define COMM_EMSG_SCALAR_OUTPUT        "The output must be a scalar in" \
									   " sample-based mode."									  
#define COMM_EMSG_FRAME_MULT_SAMP  	   "The input frame length must be an" \
                              		   " integer multiple of the number of" \
                              		   " samples per symbol."
                              		   
/* Related to Complexity propagation
 */                              		   
#define COMM_EMSG_INVALID_COMPLEXITY	"Invalid complexity specified for" \
										" the input or th eoutput port."
																				                              		   
#endif

