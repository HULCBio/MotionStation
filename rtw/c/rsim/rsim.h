/*
 * Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rsim.h
 *
 *  $RCSfile: rsim.h,v $
 *  $Revision: 1.12.4.1 $
 *  $Date: 2002/10/26 16:12:26 $
 *
 * Abstract:
 *	Data structures used with the RSIM from file and from workspace block
 *      handling.
 *
 * Requires include files
 *	tmwtypes.h
 *	simstruc_type.h
 * Note including simstruc.h before rsim.h is sufficient because simstruc.h
 * includes both tmwtypes.h and simstruc_types.h.
 */

#ifndef __RSIM_H__
#define __RSIM_H__

/*=========*
 * Defines *
 *=========*/

#define RUN_FOREVER -1.0

#define QUOTE1(name) #name
#define QUOTE(name) QUOTE1(name)    /* need to expand name    */

#ifndef SAVEFILE
# define MATFILE2(file) #file ".mat"
# define MATFILE1(file) MATFILE2(file)
# define MATFILE MATFILE1(MODEL)
#else
# define MATFILE QUOTE(SAVEFILE)
#endif

/*==========*
 * Typedefs *
 *==========*/

/* File Name Pairs for To File, From File blocks */
typedef struct {
    const char *inputString;
    char       *oldName;
    const char *newName;
    int_T      remapped; /* Used to verify that name was remapped */
} FNamePair;


/* From File Info (one per from file block) */
typedef struct {
    const char  *origFileName;
    const char  *newFileName;
    int         originalWidth;
    int         nptsTotal;
    int         nptsPerSignal;
    double      *tuDataMatrix;
} FrFInfo;


/* From Workspace Info (one per from workspace block) */
typedef struct {
    const char *origWorkspaceVarName;
    DTypeId    origDataTypeId;
    int        origIsComplex;
    int        origWidth;
    int        origElSize;
    int        nDataPoints;
    double     *time;   /* time vector must be double */
    void       *data;   /* data vector can be any type including complex */
} FWksInfo;

#define NUM_DATA_TYPES (9)

/* Information associated with parameters of a given data type */
typedef struct {
    /* data attributes */
    int  dataType;
    bool complex;
    int  dtTransIdx;
    int  elSize; /* for debugging */
    
    /* data */
    int  nEls;
    void *rVals;
    void *iVals;
} DTParamInfo;

/* Optionally one for the model */
typedef struct {
    int     errFlag;
    int     numParams;   /* total number of params                   */
    double  checksum[4]; /* model checksum                           */

    int         nTrans;    
    DTParamInfo *dtParamInfo;
} PrmStructData;


extern const char *rt_ReadFromfileMatFile(const char *origFileName, 
                                          int originalWidth,
                                          FrFInfo *frFInfo);
extern const char *rt_ReadFromWorkspaceMatFile(FWksInfo *fwksInfo);
extern const char *rt_ReadParamStructureMatfile(PrmStructData **prmStructOut,
                                                int           cellParamIndex);
extern void       rt_RSimRemapToFileName(const char **fileName);
extern void rt_FreeRSimParamStructs(PrmStructData *paramStructure);
extern void rsimLoadSolverOpts(SimStruct* S);

#endif /* __RSIM_H__ */
