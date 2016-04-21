/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Copyright by The HDF Group.                                               *
 * Copyright by the Board of Trustees of the University of Illinois.         *
 * All rights reserved.                                                      *
 *                                                                           *
 * This file is part of HDF5.  The full HDF5 copyright notice, including     *
 * terms governing use, modification, and redistribution, is contained in    *
 * the files COPYING and Copyright.html.  COPYING can be found at the root   *
 * of the source code distribution tree; Copyright.html can be found at the  *
 * root level of an installed copy of the electronic HDF5 document set and   *
 * is linked from the top-level documents page.  It can also be found at     *
 * http://hdfgroup.org/HDF5/doc/Copyright.html.  If you do not have          *
 * access to either file, you may request a copy from help@hdfgroup.org.     *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/*
 * H5api_adpt.h
 * Used for the HDF5 dll project
 * Created by Patrick Lu on 1/12/99
 */
#ifndef H5API_ADPT_H
#define H5API_ADPT_H

#if defined(WIN32)

#if defined(_HDF5DLL_)
#pragma warning(disable: 4273)	/* Disable the dll linkage warnings */
#define H5_DLL __declspec(dllexport)
#define H5_DLLVAR extern __declspec(dllexport)
#elif defined(_HDF5USEDLL_)
#define H5_DLL __declspec(dllimport)
#define H5_DLLVAR __declspec(dllimport)
#else
#define H5_DLL
#define H5_DLLVAR extern
#endif /* _HDF5DLL_ */

#if defined(HDF5_HLDLL)
#pragma warning(disable: 4273)	/* Disable the dll linkage warnings */
#define H5_HLDLL __declspec(dllexport)
#elif defined(_HDF5USEHLDLL_)
#define H5_HLDLL __declspec(dllimport)
#else
#define H5_HLDLL
#endif /* _HDF5_HLDLL */


#if defined(_HDF5TESTDLL_)
#pragma warning(disable: 4273)	/* Disable the dll linkage warnings */
#define H5TEST_DLL __declspec(dllexport)
#define H5TEST_DLLVAR extern __declspec(dllexport)
#elif defined(_HDF5TESTUSEDLL_)
#define H5TEST_DLL __declspec(dllimport)
#define H5TEST_DLLVAR __declspec(dllimport)
#else
#define H5TEST_DLL
#define H5TEST_DLLVAR extern
#endif /* _HDF5TESTDLL_ */

#if defined(HDF5FORT_CSTUB_DLL_EXPORTS)
#pragma warning(disable: 4273)	/* Disable the dll linkage warnings */
#define H5_FCDLL __declspec(dllexport)
#define H5_FCDLLVAR extern __declspec(dllexport)
#elif defined(HDF5FORT_CSTUB_USEDLL)
#define H5_FCDLL __declspec(dllimport)
#define H5_FCDLLVAR __declspec(dllimport)
#else
#define H5_FCDLL
#define H5_FCDLLVAR extern
#endif /* _HDF5_FORTRANDLL_EXPORTS_ */

#if defined(HDF5FORTTEST_CSTUB_DLL_EXPORTS)
#pragma warning(disable: 4273)	/* Disable the dll linkage warnings */
#define H5_FCTESTDLL __declspec(dllexport)
#define H5_FCTESTDLLVAR extern __declspec(dllexport)
#elif defined(HDF5FORTTEST_CSTUB_USEDLL)
#define H5_FCTESTDLL __declspec(dllimport)
#define H5_FCTESTDLLVAR __declspec(dllimport)
#else
#define H5_FCTESTDLL
#define H5_FCTESTDLLVAR extern
#endif /* _HDF5_FORTRANDLL_EXPORTS_ */



/* Added to export or to import C++ APIs - BMR (02-15-2002) */
#if defined(HDF5_CPPDLL_EXPORTS) /* this name is generated at creation */
#define H5_DLLCPP __declspec(dllexport)
#elif defined(HDF5CPP_USEDLL)
#define H5_DLLCPP __declspec(dllimport)
#else
#define H5_DLLCPP
#endif /* HDF5_CPPDLL_EXPORTS */

#else /*WIN32*/
#define H5_DLL
#define H5_HLDLL
#define H5_DLLVAR extern
#define H5_DLLCPP
#define H5TEST_DLL
#define H5TEST_DLLVAR extern
#define H5_FCDLL
#define H5_FCDLLVAR extern
#define H5_FCTESTDLL
#define H5_FCTESTDLLVAR extern
#endif

#endif /* H5API_ADPT_H */
