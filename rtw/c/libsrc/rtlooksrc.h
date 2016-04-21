#ifndef rtlooksrc_h
#define rtlooksrc_h

/* 
 * File: rtlooksrc.h generated from file
 *       gentablefuncs, Revision: 1.7.4.4.2.1 
 * 
 * Abstract: 
 *
 *    Function prototypes for look-up table algorithms.
 *
 * 
 *   Copyright 1994-2003 The MathWorks, Inc.
 *
 */

#include "rtwtypes.h"

/***************************************************************
 *                n-D Table Work Data Structures               *
 ***************************************************************/

typedef struct rt_LUTnWork_tag {
  const int_T  *dimSizes;
  void   *tableData;
  void  **bpDataSet;
  int_T  *bpIndex;
  void   *bpLambda;
  const int_T  *maxIndex;
} rt_LUTnWork;

typedef struct rt_LUTSplineWork_tag {
  rt_LUTnWork *TWork;
  void        *yyA;
  void        *yyB;
  void        *yy2;
  void        *up;
  void        *y2;
  const int_T       *numYWorkElts;
} rt_LUTSplineWork;

/* double precision variant */

typedef struct rt_LUTnWorkd_tag {
  const int32_T  *dimSizes;
  const real_T   *tableData;
  real_T  **bpDataSet;
  int32_T  *bpIndex;
  real_T   *bpLambda;
  const int32_T  *maxIndex;
} rt_LUTnWorkd;

typedef struct rt_LUTSplineWorkd_tag {
  rt_LUTnWorkd *TWork;
  real_T       *yyA;
  real_T       *yyB;
  real_T       *yy2;
  real_T       *up;
  real_T       *y2;
  const int_T  *numYWorkElts;
} rt_LUTSplineWorkd;

/* single precision variant */

typedef struct rt_LUTnWorkf_tag {
  const int32_T   *dimSizes;
  const real32_T  *tableData;
  real32_T **bpDataSet;
  int32_T   *bpIndex;
  real32_T  *bpLambda;
  const int32_T   *maxIndex;
} rt_LUTnWorkf;

typedef struct rt_LUTSplineWorkf_tag {
  rt_LUTnWorkf *TWork;
  real32_T     *yyA;
  real32_T     *yyB;
  real32_T     *yy2;
  real32_T     *up;
  real32_T     *y2;
  const int_T  *numYWorkElts;
} rt_LUTSplineWorkf;


/***************************************************************
 *                    FULL PRELOOKUP FUNCTIONS                 *
 ***************************************************************/

extern int_T rt_PLookEvnCd(const real_T           u,
                           real_T         * const lambda,
                           const real_T   * const bpData,
                           const int_T            maxIndex);

extern int_T rt_PLookEvnXd(const real_T           u,     
                           real_T         * const lambda,
                           const real_T   * const bpData,
                           const int_T            maxIndex);

extern int_T rt_PLookLinCd(const real_T           u,
                           real_T         * const lambda,
                           const real_T   * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookLinXd(const real_T           u,     
                           real_T         * const lambda,
                           const real_T   * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookBinCd(const real_T           u,
                           real_T         * const lambda,
                           const real_T   * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookBinXd(const real_T           u,     
                           real_T         * const lambda,
                           const real_T   * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookEvnCf(const real32_T         u,
                           real32_T       * const lambda,
                           const real32_T * const bpData,
                           const int_T            maxIndex);

extern int_T rt_PLookEvnXf(const real32_T         u,     
                           real32_T       * const lambda,
                           const real32_T * const bpData,
                           const int_T            maxIndex);

extern int_T rt_PLookLinCf(const real32_T         u,
                           real32_T       * const lambda,
                           const real32_T * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookLinXf(const real32_T         u,     
                           real32_T       * const lambda,
                           const real32_T * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookBinCf(const real32_T         u,
                           real32_T       * const lambda,
                           const real32_T * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);

extern int_T rt_PLookBinXf(const real32_T         u,     
                           real32_T       * const lambda,
                           const real32_T * const bpData,
                           const int_T            maxIndex,
                           const int_T            index0);


/***************************************************************
 *                  K-ONLY PRELOOKUP FUNCTIONS                 *
 ***************************************************************/

extern int_T rt_PLookEvnKCd(const real_T           u,
			    const real_T   * const bpData,
			    const int_T            maxIndex);

extern int_T rt_PLookLinKCd(const real_T           u,
			    const real_T   * const bpData,
			    const int_T            maxIndex,
			    const int_T            index0);

extern int_T rt_PLookBinKCd(const real_T           u,
			    const real_T   * const bpData,
			    const int_T            maxIndex,
			    const int_T            index0);

extern int_T rt_PLookEvnKCf(const real32_T         u,
			    const real32_T * const bpData,
			    const int_T            maxIndex);

extern int_T rt_PLookLinKCf(const real32_T         u,
			    const real32_T * const bpData,
			    const int_T            maxIndex,
			    const int_T            index0);

extern int_T rt_PLookBinKCf(const real32_T         u,
			    const real32_T * const bpData,
			    const int_T            maxIndex,
			    const int_T            index0);


/***************************************************************
 *                   INTERPOLATION FUNCTIONS                   *
 ***************************************************************/

/*--- Routines for use with Interpolation n-D Using PreLook-Up */

extern real_T rt_Intrp1Lind(const int32_T   * const bpIndex,
			    const real_T   * const bpLambda,
			    const real_T   * const T);

extern real_T rt_Intrp2Lind(const int32_T   * const bpIndex,
			    const real_T   * const bpLambda,
			    const real_T   * const T,
			    const int32_T          stride);

extern real_T rt_Intrp3Lind(const int32_T   * const bpIndex,
			    const real_T   * const bpLambda,
			    const real_T   * const T,
			    const int32_T  * const stride);

extern real_T rt_Intrp4Lind(const int32_T   * const bpIndex,
			    const real_T   * const bpLambda,
			    const real_T   * const T,
			    const int32_T  * const stride);

extern real_T rt_Intrp5Lind(const int32_T   * const bpIndex,
			    const real_T   * const bpLambda,
			    const real_T   * const T,
			    const int32_T  * const stride);


extern real32_T rt_Intrp1Linf(const int32_T   * const bpIndex,
			      const real32_T * const bpLambda,
			      const real32_T * const T);

extern real32_T rt_Intrp2Linf(const int32_T   * const bpIndex,
			      const real32_T * const bpLambda,
			      const real32_T * const T,
			      const int32_T          stride);

extern real32_T rt_Intrp3Linf(const int32_T   * const bpIndex,
			      const real32_T * const bpLambda,
			      const real32_T * const T,
			      const int32_T  * const stride);

extern real32_T rt_Intrp4Linf(const int32_T   * const bpIndex,
			      const real32_T * const bpLambda,
			      const real32_T * const T,
			      const int32_T  * const stride);

extern real32_T rt_Intrp5Linf(const int32_T   * const bpIndex,
			      const real32_T * const bpLambda,
			      const real32_T * const T,
			      const int32_T  * const stride);

/*--- Routines for internal use in Look-Up Table, n-D */


extern real_T rt_Intrp1Flatd(const int_T            bpIndex,
                             const real_T           lambda,
                             const real_T   * const tableData);

extern real_T rt_Intrp2Flatd(const int_T    * const bpIndex,
                             const int_T            numRows,
                             const real_T   * const lambda,
                             const real_T   * const tableData);

extern real_T rt_IntrpNFlatd(int_T                     numDims,
                             const rt_LUTnWork * const TWork);

extern real_T rt_IntrpNLind(int_T                     dim,
                            int_T                     offset,
                            const rt_LUTnWork * const TWork);

extern real_T rt_IntrpNSpld(int_T                          numDims,
                            const rt_LUTSplineWork * const splWork,
                            int_T                          extrapMethod);

extern real32_T rt_Intrp1Flatf(const int_T            bpIndex,
                               const real32_T         lambda,
                               const real32_T * const tableData);

extern real32_T rt_Intrp2Flatf(const int_T    * const bpIndex,
                               const int_T            numRows,
                               const real32_T * const lambda,
                               const real32_T * const tableData);

extern real32_T rt_IntrpNFlatf(int_T                     dim,
                               const rt_LUTnWork * const TWork);

extern real32_T rt_IntrpNLinf(int_T                     dim,
                              int_T                     offset,
                              const rt_LUTnWork * const TWork);

extern real32_T rt_IntrpNSplf(int_T                          numDims,
                              const rt_LUTSplineWork * const splWork,
                              int_T                          extrapMethod);

/* 
 *--- Routines for Interpolation n-D using PreLook-Up blocks 
 *    with clipping or extrapolation support.
 */
 
extern real_T rt_Intrp1FlatCd(const int_T            bpIndex,
                              const real_T           lambda,
                              const real_T   * const tableData,
                              const int_T            maxIndex);

extern real_T rt_Intrp2FlatCd(const int_T           bpIndex0,
			      const int_T           bpIndex1,
                              const real_T          lambda0,
                              const real_T          lambda1,
                              const real_T  * const tableData,
                              const int_T           maxIndex0,
                              const int_T           maxIndex1);

extern real_T rt_IntrpNFlatCd(int_T                     numDims,
			      const rt_LUTnWork * const TWork);
 

extern real_T rt_Intrp1LinCd(const int_T            bpIndex,
                             const real_T           lambda,
                             const real_T   * const tableData,
                             const int_T            maxIndex);

extern real_T rt_Intrp2LinCd(const int_T            bpIndex0,
			     const int_T            bpIndex1,
			     const real_T           lambda0,
			     const real_T           lambda1,
			     const real_T   * const tableData,
			     const int_T            maxIndex0,
			     const int_T            maxIndex1);

extern real_T rt_IntrpNLinCd(int_T                     dim,
			     int_T                     offset,
			     const rt_LUTnWork * const TWork);
 
extern real32_T rt_Intrp1FlatCf(const int_T            bpIndex,
				const real32_T           lambda,
				const real32_T   * const tableData,
				const int_T            maxIndex);

extern real32_T rt_Intrp2FlatCf(const int_T           bpIndex0,
				const int_T           bpIndex1,
				const real32_T          lambda0,
				const real32_T          lambda1,
				const real32_T  * const tableData,
				const int_T           maxIndex0,
				const int_T           maxIndex1);

extern real32_T rt_IntrpNFlatCf(int_T                     numDims,
				const rt_LUTnWork * const TWork);
 

extern real32_T rt_Intrp1LinCf(const int_T            bpIndex,
			       const real32_T           lambda,
			       const real32_T   * const tableData,
			       const int_T            maxIndex);

extern real32_T rt_Intrp2LinCf(const int_T            bpIndex0,
			       const int_T            bpIndex1,
			       const real32_T           lambda0,
			       const real32_T           lambda1,
			       const real32_T   * const tableData,
			       const int_T            maxIndex0,
			       const int_T            maxIndex1);

extern real32_T rt_IntrpNLinCf(int_T                     dim,
			       int_T                     offset,
			       const rt_LUTnWork * const TWork);
 

extern real_T rt_Intrp1LinXd(const int_T            bpIndex,
                             const real_T           lambda,
                             const real_T   * const tableData,
                             const int_T            maxIndex);

extern real_T rt_Intrp2LinXd(const int_T            bpIndex0,
			     const int_T            bpIndex1,
			     const real_T           lambda0,
			     const real_T           lambda1,
			     const real_T   * const tableData,
			     const int_T            maxIndex0,
			     const int_T            maxIndex1);

extern real_T rt_IntrpNLinXd(int_T                     dim,
			     int_T                     offset,
			     const rt_LUTnWork * const TWork);
 

extern real32_T rt_Intrp1LinXf(const int_T            bpIndex,
			       const real32_T           lambda,
			       const real32_T   * const tableData,
			       const int_T            maxIndex);

extern real32_T rt_Intrp2LinXf(const int_T            bpIndex0,
			       const int_T            bpIndex1,
			       const real32_T           lambda0,
			       const real32_T           lambda1,
			       const real32_T   * const tableData,
			       const int_T            maxIndex0,
			       const int_T            maxIndex1);

extern real32_T rt_IntrpNLinXf(int_T                     dim,
			       int_T                     offset,
			       const rt_LUTnWork * const TWork);


/***************************************************************
 *                TOP LEVEL LOOK-UP FUNCTIONS                  *
 ***************************************************************/
                      

extern real_T rt_LookFlat1EvnCZd(const real_T u,
				 const real_T * const bpData,
				 const real_T * const tableData,
				 const int_T    maxIndex);


extern real_T rt_LookFlat1EvnCSd(const real_T u,
				 const real_T * const bpData,
				 const real_T * const tableData,
                                 int_T  * const bpIndex,
				 const int_T    maxIndex);


extern real_T rt_LookFlat1LinCZd(const real_T u,
				 const real_T * const bpData,
				 const real_T * const tableData,
				 const int_T    maxIndex);


extern real_T rt_LookFlat1LinCSd(const real_T u,
				 const real_T * const bpData,
				 const real_T * const tableData,
                                 int_T  * const bpIndex,
				 const int_T    maxIndex);


extern real_T rt_LookFlat1BinCZd(const real_T u,
				 const real_T * const bpData,
				 const real_T * const tableData,
				 const int_T    maxIndex);


extern real_T rt_LookFlat1BinCSd(const real_T u,
				 const real_T * const bpData,
				 const real_T * const tableData,
                                 int_T  * const bpIndex,
				 const int_T    maxIndex);


extern real_T rt_LookFlat2EvnCZd(const real_T         u0,
				 const real_T         u1,
				 const real_T * const bpData01,
				 const real_T * const bpData02,
				 const real_T * const tableData,
				 const int_T  * const maxIndex);


extern real_T rt_LookFlat2EvnCSd(const real_T         u0,
				 const real_T         u1,
				 const real_T * const bpData01,
				 const real_T * const bpData02,
				 const real_T * const tableData,
				 int_T  * const bpIndex,
				 const int_T  * const maxIndex);


extern real_T rt_LookFlat2LinCZd(const real_T         u0,
				 const real_T         u1,
				 const real_T * const bpData01,
				 const real_T * const bpData02,
				 const real_T * const tableData,
				 const int_T  * const maxIndex);


extern real_T rt_LookFlat2LinCSd(const real_T         u0,
				 const real_T         u1,
				 const real_T * const bpData01,
				 const real_T * const bpData02,
				 const real_T * const tableData,
				 int_T  * const bpIndex,
				 const int_T  * const maxIndex);


extern real_T rt_LookFlat2BinCZd(const real_T         u0,
				 const real_T         u1,
				 const real_T * const bpData01,
				 const real_T * const bpData02,
				 const real_T * const tableData,
				 const int_T  * const maxIndex);


extern real_T rt_LookFlat2BinCSd(const real_T         u0,
				 const real_T         u1,
				 const real_T * const bpData01,
				 const real_T * const bpData02,
				 const real_T * const tableData,
				 int_T  * const bpIndex,
				 const int_T  * const maxIndex);


extern real_T rt_LookFlatNEvnCZd(int_T                numDims,
				 const real_T * u,
				 rt_LUTnWork  * TWork);


extern real_T rt_LookFlatNEvnCSd(int_T                numDims,
				 const real_T * u,
				 rt_LUTnWork  * TWork);


extern real_T rt_LookFlatNLinCZd(int_T                numDims,
				 const real_T * u,
				 rt_LUTnWork  * TWork);


extern real_T rt_LookFlatNLinCSd(int_T                numDims,
				 const real_T * u,
				 rt_LUTnWork  * TWork);


extern real_T rt_LookFlatNBinCZd(int_T                numDims,
				 const real_T * u,
				 rt_LUTnWork  * TWork);


extern real_T rt_LookFlatNBinCSd(int_T                numDims,
				 const real_T * u,
				 rt_LUTnWork  * TWork);


extern real_T rt_LookLin1EvnCZd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				const int_T    maxIndex);


extern real_T rt_LookLin1EvnXZd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				const int_T    maxIndex);


extern real_T rt_LookLin1EvnCSd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T    maxIndex);


extern real_T rt_LookLin1EvnXSd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T    maxIndex);


extern real_T rt_LookLin1LinCZd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				const int_T    maxIndex);


extern real_T rt_LookLin1LinXZd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				const int_T    maxIndex);


extern real_T rt_LookLin1LinCSd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T    maxIndex);


extern real_T rt_LookLin1LinXSd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T    maxIndex);


extern real_T rt_LookLin1BinCZd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				const int_T    maxIndex);


extern real_T rt_LookLin1BinXZd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				const int_T    maxIndex);


extern real_T rt_LookLin1BinCSd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T    maxIndex);


extern real_T rt_LookLin1BinXSd(const real_T u,
				const real_T * const bpData,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T    maxIndex);


extern real_T rt_LookLin2EvnCZd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2EvnXZd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2EvnCSd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2EvnXSd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2LinCZd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2LinXZd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2LinCSd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2LinXSd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2BinCZd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2BinXZd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2BinCSd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T  * const maxIndex);


extern real_T rt_LookLin2BinXSd(const real_T         u0,
				const real_T         u1,
				const real_T * const bpData01,
				const real_T * const bpData02,
				const real_T * const tableData,
				int_T  * const bpIndex,
				const int_T  * const maxIndex);


extern real_T rt_LookLinNEvnCZd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNEvnXZd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNEvnCSd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNEvnXSd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNLinCZd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNLinXZd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNLinCSd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNLinXSd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNBinCZd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNBinXZd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNBinCSd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookLinNBinXSd(int_T                numDims,
				const real_T * u,
				rt_LUTnWork  * TWork);


extern real_T rt_LookSplNEvnCZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNEvnXZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNEvnSZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNEvnCSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNEvnXSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNEvnSSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNLinCZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNLinXZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNLinSZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNLinCSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNLinXSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNLinSSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNBinCZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNBinXZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNBinSZd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNBinCSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNBinXSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real_T rt_LookSplNBinSSd(int_T                numDims,
				const real_T * u,
				rt_LUTSplineWork  * SWork);


extern real32_T rt_LookFlat1EvnCZf(const real32_T u,
				   const real32_T * const bpData,
				   const real32_T * const tableData,
				   const int_T    maxIndex);


extern real32_T rt_LookFlat1EvnCSf(const real32_T u,
				   const real32_T * const bpData,
				   const real32_T * const tableData,
				   int_T  * const bpIndex,
				   const int_T    maxIndex);


extern real32_T rt_LookFlat1LinCZf(const real32_T u,
				   const real32_T * const bpData,
				   const real32_T * const tableData,
				   const int_T    maxIndex);


extern real32_T rt_LookFlat1LinCSf(const real32_T u,
				   const real32_T * const bpData,
				   const real32_T * const tableData,
				   int_T  * const bpIndex,
				   const int_T    maxIndex);


extern real32_T rt_LookFlat1BinCZf(const real32_T u,
				   const real32_T * const bpData,
				   const real32_T * const tableData,
				   const int_T    maxIndex);


extern real32_T rt_LookFlat1BinCSf(const real32_T u,
				   const real32_T * const bpData,
				   const real32_T * const tableData,
				   int_T  * const bpIndex,
				   const int_T    maxIndex);


extern real32_T rt_LookFlat2EvnCZf(const real32_T         u0,
				   const real32_T         u1,
				   const real32_T * const bpData01,
				   const real32_T * const bpData02,
				   const real32_T * const tableData,
				   const int_T  * const maxIndex);


extern real32_T rt_LookFlat2EvnCSf(const real32_T         u0,
				   const real32_T         u1,
				   const real32_T * const bpData01,
				   const real32_T * const bpData02,
				   const real32_T * const tableData,
				   int_T  * const bpIndex,
				   const int_T  * const maxIndex);


extern real32_T rt_LookFlat2LinCZf(const real32_T         u0,
				   const real32_T         u1,
				   const real32_T * const bpData01,
				   const real32_T * const bpData02,
				   const real32_T * const tableData,
				   const int_T  * const maxIndex);


extern real32_T rt_LookFlat2LinCSf(const real32_T         u0,
				   const real32_T         u1,
				   const real32_T * const bpData01,
				   const real32_T * const bpData02,
				   const real32_T * const tableData,
				   int_T  * const bpIndex,
				   const int_T  * const maxIndex);


extern real32_T rt_LookFlat2BinCZf(const real32_T         u0,
				   const real32_T         u1,
				   const real32_T * const bpData01,
				   const real32_T * const bpData02,
				   const real32_T * const tableData,
				   const int_T  * const maxIndex);


extern real32_T rt_LookFlat2BinCSf(const real32_T         u0,
				   const real32_T         u1,
				   const real32_T * const bpData01,
				   const real32_T * const bpData02,
				   const real32_T * const tableData,
				   int_T  * const bpIndex,
				   const int_T  * const maxIndex);


extern real32_T rt_LookFlatNEvnCZf(int_T                numDims,
				   const real32_T * u,
				   rt_LUTnWork  * TWork);


extern real32_T rt_LookFlatNEvnCSf(int_T                numDims,
				   const real32_T * u,
				   rt_LUTnWork  * TWork);


extern real32_T rt_LookFlatNLinCZf(int_T                numDims,
				   const real32_T * u,
				   rt_LUTnWork  * TWork);


extern real32_T rt_LookFlatNLinCSf(int_T                numDims,
				   const real32_T * u,
				   rt_LUTnWork  * TWork);


extern real32_T rt_LookFlatNBinCZf(int_T                numDims,
				   const real32_T * u,
				   rt_LUTnWork  * TWork);


extern real32_T rt_LookFlatNBinCSf(int_T                numDims,
				   const real32_T * u,
				   rt_LUTnWork  * TWork);


extern real32_T rt_LookLin1EvnCZf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1EvnXZf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1EvnCSf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1EvnXSf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1LinCZf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1LinXZf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1LinCSf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1LinXSf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1BinCZf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1BinXZf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1BinCSf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T    maxIndex);


extern real32_T rt_LookLin1BinXSf(const real32_T u,
				  const real32_T * const bpData,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T    maxIndex);


extern real32_T rt_LookLin2EvnCZf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2EvnXZf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2EvnCSf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2EvnXSf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2LinCZf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2LinXZf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2LinCSf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2LinXSf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2BinCZf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2BinXZf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2BinCSf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLin2BinXSf(const real32_T         u0,
				  const real32_T         u1,
				  const real32_T * const bpData01,
				  const real32_T * const bpData02,
				  const real32_T * const tableData,
				  int_T  * const bpIndex,
				  const int_T  * const maxIndex);


extern real32_T rt_LookLinNEvnCZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNEvnXZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNEvnCSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNEvnXSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNLinCZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNLinXZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNLinCSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNLinXSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNBinCZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNBinXZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNBinCSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookLinNBinXSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTnWork  * TWork);


extern real32_T rt_LookSplNEvnCZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNEvnXZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNEvnSZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNEvnCSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNEvnXSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNEvnSSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNLinCZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNLinXZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNLinSZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNLinCSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNLinXSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNLinSSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNBinCZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNBinXZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNBinSZf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNBinCSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNBinXSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);


extern real32_T rt_LookSplNBinSSf(int_T                numDims,
				  const real32_T * u,
				  rt_LUTSplineWork  * SWork);



#endif  /* rtlooksrc_h */
