#ifndef _ADDER_CPP_
#define _ADDER_CPP_

#ifdef __cplusplus

	/* C++ class definition */
	class adder {
	private:
		int int_state;
	public:
		/* 
		 * Stateflow only generates C code, so constructors
		 * destructors, and methods must have a wrapper
		 * function with extern "C" linkage.  See below
		 * for these wrappers.
		 */
		adder();
		void add_one(int increment);
		int get_val();
	};

#else

	/*
	 * Stateflow generates c files, not C++.  This leaves two
	 * options for passing objects to functions.  They are as
	 * follows:
	 *
	 * 1) Use "void *" declarations to hold objects within
	 *    Stateflow.  This option will require type casts
	 *    every time we need to cross the C / C++ boundary.
	 *
	 * 2) Define a c-only opaque structure type with the same
	 *    name as the class.  This option requires no type
	 *    casts and allows your custom code to look  cleaner.
	 *
	 * For this example we have chosen option 2.
	 */
	typedef struct adder adder;

#endif


/*
 * Stateflow only generates c code.  Therefore, custom
 * code C++ function called by Stateflow must have
 * extern "C" linkage.
 */
#ifdef __cplusplus
extern "C" {
#endif

/* External declaration for class instance global storage */
extern adder *adderVar;

/* Constructor wrapper */
extern adder *createAdder();

/* Destructor wrapper */
extern void deleteAdder(adder *obj);

/* Method wrapper */
extern double adderOutput(adder *obj, int increment);

#ifdef __cplusplus
}
#endif

#endif /* _ADDER_CPP_ */


