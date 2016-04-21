#include "sfun_cppcount_cpp.h"

class  counter {
    double  x;
public:
    counter() {
        x = 0.0;
    }
    double output(void) {
        x = x + 1.0;
        return x; 
    }
};

void *createCounter()
{
	return (void *) new counter;
}

void deleteCounter(void *obj)
{
	counter *counterObj = (counter *)obj;
	delete counterObj;
}

double counterOutput(void *obj)
{
	counter *counterObj = (counter *)obj;
	return counterObj->output();
}

