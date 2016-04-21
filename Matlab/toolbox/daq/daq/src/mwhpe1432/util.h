// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:31:15 $


#ifndef __UTIL_H
#define __UTIL_H

#include <vector>

#ifdef _DEBUG
#define DAQ_CHECK(status) { long stat=status; if (stat) {_RPTF1(_CRT_WARN,#status " Returned %d\n",stat) ;return stat;}}
//#define DAQ_CHECK(status) { _CrtCheckMemory() ;long stat=status; _CrtCheckMemory(); if (stat) return stat;}
#define DAQ_ASSERT(function) {long stat=function; if (stat) {_RPTF1(_CRT_ASSERT,#function " Returned %d\n",stat);}}
#else
#define DAQ_CHECK(status) { if (status) return status;}
#define DAQ_ASSERT
#endif


extern bool globalCallbackInstalled;
void globalCallback(ViInt32 a, ViInt32 b);

//extern ViSession globalSession;
//extern int globalCount;
//extern long globalIdList[1024];
extern ViInt32 globalGidAO;
extern ViInt32 globalGidAI;
extern short installedId;
extern std::vector<long> _installedCallbackIDs;
extern std::vector<long> globalIdList;
extern long numFound;
extern ViInt32 addList[];
int Find1432Boards();

class GlobalInfo
{
public:
    GlobalInfo() {InterlockedIncrement(&globalCount);}
    ~GlobalInfo();
    HRESULT GetGlobalSession(ViSession &_session);
    void rmDev(int id);
private:
    void CalculateIdList();
    static ViSession globalSession;
    static long globalCount;
};

typedef enum {
    TRIG_TYPE_MANUAL=TRIG_MANUAL_SOFTWARE,
    TRIG_TYPE_IMMEDIATE=TRIG_IMMEDIATE,    
    TRIG_TYPE_SOFTWARE=TRIG_SOFTWARE,
    TRIG_TYPE_EXTERNAL=MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,1L),
    TRIG_TYPE_HW_ANALOG=MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,2L)
} AITriggerType;

#endif