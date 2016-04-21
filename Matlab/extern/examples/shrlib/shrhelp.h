/* shrhelp.h
 * Sharied libry helper include file for cross platform portablility
 * define EXPORT_FCNS before includeing this file in sorce files that build the library
 * no defines are needed to use the libary. */
#ifndef SHRHELP
#define SHRHELP

#ifdef WIN32
#ifdef EXPORT_FCNS
#define EXPORTED_FUNCTION __declspec(dllexport)
#else
#define EXPORTED_FUNCTION __declspec(dllimport)
#endif
#else
#define EXPORTED_FUNCTION
#endif

#endif

