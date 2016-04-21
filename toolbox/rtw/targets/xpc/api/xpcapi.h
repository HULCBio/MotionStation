/* File:     xpcapi.h
 * Abstract: Definitions for the xPC Target C API
 * $Revision: 1.9.6.3 $ $Date: 2004/01/22 18:34:07 $
 */
/* Copyright 1996-2003 The MathWorks, Inc. */

#ifndef __XPCAPI_H__
#define __XPCAPI_H__

#ifndef EXPORT
#define EXPORT /**/
#endif

#ifndef XPCAPICALLCONV
#define XPCAPICALLCONV __stdcall
#endif

#ifndef NOMANGLE
#define NOMANGLE /**/
/* #define NOMANGLE extern "C" */
#endif

/* define your own values for NOMANGLE, EXPORT, XPCAPICALLCONV and/or
 * XPCAPIFUNC to change the calling conventions. */
#ifndef XPCAPIFUNC
#define XPCAPIFUNC(type, fun) \
  NOMANGLE EXPORT extern type (XPCAPICALLCONV *##fun)
#endif

#ifdef BUILDDLL
#else
#ifdef  __cplusplus
extern "C" {
#endif
#endif

#define COM1 0
#define COM2 1

/****************************************************************************/
/* ExtStruct:   lgmode =======================================================
 * Description: The structure that holds the values for data logging options.
 *              <vbl>mode is an integer which is 0 for time-equidistant
 *              logging or 1 for value-equidistant logging. These can also
 *              be set using the constants <vbl>LGMOD_TIME and
 *              <vbl>LGMOD_VALUE in xpcapiconst.h. For value-equidistant data,
 *              the incremental value between logged data points is set in
 *              <vbl>incrementvalue (this value is ignored for
 *              time-equidistant logging).
 * SeeAlso:     xPCGetLogMode, xPCSetLogMode
 */
/****************************************************************************/
typedef struct {
    int    mode;
    double incrementvalue;
} lgmode;

/****************************************************************************/
/* ExtStruct:   scopedata ====================================================
 * Description: This structure holds all the data about the scope, used in the
 *              functions <xref>xPCGetScope and <xref>xPCSetScope. In the
 *              structure, <vbl>number refers to the scope number. The
 *              remaining fields are as in the various xPCGetSc* functions
 *              (e.g. <vbl>state is as in <xref>xPCScGetState, <vbl>signals
 *              is as in <xref>xPCScGetSignals, etc.).
 * SeeAlso:     xPCGetScope, xPCSetScope, xPCScGetType, xPCScGetState,
 *              xPCScGetSignals, xPCScGetNumSamples, xPCScGetDecimation,
 *              xPCScGetTriggerMode, xPCScGetNumPrePostSamples,
 *              xPCScGetTriggerSignal, xPCScGetTriggerScope,
 *              xPCScGetTriggerLevel, xPCScGetTriggerSlope.
 */
/****************************************************************************/
typedef struct {
    int    number;
    int    type;
    int    state;
    int    signals[20];
    int    numsamples;
    int    decimation;
    int    triggermode;
    int    numprepostsamples;
    int    triggersignal;
    int    triggerscope;
    int    triggerscopesample;
    double triggerlevel;
    int    triggerslope;
} scopedata;

/* --------------------------------------------------- */
XPCAPIFUNC(int, xPCReOpenPort)(int port);
XPCAPIFUNC(int, xPCOpenSerialPort)(int comport, int baudRate);
XPCAPIFUNC(void, xPCClosePort)(int port);
XPCAPIFUNC(int, xPCGetLastError)(void);
XPCAPIFUNC(void, xPCSetLastError)(int error);
XPCAPIFUNC(double, xPCGetExecTime)(int port);
XPCAPIFUNC(void, xPCSetStopTime)(int port, double tfinal);
XPCAPIFUNC(double, xPCGetStopTime)(int port);
XPCAPIFUNC(void, xPCSetSampleTime)(int port, double ts);
XPCAPIFUNC(double, xPCGetSampleTime)(int port);
XPCAPIFUNC(void, xPCSetEcho)(int port, int mode);
XPCAPIFUNC(int, xPCGetEcho)(int port);
XPCAPIFUNC(double, xPCAverageTET)(int port);
XPCAPIFUNC(int, xPCGetNumParams)(int port);
XPCAPIFUNC(int, xPCGetNumSignals)(int port);
XPCAPIFUNC(char *, xPCGetAppName)(int port, char *modelname);
XPCAPIFUNC(void, xPCUnloadApp)(int port);
XPCAPIFUNC(void, xPCStartApp)(int port);
XPCAPIFUNC(void, xPCStopApp)(int port);
XPCAPIFUNC(int, xPCIsAppRunning)(int port);
XPCAPIFUNC(int, xPCIsOverloaded)(int port);
XPCAPIFUNC(int, xPCGetNumOutputs)(int port);
XPCAPIFUNC(int, xPCGetNumStates)(int port);
XPCAPIFUNC(void, xPCGetParam)(int port, int parIdx, double *paramValue);
XPCAPIFUNC(void, xPCSetLogMode)(int port, lgmode lgdata);
XPCAPIFUNC(void, xPCSetParam)(int port, int parIdx, const double *paramValue);
XPCAPIFUNC(lgmode, xPCGetLogMode)(int port);
XPCAPIFUNC(int, xPCNumLogSamples)(int port);
XPCAPIFUNC(int, xPCMaxLogSamples)(int port);
XPCAPIFUNC(int, xPCNumLogWraps)(int port);
XPCAPIFUNC(void, xPCReboot)(int port);
XPCAPIFUNC(void, xPCGetOutputLog)(int port, int start, int numsamples,
                                  int decimation, int output_id, double *data);
XPCAPIFUNC(void, xPCGetStateLog)(int port, int start, int numsamples,
                                 int decimation, int state_id, double *data);
XPCAPIFUNC(void, xPCGetTimeLog)(int port, int start, int numsamples,
                                int decimation, double *data);
XPCAPIFUNC(void, xPCGetTETLog)(int port, int start, int numsamples,
                               int decimation, double *data);
XPCAPIFUNC(void, xPCScGetData)(int port, int scNum , int signal_id, int start,
                               int numsamples, int decimation, double *data);
XPCAPIFUNC(void, xPCMinimumTET)(int port, double *data);
XPCAPIFUNC(void, xPCMaximumTET)(int port, double *data);
XPCAPIFUNC(int, xPCGetSignals)(int port, int numSignals, const int *signals,
                               double *values);
XPCAPIFUNC(double, xPCGetSignal)(int port,  int sigNum);
XPCAPIFUNC(void, xPCAddScope)(int port, int type, int scNum);
XPCAPIFUNC(void, xPCRemScope)(int port, int scNum);
XPCAPIFUNC(void, xPCScAddSignal)(int port, int scNum, int sigNum);
XPCAPIFUNC(void, xPCScRemSignal)(int port, int scNum, int sigNum);
XPCAPIFUNC(void, xPCScSetAutoRestart)(int port, int scNum, int autorestart);
XPCAPIFUNC(int,  xPCScGetAutoRestart)(int port, int scNum);
XPCAPIFUNC(void, xPCGetScopes)(int port, int *data);
XPCAPIFUNC(void, xPCScGetSignals)(int port, int scNum, int *data);
XPCAPIFUNC(void, xPCScSetDecimation)(int port, int scNum, int decimation);
XPCAPIFUNC(int, xPCScGetDecimation)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetNumSamples)(int port, int scNum, int samples);
XPCAPIFUNC(int, xPCScGetNumSamples)(int port, int scNum);
XPCAPIFUNC(double, xPCScGetStartTime)(int port, int scNum);
XPCAPIFUNC(int, xPCScGetState)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetTriggerLevel)(int port, int scNum, double level);
XPCAPIFUNC(double, xPCScGetTriggerLevel)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetTriggerMode)(int port, int scNum, int mode);
XPCAPIFUNC(int, xPCScGetTriggerMode)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetTriggerScope)(int port, int scNum, int trigMode);
XPCAPIFUNC(int, xPCScGetTriggerScope)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetTriggerScopeSample)(int port, int scNum, int trigScSamp);
XPCAPIFUNC(int, xPCScGetTriggerScopeSample)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetTriggerSignal)(int port, int scNum, int trigSig);
XPCAPIFUNC(int, xPCScGetTriggerSignal)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetTriggerSlope)(int port, int scNum, int trigSlope);
XPCAPIFUNC(int, xPCScGetTriggerSlope)(int port, int scNum);
XPCAPIFUNC(void, xPCScSoftwareTrigger)(int port, int scNum);
XPCAPIFUNC(void, xPCScStart)(int port, int scNum);
XPCAPIFUNC(void, xPCScStop)(int port, int scNum);
XPCAPIFUNC(int, xPCIsScFinished)(int port, int scNum);
XPCAPIFUNC(int, xPCScGetNumPrePostSamples)(int port, int scNum);
XPCAPIFUNC(void, xPCScSetNumPrePostSamples)(int port, int scNum, int prepost);
XPCAPIFUNC(scopedata, xPCGetScope)(int port, int scNum);
XPCAPIFUNC(void, xPCSetScope)(int port, scopedata state);
XPCAPIFUNC(void, xPCLoadApp)(int port, const char* pathstr,
                             const char* filename);
XPCAPIFUNC(void, xPCGetParamDims)(int port, int parIdx, int *dims);
XPCAPIFUNC(int, xPCGetSignalWidth)(int port, int sigIdx);
XPCAPIFUNC(int, xPCGetSignalIdx)(int port, const char *sigName );
XPCAPIFUNC(int, xPCGetParamIdx)(int port, const char *block,
                                const char *parameter);
XPCAPIFUNC(void, xPCGetParamName)(int port, int parIdx, char *block, char *param);
XPCAPIFUNC(char *, xPCGetSignalName)(int port, int sigIdx, char *sigName);
XPCAPIFUNC(int, xPCTgScGetGrid)(int port, int scNum);
XPCAPIFUNC(int, xPCTgScGetMode)(int port, int scNum);
XPCAPIFUNC(int, xPCTgScGetViewMode)(int port);
XPCAPIFUNC(void, xPCTgScGetYLimits)(int port, int scNum, double *limits);
XPCAPIFUNC(void, xPCTgScSetGrid)(int port, int scNum, int flag);
XPCAPIFUNC(void, xPCTgScSetMode)(int port, int scNum, int flag);
XPCAPIFUNC(void, xPCTgScSetViewMode)(int port, int scNum);
XPCAPIFUNC(void, xPCTgScSetYLimits)(int port, int scNum, const double *limits);
XPCAPIFUNC(void, xPCSetLoadTimeOut)(int port, int timeOut);
XPCAPIFUNC(const char *, xPCErrorMsg)(int errorno, char *errmsg);
XPCAPIFUNC(int, xPCScGetType)(int port, int scNum);
XPCAPIFUNC(int, xPCGetLoadTimeOut)(int port);
XPCAPIFUNC(int, xPCOpenTcpIpPort)(const char* address, const char* port);
XPCAPIFUNC(void, xPCOpenConnection)(int port);
XPCAPIFUNC(void, xPCCloseConnection)(int port);
XPCAPIFUNC(int, xPCRegisterTarget)(int commType, const char *ipAddress,
                                   const char *ipPort,
                                   int comPort, int baudRate);
XPCAPIFUNC(void, xPCDeRegisterTarget)(int port);
XPCAPIFUNC(void, xPCGetTargetVersion)(int port, char *ver);
XPCAPIFUNC(int, xPCTargetPing)(int port);
XPCAPIFUNC(void, xPCFSReadFile)(int port, int fileHandle, int start,
                               int numsamples, double *data);
XPCAPIFUNC(void, xPCFSWriteFile)(int port, int fileHandle, int numbytes,
                                 unsigned char *data);
XPCAPIFUNC(void, xPCFSBufferInfo)(int port, char *data);
XPCAPIFUNC(int, xPCFSGetFileSize)(int port, int fileHandle);
XPCAPIFUNC(int, xPCFSOpenFile)(int port, char *filename, char *attrib);
XPCAPIFUNC(void, xPCFSCloseFile)(int port, int fileHandle);
XPCAPIFUNC(void, xPCFSGetPWD)(int port, char *data);
XPCAPIFUNC(void, xPCFTPGet)(int port, int fileHandle, int numbytes, char *filename);
XPCAPIFUNC(void, xPCFTPPut)(int port, int fileHandle, char *filename);
XPCAPIFUNC(void, xPCFSRemoveFile)(int port, char *filename);
XPCAPIFUNC(void, xPCFSCD)(int port, char *filename);
XPCAPIFUNC(void, xPCFSMKDIR)(int port, const char *dirname);
XPCAPIFUNC(void, xPCFSRMDIR)(int port, const char *dirname);
XPCAPIFUNC(void, xPCFSDir)(int port, const char *path, char *listing, int numbytes);
XPCAPIFUNC(int, xPCFSDirSize)(int port, const char *path);
XPCAPIFUNC(void, xPCFSGetError)(int            port,
                                unsigned int   errCode,
                                unsigned char *message);
XPCAPIFUNC(void, xPCSaveParamSet)(int port, const char *filename);
XPCAPIFUNC(void, xPCLoadParamSet)(int port, const char *filename);

XPCAPIFUNC(void, xPCFSScSetFilename)(int port, int scopeId,
                                     const char *filename);
XPCAPIFUNC(const char *, xPCFSScGetFilename)(int port, int scopeId,
                                             char *filename);
XPCAPIFUNC(void, xPCFSScSetWriteMode)(int port, int scopeId,
                                      int writeMode);
XPCAPIFUNC(int, xPCFSScGetWriteMode)(int port, int scopeId);

XPCAPIFUNC(void, xPCFSScSetWriteSize)(int port, int scopeId,
                                     unsigned int writeSize);
XPCAPIFUNC(unsigned int, xPCFSScGetWriteSize)(int port, int scopeId);

/* --------------------------------------------------- */

int  xPCInitAPI(void);
void xPCFreeAPI(void);


#ifndef BUILDDLL
#ifdef  __cplusplus
}
#endif /* __cplusplus */
#endif /* BUILDDLL */

#endif /* __XPCAPI_H__ */
