/*
 *  $RCSfile: c6000_main.h,v $
 *  $Revision: 1.19.2.4 $
 *  $Date: 2004/04/08 21:00:25 $
 *  Copyright 1999-2004 The MathWorks, Inc.
 *
 *  Abstract:  Header file for <model>_main.c
 */

#ifndef C6000_MAIN_H
#define C6000_MAIN_H

/*=========*
 * Defines *
 *=========*/

#ifndef TRUE
#define FALSE (0)
#define TRUE  (1)
#endif

#ifndef EXIT_FAILURE
#define EXIT_FAILURE  1
#endif
#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS  0
#endif

#define QUOTE1(name) #name
#define QUOTE(name) QUOTE1(name)    /* need to expand name    */

#ifndef RT
# error "must define RT"
#endif

#ifndef MODEL
# error "must define MODEL"
#endif

#ifndef NUMST
# error "must define number of sample times, NUMST"
#endif

#ifndef NCSTATES
# error "must define NCSTATES"
#endif

#define RUN_FOREVER -1.0

#define EXPAND_CONCAT(name1,name2) name1 ## name2
#define CONCAT(name1,name2) EXPAND_CONCAT(name1,name2)
#define RT_MODEL            CONCAT(MODEL,_rtModel)


#endif

/* [EOF] c6000_main.h */
