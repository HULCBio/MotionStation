//////////////////////////////////////////////////////////////////////////////
// MWIPPL.CPP
//
// This class provides a wrapper for the use of Intel's Performance Primitives
// Library in Matlab 
//
// $Revision: 1.1.6.1 $
// Copyright 1993-2003 The MathWorks, Inc. All Rights Reserved.
//////////////////////////////////////////////////////////////////////////////

static char rcsid[] = "$Id: mwippl.cpp,v 1.1.6.1 2003/05/03 17:52:12 batserve Exp $";

#include <string.h>
#include "mex.h"
#include "mwippl.h"

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
MwIppl::MwIppl()
{
    //Initialize class variables
    for(int i=0; i < MAX_NUM_LIBS;i++)
    {
        fLibInfo[i].libPointer = NULL;
    }

    //Initialize "library name" field in lib info struct
    strcpy(fLibInfo[ippCV].libName, LIBIPPCV);
    strcpy(fLibInfo[ippS] .libName, LIBIPPS );
    strcpy(fLibInfo[ippI] .libName, LIBIPPI );
    strcpy(fLibInfo[ippAC].libName, LIBIPPAC);

    //Retrieve pointer to IPPL error reporting function 
    ippGetStatusString = 
        (ippGetStatusString_T)getMethodPointer("ippGetStatusString", ippS);

    fIpplEnabled = isIpplEnabled();
};

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
MwIppl::~MwIppl()
{
    for(int i=0; i < MAX_NUM_LIBS; i++)
    {
        if(fLibInfo[i].libPointer != NULL)
        {
            utUnloadLibrary(fLibInfo[i].libPointer);
        }
    }
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
#define ENV_VAR_IPPL_OFF "IPT_IPPL_OFF"

bool MwIppl::isIpplEnabled(void)
{
    bool  ipplEnabled = true;
    char *envValue = NULL;    
    
    envValue = getenv(ENV_VAR_IPPL_OFF);

    ipplEnabled = (envValue == NULL) ? true : false;

    return(ipplEnabled);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void *MwIppl::getMethodPointer(const char *methodName, libindex_T libIndex)
{
    void       *methodPointer = NULL;
    int         error         = 0;

#ifdef __i386__ //Always return NULL on non-Intel architectures  

    mxAssert((libIndex <= MAX_NUM_LIBS), "IPPL library index out of range");

    //Only load if not loaded before
    if(!fLibInfo[libIndex].libPointer && fIpplEnabled)
    {
        fLibInfo[libIndex].libPointer =  
            utLoadLibrary(fLibInfo[libIndex].libName, &error);
    }
    
    if(error || !fIpplEnabled )
    {
        //silently return null on failure; this may only mean that
        //the library is not available on this platform or that the
        //user chose to remove it. 
        methodPointer = NULL;  
    }
    else
    {
        methodPointer =
            utFindSymbolInLibrary(fLibInfo[libIndex].libPointer,
                                  (char *)methodName);

        mxAssert(methodPointer, utLastLibraryError());
    }

#endif

    return(methodPointer);
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
void MwIppl::ipplCheckStatus(IppStatus statusCode)
{
    if(statusCode != ippStsNoErr)
    {
        if(ippGetStatusString)
        {
            mexErrMsgIdAndTxt("Images:mwippl:ipplError", "%s",
                              (*ippGetStatusString)(statusCode));
        }
        else
        {
            mexErrMsgIdAndTxt("Images:mwippl:unknownIpplError", "%s",
                              "Unknown error occured in IPPL.");
        }
    }   
}

//////////////////////////////////////////////////////////////////////////////
//
//////////////////////////////////////////////////////////////////////////////
#define METHOD_NAME_LEN 256
#define LIB_INFO_LEN    1024
bool MwIppl::getLibraryInfo(libindex_T libIndex, mxArray **mxInfo)
{
    char methodName[METHOD_NAME_LEN];
    bool status = true;

    switch(libIndex)
    {
      case ippI:
        strcpy(methodName,"ippiGetLibVersion");
        break;
      case ippS:
        strcpy(methodName,"ippsGetLibVersion");
        break;
      case ippCV:
        strcpy(methodName,"ippcvGetLibVersion");
        break;
      case ippAC:
        strcpy(methodName,"ippacGetLibVersion");
        break;
      default:
        mexErrMsgIdAndTxt("Images:mwippl:unknownIpplError", "%s",
                          "Internal error occured in MWIPPL.CPP.");
        break;
    }

    ippGetLibVersion = 
        (ippGetLibVersion_T)getMethodPointer(methodName, libIndex);


    char *info = (char *)mxCalloc(LIB_INFO_LEN, sizeof(char));

    if(ippGetLibVersion)
    {
        const IppLibraryVersion* libInfo = ippGetLibVersion();


        sprintf(info,"%-8s %-15s %d.%d.%d.%-3d %-4s %s", 
                libInfo->Name, 
                libInfo->Version,
                libInfo->major,
                libInfo->minor,
                libInfo->majorBuild,
                libInfo->build,
                libInfo->targetCpu,
                libInfo->BuildDate);

        status = true;
    }
    else if(!fIpplEnabled)
    {
        sprintf(info,"Library %s was disabled using %s environment variable.",
                fLibInfo[libIndex].libName, ENV_VAR_IPPL_OFF);

        status = false;        
    }
    else
    {
        sprintf(info,"Library %s could not be loaded.", 
        fLibInfo[libIndex].libName);

        status = false;
    }

    //Set the output variable
    *mxInfo = mxCreateString(info);

    mxFree(info);  //Release the no longer needed memory 

    return(status);
}
