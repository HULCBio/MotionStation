/*
 * File: profile.h
 *
 * Abstract: Header file for exectution profiling engine
 *
 * $Revision: 1.1.6.2 $
 * $Date: 2003/07/31 18:05:19 $
 *
 * Copyright 2003 The MathWorks, Inc.
 */

#ifndef _PROFILE_H_
#define _PROFILE_H_

#include "tmwtypes.h"

#define PROFILING_INACTIVE 0
#define PROFILING_LOG_IN_PROGRESS 1
#define PROFILING_SEND_IN_PROGRESS 2


/*
 * Function: overrun_max_log
 * 
 * Purpose:  Call this function to log the maximum number of task overruns
 *           that occurred at any one time during model execution.
 *
 * Inputs:   
 *           overrunFlag - The present value of the overrunsFlag for this task;
 *                         note that this is one greater than the number of 
 *                         overruns that have occurred.
 *
 *           taskNo      - the task number in the range 0 to NUMST-1
 * 
 * Returns:  none
 */
void overrun_max_log(uint_T overruns, uint_T taskNo);


/*
 * Function: profile_init
 * 
 * Purpose:  Initialization required for profiling. This function should be
 *           called once during model initialization.
 *
 * Inputs:   none
 * 
 * Returns:  none
 */
void profile_init(void);

/*
 * Function: profile_begin
 * 
 * Purpose:  Initialization required to begin a profiling run. This function
 *           should be called each time profiling data is to be logged.
 *
 * Inputs:   none
 * 
 * Returns:  none
 */
void profile_begin(void);


/*
 * Function: profile_task_start
 * 
 * Purpose: Function called at the start of a timer task to be profiled. This function must be used in 
 *          conjuction with profile_task_end. Together these functions are used to log profiling data
 *          over a period of time and to track the maximum turnaround time of each timer task since model 
 *          execution began. 
 *          
 *          This function should be called with interrupts disabled to ensure
 *          that the index into the logged data array is consistent.
 *
 * Inputs:  
 *   
 *    task_num - an array index that identifies the timer task being scheduled. This value MUST be in 
 *               the range 0 to NumberOfSampleTimes-1.
 *
 * Returns: none */
void profile_task_start(int_T section_num);


/*
 * Function: profile_task_end
 * 
 * Purpose:  See profile_task_start.
 *
 * Inputs:   
 *   
 *    task_num - see profile_task_start.
 * 
 * Returns:  none
 */
void profile_task_end(int_T section_num);



/*
 * Function: profile_section_start
 * 
 * Purpose:  Function called at the start of a section of code to be profiled. This function
 *           must be used in conjunction with profile_section_end. Together these functions are
 *           used to log profiling data over the period of time when execution profile logging
 *           is in progress.
 * 
 *           This function should be called with interrupts disabled to ensure
 *           that the index into the logged data array is consistent.
 *
 * Inputs:   
 *   
 *    section_num  - an array index that identifies the code section being profiled; the value
 *                   of section_num may be any value that identifies the section of code being
 *                   profiled. 
 *
 * Returns:  none
 */
void profile_section_start(int_T section_num);


/*
 * Function: profile_section_end
 * 
 * Purpose:  See profile_section_start.
 *
 * Inputs:   
 *   
 *    section_num  - see profile_section_start.
 * 
 * Returns:  none
 */
void profile_section_end(int_T section_num);


/*
 * Function: profile_get_data
 * 
 * Purpose:  Function called to retrieve logged profiling data.
 *
 * Inputs:   
 *   
 *    p_data_block - pointer to an array, into which the the next block of data
 *                   will be copied; the calling function is responsible for
 *                   allocating the memory for this array
 *                   
 * 
 * Returns:  1 if data was available, 0 otherwise
 */
uint_T profile_get_data(uint8_T * p_data_block);


/*
 * Function: profile_state_update
 * 
 * Purpose:  Function called to update the profiling internal state. This function
 *           must be called periodically, e.g. from a background task.
 *
 * Inputs:   
 *   
 *    p_data_block - pointer to an array, into which the the next block of data
 *                   will be copied; the calling function is responsible for
 *                   allocating the memory for this array
 *                   
 * 
 * Returns:  none
 */
void profile_state_update(void);

/*
 * Function: profile_get_state
 * 
 * Purpose:  Function called return profiling internal state. 
 *
 * Inputs:   
 * 
 *    None.
 *
 * Returns:
 * 
 *    A state variable, which  must be one of 
 *
 *       PROFILING_INACTIVE
 *       PROFILING_LOG_IN_PROGRESS
 *       PROFILING_SEND_IN_PROGRESS
 *
 */
uint_T profile_get_state(void);

/*
 * Function: profile_get_max_turnaround
 * 
 * Purpose:  Get maximum logged turnaround time for a task.
 *
 * Inputs:   
 * 
 *    rate - the rate, where 0 is the base rate, 1, 2, 3 .. are sub-rates.
 *
 * Returns:
 * 
 *    The maximum logged turnaround time in timer ticks.
 *
 */
uint_T profile_get_max_turnaround(uint_T rate);


#endif




