/*
 * The following example illustrates how to use C++ code with
 * your C language MEX-file for MATLAB 5 for UNIX or Microsoft Visual.
 * It makes use of member functions, constructors, destructors, and the
 * iostream.
 *
 * The routine simply defines a class, constructs a simple object,
 * and displays the initial values of the internal variables.  It
 * then sets the data members of the object based on the input given
 * to the MEX-file and displays the changed values.
 *
 * The file is called mexcpp.cpp.  The extension was chosen rather
 * arbitrarily and as being unambiguous and generally recognized by
 * C++ compilers.  The mex script should recognize any other common
 * C++ source file extension, such as .C, .cc, or .cxx.
 *
 * FOR UNIX:
 * In order to compile this example, invoke mex as:
 *
 *   mex mexcpp.cpp
 *
 * FOR NT:
 * Be sure to set your environment for MSVC++ 5.0.  In order to do this,
 * run 'mex -setup' at the MATLAB command prompt.  Then invoke mex as:
 *
 *   mex mexcpp.cpp
 *
 *
 * The calling syntax is:    mexcpp( num1, num2 )
 *
 * If you run your MEX-file in MATLAB and you do not receive the expected
 * output make sure that you have a C++ flush() function call in your
 * program.  Also, for NT, cout will not display, since there is no shell
 * to display to.  Therefore, you must use mexPrintf.
 *
 * Copyright (c) 1984-1998 by The MathWorks, Inc.
 * All Rights Reserved.
 * $Revision: 1.5.4.1 $
 */
#include <iostream>
#include <math.h>
#include "mex.h"

using namespace std;

extern void _main();

/****************************/
class MyData {

public:
  void display();
  void set_data(double v1, double v2);
  MyData(double v1 = 0, double v2 = 0);
  ~MyData() { }
private:
  double val1, val2;
};

MyData::MyData(double v1, double v2)
{
  val1 = v1;
  val2 = v2;
}

void MyData::display()
{
#ifdef _WIN32
	mexPrintf("Value1 = %g\n", val1);
	mexPrintf("Value2 = %g\n\n", val2);
#else
  cout << "Value1 = " << val1 << "\n";
  cout << "Value2 = " << val2 << "\n\n";
#endif
}

void MyData::set_data(double v1, double v2) { val1 = v1; val2 = v2; }

/*********************/

static
void mexcpp(
	    double num1,
	    double num2
	    )
{
#ifdef _WIN32
	mexPrintf("\nThe initialized data in object:\n");
#else
  cout << "\nThe initialized data in object:\n";
#endif
  MyData *d = new MyData; // Create a  MyData object
  d->display();           // It should be initialized to
                          // zeros
  d->set_data(num1,num2); // Set data members to incoming
                          // values
#ifdef _WIN32
  mexPrintf("After setting the object's data to your input:\n");
#else
  cout << "After setting the object's data to your input:\n";
#endif
  d->display();           // Make sure the set_data() worked
  delete(d);
  flush(cout);
  return;
}

void mexFunction(
		 int          nlhs,
		 mxArray      *plhs[],
		 int          nrhs,
		 const mxArray *prhs[]
		 )
{

  double      *vin1, *vin2;

  /* Check for proper number of arguments */

  if (nrhs != 2) {
    mexErrMsgTxt("MEXCPP requires two input arguments.");
  } else if (nlhs >= 1) {
    mexErrMsgTxt("MEXCPP requires no output argument.");
  }

  vin1 = (double *) mxGetPr(prhs[0]);
  vin2 = (double *) mxGetPr(prhs[1]);

  mexcpp(*vin1, *vin2);
  return;
}
