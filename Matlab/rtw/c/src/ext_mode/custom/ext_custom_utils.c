/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: ext_custom_utils.c     $Revision: 1.1.6.1 $
 *
 * Absract:
 *  External mode shared data structures and functions used by the external
 *  communication, mex link, and generated code.  This file is for definitions
 *  related to custom external mode implementations (e.g., sockets, serial).
 *  See ext_share.h for definitions common to all implementations of external
 *  mode (ext_share.h should NOT be modified).
 *     
 *      [THIS FILE NEEDS TO BE MODIFIED TO IMPLEMENT VARIOUS DATA TRANSPORT
 *       MECHANISMS]
 */


/***************** TRANSPORT-DEPENDENT DEFS AND INCLUDES **********************
 *                                                                            *
 * THESE INCLUDES ARE SPECIFIC TO THE TRANSPORT IMPLEMENTATION AND WOULD BE   *
 * MODIFIED WHEN IMPLEMENTING A NEW TRANSPORT LAYER.  THESE DEFS AND INCLUDES *
 * ARE IDENTICAL ON THE HOST AND TARGET, AND ARE THEREFORE DEFINED HERE       *
 *                                                                            *
 ******************************************************************************/


/***************** PRIVATE FUNCTIONS ******************************************
 *                                                                            *
 *  THE FOLLOWING FUNCTIONS ARE SPECIFIC TO THE CUSTOM IMPLEMENTATION OF      *
 *  HOST-TARGET COMMUNICATION.  THESE FUNCTIONS ARE IDENTICAL ON THE HOST     *
 *  AND TARGET, AND ARE THEREFORE DEFINED HERE.                               *
 *                                                                            *
 ******************************************************************************/


/* [EOF] ext_custom_utils.c */
