/*
 * $Revision: 1.6.4.5 $
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h"
#include "dt_info.h"

#include "rsim.h"
#include "rsim_sup.h"

#include "ext_work.h"

/*=============*
 * Global data *
 *=============*/

/*
 * File name mapping pairs (old=new) for To File, From File blocks.
 */
FNamePair *gblFrFNamepair = NULL;
FNamePair *gblToFNamepair = NULL;

/* Memory allocation error is used by blocks in generated code */
const char *RT_MEMORY_ALLOCATION_ERROR = "memory allocation error";

/*
 * Global data for command line arguments
 */
static const char gblFromWorkspaceFilenameDefault[] = "from_workspace.mat";
static int_T      gblVerbose                        = 0;

const char   *gblFromWorkspaceFilename = gblFromWorkspaceFilenameDefault;
const char   *gblMatLoggingFilename    = NULL;

const char   *gblParamFilename         = NULL;
int           gblParamCellIndex        = -1;

const char   *gblSolverOptsFilename    = NULL;
int           gblSolverOptsArrIndex    = -1;

double       gblFinalTime              = -2.0;  /* not specified */
int          gblTimeLimit              = -1; /* not specified */

/*=================================*
 * External data setup by rsim.tlc *
 *=================================*/
extern const int_T   gblNumFrFiles;
extern const int_T   gblNumToFiles;
extern const int_T   gblNumFrWksBlocks;

/*===========*
 * Constants *
 *===========*/

static const char UsageMsg[] =
"Rapid Simulation Target usage: modelname [switches]\n"
"  switches:\n"
"    -f <originalFromFile.mat=newFromFile.mat>\n"
"            Name of original input MAT-file and replacement input MAT-file\n"
"            containing TU matrix for \"From File\" block.\n"
"    -o <results.mat>\n"
"            Name of output MAT-file for MAT-file logging of simulation data\n"
"            (time,states,root outports).\n"
"    -p <parameters.mat>\n"
"            Name of new \"Parameter\" MAT-file containing new block parameter\n"
"            vector \"rtP\".\n"
"    -s,-tf <stopTime>\n"
"            Final time value to end simulation.\n"
"    -S <solver_options.mat>\n"
"            Load new solver options (e.g., Solver, RelTol, AbsTol, etc)\n"
"    -L timeLimit\n"
"            Exit if run time (in seconds) of the program exceeds timeLimit\n"
"    -t <originalToFile.mat=newToFile.mat>\n"
"            Name of original destination file and new destination file\n"
"            for results from a \"To File\" block.\n"
"    -w      Waits for Simulink to start model in External Mode.\n"
"    -port <TCPport>\n"
"            Overrides 17725 default port for External Mode,\n"
"            valid range 256 to 65535.\n";

static const char ObsoleteMsg[] =
"The -s switch is now obsolete and will be removed from a future version.\n"
"Please use the -tf switch in place of -s.\n";

/* Function: FreeFNamePairList ================================================
 * Abstract:
 *	Free name pair lists.
 */
static void FreeFNamePairList(FNamePair *list, int_T len)
{
    if (list != NULL) {
        int_T i;
        for (i = 0; i < len; i++) {
            if (list[i].oldName != NULL) free(list[i].oldName);
        }
        free(list);
    }

} /* end FreeFFnameList */


/* Function: FreeGbls ========================================================
 * Abstract:
 *	Free global memory prior to exit
 */
void FreeGbls(void)
{
    FreeFNamePairList(gblToFNamepair, gblNumToFiles);
    FreeFNamePairList(gblFrFNamepair, gblNumFrFiles);

} /* end FreeGbls */


/* Function: CheckRemappings ==================================================
 * Abstract:
 *	Verify that the FromFile switches were used
 *
 * Returns:
 *	NULL     - success
 *	non-NULL - error message
 */
const char *CheckRemappings(void)
{
    int_T i;

    for (i = 0; i < gblNumFrFiles; i++) {
        if (gblFrFNamepair[i].oldName != NULL && gblFrFNamepair[i].remapped==0){
            return("one or more -f switches from file names do not exist in "
                   "the model");
        }
    }

    for (i = 0; i < gblNumToFiles; i++) {
        if (gblToFNamepair[i].oldName != NULL && gblToFNamepair[i].remapped==0){
            return("one or more -t switches from file names do not exist in "
                   "the model");
        }
    }
    return(NULL);

} /* end CheckRemappings */


/* Function: SplitFileNamepair =================================================
 *
 * Abstract:
 *           This function splits an input string into two parts.
 *           The input file-name-pair would appear as follows:
 *
 *                origname.mat=replacement.mat
 *
 *           The first  portion of the string contains the original file name.
 *           This is followed by an "=" equal sign, no spaces allowed!
 *           Then, the string following the equal sign will contain
 *           the replacement file name.
 *
 * Inputs:   struct FNamePair fileNamePair.inputString
 * Outputs:  returns struct "fileNames" with fields containing:
 *           - fileNamePair.oldName
 *           - fileNamePair.newName
 *
 */
static const char *SplitFileNamepair(FNamePair *fileNamePair)
{
    const char *pairStr = fileNamePair->inputString;
    const char *eq      = strchr(pairStr, '=');
    size_t     oldLen;

    if (eq == NULL) {
        return("invalid file remapping argument specified (no \"=\" found)");
    }

    /*LINTED E_CAST_INT_TO_SMALL_INT */
    oldLen = (size_t)(eq - pairStr);

    if ((fileNamePair->oldName = (char*)malloc(oldLen+1)) == NULL) {
        return("memory allocation error (SplitFileNamepair)");
    }

    (void)strncpy(fileNamePair->oldName,pairStr,oldLen);
    fileNamePair->oldName[oldLen] = '\0';

    fileNamePair->newName = eq+1;

    if (fileNamePair->newName[0] == '\0') {
        return("invalid file remapping argument specified (no new name found)");
    }

    return(NULL);

}  /* end SplitFileNamepair */


/* Function: ParseArgs ========================================================
 * Abstract:
 *	Parse the command-line arguments: valid args:
 *       -f     = Fromfile block name pair for reading "from file" data
 *       -o     = Output file for matfile logging
 *       -p     = Param file for new rtP vector
 *       -s,-tf = Stop time for ending simulation
 *       -t     = Tofile name pair so saving "to file" data
 *
 *  Example:
 *       f14 -p mydata -o myoutfile -s 10.1 -f originfile.mat=newinfile.mat
 *           -t origtofile=newtofile.mat
 *
 *  This results as follows:
 *       - sets data structures to run model f14
 *       - "-p" option loads new rtP param vector from "mydata.mat"
 *       - "-o" saves stand-alone simulation results to "mydata.mat"
 *              instead of saving to "f14.mat"
 *       - "-s" results in simulation stopping at t=10.1 seconds.
 *       - "-f" replaces the input matfile name for all instances of  fromfile
 *              blocks that had the original name: "originfile.mat" with the
 *              replacement name: "newinfile.mat".
 *       - "-t" similar to -f option except swapping names of to file blocks.
 *
 *  Returns:
 *	NULL     - success
 *	non-NULL - error message
 */
const char *ParseArgs(int_T argc, char_T *argv[])
{
    int_T      tvar;
    int_T      optLen           = 0;
    int_T      toFNamepairIdx   = 0;
    int_T      frFNamepairIdx   = 0;
    const char *result          = NULL; /* assume success */

    /*
     * In TLC, when using RSim, we need to define variables:
     * gblNumToFiles and gblNumFrFiles -- even if the number of
     * such blocks is zero. This allows to parser to flag the user if
     * an attempt is made to provide a new file for a type of block
     * that is not used in the current model.
     */

    /*
     * If any "to file" or "from file" blocks exist, we must allocate
     * memory for "to file" and "from file" namepairs even if the
     * file names remain unchanged from the original file names.
     */
     if (gblNumToFiles>0) {
         gblToFNamepair = (FNamePair*)calloc(gblNumToFiles,sizeof(FNamePair));
         if (gblToFNamepair==NULL) {
             result = "memory allocation error (gblToFNamepair)";
             goto EXIT_POINT;
         }
     }

     if (gblNumFrFiles>0) {
         gblFrFNamepair = (FNamePair*)calloc(gblNumFrFiles,sizeof(FNamePair));
         if (gblFrFNamepair==NULL) {
             result = "memory allocation error (gblFrFNamepair)";
             goto EXIT_POINT;
         }
     }

     /*
      * Warn user about -s being obsoleted in a future version (it still gets
      * processed as normal for now).
      */
     for (tvar = 1; tvar < argc; tvar++) {

         if (strcmp(argv[tvar], "-s") == 0) {
             printf("%s", ObsoleteMsg);
         }
     }

     /*
      * Convert any -tf arguments to -s.
      */
     for (tvar = 1; tvar < argc; tvar++) {

         if (strcmp(argv[tvar], "-tf") == 0) {
             argv[tvar][1] = 's';
             argv[tvar][2] = '\0';
         }
     }

     for (tvar = 1; tvar < argc; tvar++) { /* check list of input args */

         if (argv[tvar][0] == '-') {       /* expect an option to follow "-" */
             optLen = strlen( argv[tvar] );
             if (optLen == 1) {
                 result = UsageMsg;
                 goto EXIT_POINT;
             }

             /*
              * Skip arguments which are greater than 2 chars in length.
              */
             if (optLen != 2) {
                 continue;
             }

             switch(argv[tvar][1]) {

               case 'f':  /* FromFile */
                 /*  Syntax:   -f oldfile.mat=newfile.mat
                  *
                  *  This allows a new input file "newName.mat" to replace the
                  *  original input file "oldName.mat" provided data dimensions
                  *  and data types are compatible.
                  *
                  *  If "oldname.mat" does not exist, we error out.
                  */
                 if( (tvar + 1 ) == argc || argv[tvar+1][0] == '-') {
                     result = UsageMsg;
                     goto EXIT_POINT;
                 }

                 if (frFNamepairIdx == gblNumFrFiles) {
                     result = "too many -f switches were specified";
                     goto EXIT_POINT;
                 }

                 gblFrFNamepair[frFNamepairIdx].inputString = argv[tvar+1];
                 if ((result =
                      SplitFileNamepair(&gblFrFNamepair[frFNamepairIdx])) !=
                     NULL) {
                     goto EXIT_POINT;
                 }
                 frFNamepairIdx++; /* another name pair */

                 /*
                  * Set the current argument to NULL, advance the pointer
                  * to the next argument, and NULL it out as well.  We need
                  * to NULL out processed arguments so external mode will
                  * ignore them.
                  */
                 argv[tvar++] = NULL;
                 argv[tvar]   = NULL;
                 break;

               case 'o':  /* OutputFile */
                 /* Syntax: -o filename.mat
                  *
                  * From argv, get OutputFile name for saving matfile
                  * logging data. The default output file name
                  * is <modelname>.mat.
                  *
                  * Only only -o switch is allowed.
                  */
                 if( (tvar + 1 ) == argc || argv[tvar+1][0] == '-') {
                     result = UsageMsg;
                     goto EXIT_POINT;
                 }
                 if (gblMatLoggingFilename != NULL) {
                     result = "only one -o switch is allowed\n";
                     goto EXIT_POINT;
                 }

                 gblMatLoggingFilename = argv[tvar+1];

                /*
                 * Set the current argument to NULL, advance the pointer
                 * to the next argument, and NULL it out as well.  We need
                 * to NULL out processed arguments so external mode will
                 * ignore them.
                 */
                 argv[tvar++] = NULL;
                 argv[tvar]   = NULL;
                 break;

	      case 'p':  /* Param File */
                /*
                 * Syntax: -p paramfile.mat@3
                 *
                 *  From argv, get the input string containing Param file
                 *  name. This file should contain a new "rtP" parameter
                 *  vector with a completely new parameter vector.
                 *
                 *  Only one occurence of -p paramfile.mat is valid.
                 */
                if( (tvar + 1 ) == argc || argv[tvar+1][0] == '-') {
                    result = UsageMsg;
                    goto EXIT_POINT;
                }

                if (gblParamFilename != NULL) {
                    result = "only one -p switch is allowed\n";
                    goto EXIT_POINT;
                }

                /*
                 * Put name of file containing parameter structure into
                 * a global variable. Once the name is non-NULL, RSim
                 * will plan on reading the MAT-file and replacing
                 * the rtP structure with a new parameter set
                 */
                gblParamFilename = argv[tvar+1];

                /*
                 * Now look for any '@' symbol and read gblParamCellIndex
                 */
                {
                    char* tmpStr = (char*)strchr(gblParamFilename, '@');
                    if (tmpStr != NULL) {
                        char dumStr[2];
                        if ( sscanf(tmpStr+1, "%d%1s",
                                    &gblParamCellIndex, dumStr) != 1 ||
                             gblParamCellIndex < 0 ) {
                            result = UsageMsg;
                            goto EXIT_POINT;
                        }
                        tmpStr[0] = '\0';
                    }
                }

                /*
                 * Set the current argument to NULL, advance the pointer
                 * to the next argument, and NULL it out as well.  We need
                 * to NULL out processed arguments so external mode will
                 * ignore them.
                 */
                argv[tvar++] = NULL;
                argv[tvar]   = NULL;
                break;

              case 's':  /* Stop Time */
                /* Syntax: -s <time>, -tf <time>
                 *
                 * From argv, get the final time value when the simulation
                 * will end.
                 */
                if( (tvar + 1 ) == argc || ( argv[tvar+1][0] == '-')  ) {
                    result = UsageMsg;
                    goto EXIT_POINT;
                }

                if (gblFinalTime != -2.0) {
                    result = "only one -s or -tf switch is allowed\n";
                    goto EXIT_POINT;
                }

                {
                    char_T str2[200], tmpstr[2];

                    sscanf(argv[tvar+1],"%200s",str2);
                    if (strcmp(str2, "inf") == 0) {
                        gblFinalTime = RUN_FOREVER;
                    } else {
                        if ((sscanf(str2,"%lf%1s",&gblFinalTime,tmpstr) != 1) ||
                            (gblFinalTime < 0.0) ) {
                            result = "invalid -s or -tf switch argument "
                                "specified.  stop time must be a real, "
                                "positive value or inf\n";
                            goto EXIT_POINT;
                        }
                    }
                }

                /*
                 * Set the current argument to NULL, advance the pointer
                 * to the next argument, and NULL it out as well.  We need
                 * to NULL out processed arguments so external mode will
                 * ignore them.
                 */
                argv[tvar++] = NULL;
                argv[tvar]   = NULL;
                break;

	      case 'S':  /* Solver options */
                /*
                 * Syntax: -S solver_opts.mat@3
                 *
                 *  From argv, get the input string containing solver options
                 *  file name.
                 *
                 *  Only one occurence of -S solver_opts.mat is valid.
                 */
                if( (tvar + 1 ) == argc || argv[tvar+1][0] == '-') {
                    result = UsageMsg;
                    goto EXIT_POINT;
                }

                if (gblSolverOptsFilename != NULL) {
                    result = "only one -S switch is allowed\n";
                    goto EXIT_POINT;
                }

                /*
                 * Put name of file containing parameter structure into
                 * a global variable. Once the name is non-NULL, RSim
                 * will plan on reading the MAT-file and replacing
                 * the rtP structure with a new parameter set
                 */
                gblSolverOptsFilename = argv[tvar+1];

                /*
                 * Now look for any '@' symbol and read gblSolverOptsArrIndex
                 */
                {
                    char* tmpStr = (char*)strchr(gblSolverOptsFilename, '@');
                    if (tmpStr != NULL) {
                        char dumStr[2];
                        if ( sscanf(tmpStr+1, "%d%1s",
                                    &gblSolverOptsArrIndex, dumStr) != 1 ||
                             gblSolverOptsArrIndex < 0 ) {
                            result = UsageMsg;
                            goto EXIT_POINT;
                        }
                        tmpStr[0] = '\0';
                    }
                }

                /*
                 * Set the current argument to NULL, advance the pointer
                 * to the next argument, and NULL it out as well.  We need
                 * to NULL out processed arguments so external mode will
                 * ignore them.
                 */
                argv[tvar++] = NULL;
                argv[tvar]   = NULL;
                break;

              case 'L':  /* Stop Time */
                /* Syntax: -L <timeLimit>
                 *
                 */
                if( (tvar + 1 ) == argc || ( argv[tvar+1][0] == '-')  ) {
                    result = UsageMsg;
                    goto EXIT_POINT;
                }

                if (gblTimeLimit != -1.0) {
                    result = "only one -L switch is allowed\n";
                    goto EXIT_POINT;
                }

                {
                    char_T str2[200], tmpstr[2];

                    sscanf(argv[tvar+1],"%200s",str2);
                    if ( (sscanf(str2,"%d%1s",&gblTimeLimit,tmpstr) != 1) ||
                         (gblTimeLimit <= 0) ) {
                        result = "invalid -L switch argument specified.\n"
                            "Run time limit must be a positive integer\n";
                        goto EXIT_POINT;
                    }
                }

                /*
                 * Set the current argument to NULL, advance the pointer
                 * to the next argument, and NULL it out as well.  We need
                 * to NULL out processed arguments so external mode will
                 * ignore them.
                 */
                argv[tvar++] = NULL;
                argv[tvar]   = NULL;
                break;

              case 't':  /* ToFile */
                /*
                 * Get the input string containing a "To File" name pair, for
                 *  example:   -t oldfile.mat=newfile.mat
                 *  The "newfile.mat" will be used as a replacement for the
                 *  original output filename "oldname.mat" so multiple runs
                 *  can be made without overwriting output files.
                 */
                if( (tvar + 1 ) == argc || argv[tvar+1][0] == '-') {
                    result = UsageMsg;
                    goto EXIT_POINT;
                }

                if (toFNamepairIdx == gblNumToFiles) {
                    result = "too many -t switches were specified";
                    goto EXIT_POINT;
                }

                gblToFNamepair[toFNamepairIdx].inputString = argv[tvar+1];
                if ((result =
                     SplitFileNamepair(&gblToFNamepair[toFNamepairIdx])) !=
                    NULL) {
                    goto EXIT_POINT;
                }
                toFNamepairIdx++; /* another name pair */

                /*
                 * Set the current argument to NULL, advance the pointer
                 * to the next argument, and NULL it out as well.  We need
                 * to NULL out processed arguments so external mode will
                 * ignore them.
                 */
                argv[tvar++] = NULL;
                argv[tvar]   = NULL;
                break;

               case 'v': /* Verbose switch */
                /* Syntax: -v
                *
                *  Turn on the global verbose flag.
                */
                if (gblVerbose != 0) {
                    result = "only one -v switch is allowed";
                    goto EXIT_POINT;
                }
                gblVerbose = 1;

                /*
                 * Set the current argument to NULL.  We need to NULL out
                 * processed arguments so external mode will ignore them.
                 */
                argv[tvar] = NULL;
                break;

              default:
                break;
             }
         }
     } /* end parse loop */

     /*
      * Check for external mode arguments.
      */
     rtExtModeParseArgs(argc, (const char_T **) argv, NULL);

     /*
      * Check for unprocessed ("unhandled") args.
      */
     {
         int i;
         for (i=1; i<argc; i++) {
             if (argv[i] != NULL) {
                 result = UsageMsg;
                 goto EXIT_POINT;
             }
         }
     }

     if (gblMatLoggingFilename == NULL)  {
         gblMatLoggingFilename = MATFILE; /* default is model.mat */
     }

    /* Check that none of the new "To File" output filenames  
     * is the same as the output file name 
     * Also check that none of the new "To File" output filenames
     * is mapped assigned to different old "To File" output filenames  
     */
     
     {
         int i,j;
         for (i = 0; i < toFNamepairIdx; i++ ) {  
             if(strcmp(gblMatLoggingFilename,gblToFNamepair[i].newName) == 0){
                 result = " 'To File' filename cannot be the same as output filename of the model";
                 goto EXIT_POINT;
                 
             }
         }
         for (j = i+1; j <  toFNamepairIdx; j++ ){
             if(strcmp(gblToFNamepair[i].oldName, gblToFNamepair[j].oldName) == 0){
                 (void)printf("'To File' filename '%s' is replaced more than once with the -t option\n",
                              gblToFNamepair[j].oldName);
                 result = "'Multiple replacement of 'To File' filenames is not allowed\n";
                 goto EXIT_POINT; 
             }
             
             if(strcmp(gblToFNamepair[i].newName, gblToFNamepair[j].newName) == 0){
                 (void)printf("'To File' filename replacement '%s' is used more than once with the -t option\n",
                              gblToFNamepair[j].newName);
                 result = "All 'To File' filenames must be  unique\n";
                 goto EXIT_POINT; 
             }
         }   
     }
     
     if (gblVerbose) {
         int_T i;
         if (gblParamFilename != NULL) {
             (void)printf("** Reading paramters");
             if (gblParamCellIndex != -1) {
                 (void)printf(" at cell array index %d", gblParamCellIndex);
             }
             (void)printf(" from file \"%s\"\n", gblParamFilename);
         } else {
             (void)printf("** Using default model parameters (no parameter "
                          "file specified)\n");
         }

         if (gblSolverOptsFilename != NULL) {
             (void)printf("** Reading solver options");
             if (gblSolverOptsArrIndex != -1) {
                 (void)printf(" at array index %d",gblSolverOptsArrIndex);
             }
             (void)printf(" from file \"%s\"\n", gblSolverOptsFilename);
         } else {
             (void)printf("** Using solver options specified on the model "
                          "(no solver options file specified)\n");
         }

         if (gblFinalTime != -2.0) {
             if (gblFinalTime == RUN_FOREVER) {
                 (void)printf("** Setting stop time to infinity.\n");
             } else {
                 (void)printf("** Stop time = %.16g\n", gblFinalTime);
             }
         }

         (void)printf("** Output filename = %s\n", gblMatLoggingFilename);

         for (i=0; i < toFNamepairIdx; i++) {
             (void)printf("** Replacing ToFile \"%s\" with \"%s\"\n",
                          gblToFNamepair[i].oldName,
                          gblToFNamepair[i].newName);
         }

         for (i=0; i < frFNamepairIdx; i++) {
             (void)printf("** Replacing FromFile \"%s\" with \"%s\"\n",
                          gblFrFNamepair[i].oldName,
                          gblFrFNamepair[i].newName);
         }
     }

 EXIT_POINT:
     return(result);

} /* end ParseArgs */

/* Function: ReplaceRtP ========================================================
 * Abstract
 *  Initialize the rtP structure using the parameters from the specified
 *  'paramStructure'.  The 'paramStructure' contains parameter info that was
 *  read from a mat file (see rsim_mat.c/rt_ReadParamStructureMatfile).
 */
static const char *ReplaceRtP(const SimStruct *S,
                              const PrmStructData *paramStructure)
{
    int                     i;
    const char              *errStr        = NULL;
    const DTParamInfo       *dtParamInfo   = paramStructure->dtParamInfo;
    int                     nTrans         = paramStructure->nTrans;
    const DataTypeTransInfo *dtInfo        = (const DataTypeTransInfo *)ssGetModelMappingInfo(S);
    DataTypeTransitionTable *dtTable       = dtGetParamDataTypeTrans(dtInfo);
    uint_T                  *dataTypeSizes = dtGetDataTypeSizes(dtInfo);

    for (i=0; i<nTrans; i++) {
        int  dataTransIdx  = dtParamInfo[i].dtTransIdx;
        char *transAddress = dtTransGetAddress(dtTable, dataTransIdx);
        bool complex       = (bool)dtParamInfo[i].complex;
        int  dataType      = dtParamInfo[i].dataType;
        int  dtSize        = (int)dataTypeSizes[dataType];
        int  nEls          = dtParamInfo[i].nEls;

        /*
         * Check for consistent element size.  dtParamInfo->elSize is the size
         * as stored in the parameter mat-file.  This should match the size
         * used by the generated code (i.e., stored in the SimStruct).
         */
        if (dtParamInfo[i].elSize != dtSize) {
            errStr = "Parameter data type sizes in MAT-file not same "
                "as data type sizes in RTW generated code";
            goto EXIT_POINT;
        }

        if (!complex) {
            (void)memcpy(transAddress,dtParamInfo[i].rVals,nEls*dtSize);
        } else {
            /*
             * Must interleave the real and imaginary parts.  Simulink style.
             */
            int  j;
            char *dst     = transAddress;
            const char *realSrc = (const char *)dtParamInfo[i].rVals;
            const char *imagSrc = (const char *)dtParamInfo[i].iVals;

            for (j=0; j<nEls; j++) {
                /* Copy real part. */
                (void)memcpy(dst,realSrc,dtSize);
                dst     += dtSize;
                realSrc += dtSize;

                /* Copy imag part. */
                (void)memcpy(dst,imagSrc,dtSize);
                dst     += dtSize;
                imagSrc += dtSize;
            }
        }
    }

EXIT_POINT:
    return(errStr);
} /* end ReplaceRtP */


/* Function: ReadMatFileAndUpdateParams ========================================
 *
 */
const char* ReadMatFileAndUpdateParams(const SimStruct *S)
{
    const char*    result         = NULL;
    PrmStructData* paramStructure = NULL;

    if (gblParamFilename == NULL) goto EXIT_POINT;

    result = rt_ReadParamStructureMatfile(&paramStructure, gblParamCellIndex);
    if (result != NULL) goto EXIT_POINT;

    /* be sure checksums all match */
    if (paramStructure->checksum[0] != ssGetChecksum0(S) ||
        paramStructure->checksum[1] != ssGetChecksum1(S) ||
        paramStructure->checksum[2] != ssGetChecksum2(S) ||
        paramStructure->checksum[3] != ssGetChecksum3(S) ) {
        result = "model checksum mismatch - incorrect parameter data "
            "specified";
        goto EXIT_POINT;
    }

    /* Replace the rtP structure */
    result = ReplaceRtP(S, paramStructure);
    if (result != NULL) goto EXIT_POINT;

  EXIT_POINT:
    if (paramStructure != NULL) {
        rt_FreeRSimParamStructs(paramStructure);
    }
    return(result);

} /* ReadMatFileAndUpdateParams */
