#include "adder_cpp.h"

/***************************************/
/**** Class instance global storage ****/
/***************************************/

adder *adderVar;

/**********************************/
/**** Class method definitions ****/
/**********************************/

adder::adder()
{
	int_state = 0;
}

void adder::add_one(int increment)
{
	int_state += increment;
}

int adder::get_val()
{
	return int_state;
}

/*****************************************/
/**** extern "C" wrappers for methods ****/
/*****************************************/

adder *createAdder()
{
	return new adder;
}

void deleteAdder(adder *obj)
{
	delete obj;
}

double adderOutput(adder *obj, int increment)
{
	obj->add_one(increment);
	return obj->get_val();
}
