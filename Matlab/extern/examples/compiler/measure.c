/*
 *Doc example  Chapter 5.
 *$Revision: 1.1 $
 */

#include "matlab.h"
#include "collect_external.h"
#include <math.h>

extern double measure_from_device(void);

mxArray *Mcollect_collect_one( int nargout_) 
{ 
        return( mlfScalar( measure_from_device() )); 
}


double measure_from_device(void)
{ 
        static double t = 0.0;
        t = t + 0.05;
        return sin(t);
}
