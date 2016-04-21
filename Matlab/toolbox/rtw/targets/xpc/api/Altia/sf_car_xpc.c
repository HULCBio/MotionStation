/* File:     sf_car_xpc.c
 * Abstract: Demonstrates the use of the xPC Target C-API in Human-Machine
 *           interaction using ALTIA Design and its API. This file generates a Win32 
 *           Console application, which when invoked launches the Altia Design Human
 *           Machine Interface sfcarxpc.dsn and then loads the sf_car_xpc.dlm
 *           compiled application on to the xPC Target PC.
 *
 *           The executable is built using the make32.ms makefile with the C/C++ Visual Studio nmake. 
 *           nmake -f make32.ms -lan 
 *           To rebuild the executable, you would need to have ALTIA Design installed on your System
 *           and modify the make32.ms makefile to reflect where ALTIA is installed on your system.
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */

/* ALTIA specific API include */
#include "altia.h"

/* Standard include files */
#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <ctype.h>
#include <conio.h>
#include <windows.h>

/* xPC Target C-API specific includes */
#include "xpcapi.h"
#include "xpcapiconst.h"

#define SERIAL 0
#define TCPIP  1
#define IDLETHROTTLE 7
#define CRUISEMIN 10
#define CRUISEMAX 100

static int cruiseset = 0;
static int savedCruise = 0;
static int cruiseOn = 0;
static int brakeOn = 0;
static int sentScreech = 0;
static int cruiseSpeed = 0;
static int currentSpeed = 0;
static int pedalVal = 0;
static int pedalInc = 0;
static int ignition = 0;
static AtConnectId connectId = 0;
static AtTimerId stimer = 0;

/* Global Variables */
int   mode = TCPIP, comPort = 0;
int   port;
int   thrPID, brakePID, cruiseSwitchPID, cruiseSetPID, resumePID, rpmSID, speedSID, gearSID;
char *ipAddress, *ipPort, *pathToApp = NULL;

/* Function prototypes */
double getParam(int parIdx);
void   setParam(int parIdx, double parValue);
void   findParam(char *block, char *param, int *id);
void   findSignal(char *sig, int *id);
void   Usage(void);
void   cleanUp(void);
void   checkError(char *str);
void   processKeys(void);
void   parseArgs(int argc, char *argv[]);
int    str2Int(char *str);

/***************************************************************************************
 * Altia function Events to be handled by ALTIA's Human-Machine Interface sfcarxpc.dsn *
 /**************************************************************************************/

/* Handles throttle pedal press events */
void throttleEvent(AtConnectId connectId, char *name,int  value, AtPointer data)
{
  int pedalValue;
   
    if (ignition)     
        if (!brakeOn){    
            setParam(brakePID,0);
            setParam(thrPID,value);
            pedalVal = value;
            pedalValue= pedalValue;
            AtSendEvent(connectId, "speed_needle", (int)xPCGetSignal(port,speedSID));
            AtSendEvent(connectId, "rpm_needle",(int)xPCGetSignal(port,rpmSID));
        } 
}

/* Handles brake pedal press events */
void brakeEvent(AtConnectId connectId, char *name, int value,AtPointer data)
{
    if (value > 25 && value > brakeOn && sentScreech == 0)
    {
        AtSendEvent(connectId, "brake", 1); /* sound screech */
	sentScreech = 1;
    }
    brakeOn = value;
        
    if (brakeOn == 0)
	sentScreech = 0;

    if (ignition && value >= 1)
    {
        /* If cruise was on, disengage it */
        if (cruiseset == 1)
            AtSendEvent(connectId, "set_light", 0);
        setParam(brakePID,value*40);
        brakeOn = value;
        AtSendEvent(connectId, "speed_needle", (int)xPCGetSignal(port,speedSID));
        AtSendEvent(connectId, "rpm_needle",(int)xPCGetSignal(port,rpmSID));
    }
}

void offCruise()
{
    cruiseOn = 0;
   
    AtSendEvent(connectId, "on_event", 0);
    AtSendEvent(connectId, "set_light", 0);
    setParam(cruiseSwitchPID,0);
}

void initCruise()
{
    ignition = 0;
    sentScreech = 0;

    offCruise();
    AtSendEvent(connectId, "speed_needle", 0);
    AtSendEvent(connectId, "rpm_needle", 0);
}

/* Handle ignition switch */
void ignitionEvent(AtConnectId connectId, char *name, int value,AtPointer data)
{
 
    /* If car is turning off... */
    if (ignition && value == 0)
    {
	initCruise();
        xPCStopApp(port);
    }
    else if (!ignition && value == 1)
    {
        ignition = 1;

	offCruise();
        xPCStartApp(port);checkError(NULL);
        AtSendEvent(connectId, "speed_needle", xPCGetSignal(port,speedSID));
        AtSendEvent(connectId, "rpm_needle", xPCGetSignal(port,rpmSID));
    }
}

/* Cruise on event */
void cruiseOnEvent(AtConnectId connectId, char *name, int value, AtPointer data)
{
    if (ignition && !cruiseOn && value == 1)
    {
        cruiseOn = 1;
        AtSendEvent(connectId, "on_event", 1);
        setParam(cruiseSwitchPID,1);         
    }
}

/* Cruise off event */
void cruiseOffEvent(AtConnectId connectId, char *name, int value, AtPointer data)
{
    int pedalValue;

    if (ignition && cruiseOn && value == 1)
    {
        offCruise();
        AtPollEvent(connectId, "gas_pedal", &pedalValue);
        throttleEvent(connectId, "gas_pedal", pedalValue, NULL);
    }
}


/* Cruise set event */
void cruiseSetEvent(AtConnectId connectId, char *name, int value, AtPointer data)
{
    if (ignition && cruiseOn && !brakeOn && value == 1)
    {
       cruiseset=1;
       AtSendEvent(connectId, "set_light", 1);
       setParam(cruiseSetPID,1);
       setParam(cruiseSetPID,0); /*reset the resume button*/
       throttleEvent(connectId,"gas_pedal",0,NULL);
    }
}


/* Cruise Resume event */
void cruiseResumeEvent(AtConnectId connectId, char *name, int value, AtPointer data)
{
       if (ignition && cruiseOn && !brakeOn && value == 1)
       {  //event to triger the resume state 
           if (getParam(resumePID)== 1) {
               setParam(resumePID,0);
               setParam(brakePID,0);
           }
           if (getParam(resumePID)== 0){
               setParam(resumePID,1);
               setParam(brakePID,0);
           }
       AtSendEvent(connectId, "set_light", 1);  
       }
}

/* Quit request */
void quitEvent(AtConnectId connectId,char *name, int value, AtPointer data)
{
    if (value == 1)
    {
        AtSendEvent(connectId, "altiaQuit", 1);
        atexit(cleanUp);
    }
}

void timeHandler(AtPointer data, unsigned long interval, AtTimerId id)
{
    AtConnectId connectId = (AtConnectId) data;
    int value;

    value = (pedalVal*3)/4;
    if (value < 0)
        value = 0;
    if (value > 74)
        value = 74;
    if (ignition)
    {

       if (value >= (IDLETHROTTLE*2))
           AtSendEvent(connectId, "throttle_nexty", value);
       else
           AtSendEvent(connectId, "throttle_nexty", (IDLETHROTTLE*3)/4);
    }
    else
    {
        value = 0;
        AtSendEvent(connectId, "throttle_nexty", 0);
    }

    value = (currentSpeed *3)/4;
    if (value < 0)
        value = 0;
    if (value > 74)
        value = 74;
    AtSendEvent(connectId, "throttle_draw", 1);
    AtSendEvent(connectId, "speed_nexty", value);
    AtSendEvent(connectId, "speed_draw", 1);
            AtAddTimer(interval, timeHandler, data);
}

void timersec(AtPointer data, unsigned long interval, AtTimerId id)
{
    AtConnectId connectId = (AtConnectId) data;    
    currentSpeed = (int)xPCGetSignal(port,speedSID);
    AtSendEvent(connectId, "speed_needle",(int) xPCGetSignal(port,speedSID));
    AtSendEvent(connectId, "rpm_needle",(int) xPCGetSignal(port,rpmSID));    
    AtAddTimer(interval, timersec, data);
}


/*************************
* xPC Specific functions *
/*************************/
/* Function: Usage ===========================================================
 * Abstract: Prints a simple usage message.                                 */
void Usage(void) {
    fprintf(stdout,
            "Usage: sf_car_xpc {-t IPAddress:IpPort|-c num}\n\n"
            "E.g.:  sf_car_xpc -t 192.168.0.1:22222\n"
            "E.g.:  sf_car_xpc -c 1\n\n");
    return;
} /* end Usage() */

/* Function: str2Int =========================================================
 * Abstract: Converts the supplied string str to an integer. Returns INT_MIN
 *           if the string is invalid as an integer (e.g. "123string" is
 *           invalid) or if the string is empty.                            */
int str2Int(char *str) {
    char *tmp;
    int   tmpInt;
    tmpInt = (int)strtol(str, &tmp, 10);
    if (*str == '\0' || (*tmp != '\0')) {
        return INT_MIN;
    }
    return tmpInt;
} /* end str2Int */

/* Function: parseArgs =======================================================
 * Abstract: Parses the command line arguments and sets the state of variables
 *           based on the arguments.                                        */
void parseArgs(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Insufficient command line arguments.\n\n");
        Usage();
        exit(EXIT_FAILURE);
    }
    if (strlen(argv[1]) != 2               ||
        strchr("-/",   argv[1][0]) == NULL ||
        strchr("tTcC", argv[1][1]) == NULL) {
        fprintf(stderr, "Unrecognized Argument %s\n\n", argv[1]);
        Usage();
        exit(EXIT_FAILURE);
    }
    mode = tolower(argv[1][1]) == 'c' ? SERIAL : TCPIP;
    if (mode == SERIAL) {
        int tmpInt;
        if ((tmpInt = str2Int(argv[2])) > INT_MIN) {
            comPort = tmpInt;
        } else {
            fprintf(stderr, "Unrecognized argument %s\n", argv[2]);
            Usage();
        }
    } else {
        char *tmp;
        ipAddress = argv[2];
        if ((tmp = strchr(argv[2], ':')) == NULL) {
            /* memory need not be freed as it is allocated only once, will *
             * hang around till app ends.                                  */
            if ((ipPort = malloc(6 * sizeof(char))) == NULL) {
                fprintf(stderr, "Unable to allocate memory");
                exit(EXIT_FAILURE);
            }
            strcpy(ipPort, "22222");
        } else {
            *tmp      = '\0';
            ipPort    = ++tmp;
        }
    }
    return;
} /* end parseArgs() */

/* Function: cleanUp =========================================================
 * Abstract: Called at program termination to exit in a clean way.          */
void cleanUp(void) {
    xPCClosePort(port);
    xPCFreeAPI();
    return;
} /* end cleanUp() */

/* Function: checkError ======================================================
 * Abstract: Checks for error by calling xPCGetLastError(); if an error is
 *           found, prints the appropriate error message and exits.         */
void checkError(char *str) {
    char errMsg[80];
    if (xPCGetLastError()) {
        if (str != NULL)
            fputs(str, stderr);
        xPCErrorMsg(xPCGetLastError(), errMsg);
        fputs(errMsg, stderr);
        exit(EXIT_FAILURE);
    }
    return;
} /* end checkError() */

/* Function: findParam =======================================================
 * Abstract: Wrapper function around the xPCGetParamIdx() API call. Also
 *           checks to see if the parameter is not found, and exits in that
 *           case.                                                          */
void findParam(char *block, char *param, int *id) {
    int tmp;
    tmp = xPCGetParamIdx(port, block, param);
    if (xPCGetLastError() || tmp == -1) {
        fprintf(stderr, "Param %s/%s not found\n", block, param);
        exit(EXIT_FAILURE);
    }
    *id = tmp;
    return;
} /* end findParam() */

/* Function: findSignal ======================================================
 * Abstract: Wrapper function around the xPCGetSignalIdx() API call. Also
 *           checks to see if the signal is not found, and exits in that
 *           case.                                                          */
void findSignal(char *sig, int *id) {
    int tmp;
    tmp = xPCGetSignalIdx(port, sig);
    if (xPCGetLastError() || tmp == -1) {
        fprintf(stderr, "Signal %s not found\n", sig);
        exit(EXIT_FAILURE);
    }
    *id = tmp;
    return;
} /* end findSignal() */

/* Function: getParam ========================================================
 * Abstract: Wrapper function around the xPCGetParam() API call. Also checks
 *           for error, and exits if an error is found.                     */
double getParam(int parIdx) {
    double p;
    xPCGetParam(port, parIdx, &p);
    checkError("GetParam: ");
    return p;
} /* end getParam() */

/* Function: setParam ========================================================
 * Abstract: Wrapper function around the xPCSetParam() API call. Also checks
 *           for error, and exits if an error is found.                     */
void setParam(int parIdx, double parValue) {
    xPCSetParam(port, parIdx, &parValue);
    checkError("SetParam: ");
    return;
} /* end setParam() */

/**************************************************
*              Main Application                   *
***************************************************/
int main(int argc,char *argv[])
{
 
    AtConnectId connectId;
    if ((connectId = AtStartInterface("sfcarxpc.dsn", NULL, 0, NULL ,NULL)) < 0) {
	fprintf(stderr, "AtStartInterface failed\n");
	exit(1);
}
    if (connectId < 0)
    return 1;
    parseArgs(argc, argv);
    atexit(cleanUp);

    if (xPCInitAPI()) {
        fprintf(stderr, "Could not load api\n");
        return -1;
    }

    if (mode == SERIAL)
        port = xPCOpenSerialPort(comPort, 0);
    else if (mode == TCPIP)
        port = xPCOpenTcpIpPort(ipAddress, ipPort);
    else {
        fprintf(stderr, "Invalid communication mode\n");
        exit(EXIT_FAILURE);
    }
    checkError("PortOpen: ");

    xPCLoadApp(port, ".", "sf_carcctrl_xpc"); checkError("LoadApp: ");
    printf("Application sf_carcctrl_xpc loaded, SampleTime: %g  StopTime: %g\n\n",
           xPCGetSampleTime(port), xPCGetStopTime(port));
    checkError(NULL);

    findParam("Throttle", "Value", &thrPID);
    findParam("Brake", "Value", &brakePID);
    findParam("Cruise Switch/Constant", "Value", &cruiseSwitchPID);
    findParam("cruiseSet/Constant", "Value", &cruiseSetPID);
    findParam("resume/Constant","Value", &resumePID);
    findSignal("Engine/rpm", &rpmSID);
    findSignal("Vehicle/mph", &speedSID);
    findSignal("shift_logic/ SFunction ", &gearSID);
  
    AtCacheOutput(connectId, 1);
    AtRetryCount(connectId, 1);

    /* Reset variables and Altia interface */
    initCruise();
    brakeOn = 0;

    AtSendEvent(connectId, "ignition_key", 0);
    AtSendEvent(connectId, "gas_pedal", 0);
    AtSendEvent(connectId, "brake_pedal", 0);
    AtSendEvent(connectId, "key", 0);

    
       /* Register callbacks for incoming Altia interface events */
    AtAddCallback(connectId, "gas_pedal", throttleEvent, NULL);
    AtAddCallback(connectId, "brake_pedal", brakeEvent, NULL);
    AtAddCallback(connectId, "ignition_key", ignitionEvent, NULL);
    AtAddCallback(connectId, "on_event", cruiseOnEvent, NULL);
    AtAddCallback(connectId, "off_event", cruiseOffEvent, NULL);
    AtAddCallback(connectId, "set_event", cruiseSetEvent, NULL);
    AtAddCallback(connectId, "resume_event", cruiseResumeEvent, NULL);
    AtAddCallback(connectId, "quit", quitEvent, NULL);
    
    AtAddTimer(40L, timersec, (AtPointer) connectId);
    AtAddTimer(10L, timeHandler, (AtPointer) connectId);

    /* Toolkit library will block waiting for input and timeouts */
    AtMainLoop();
    AtStopInterface(connectId);
    AtCloseConnection(connectId);
    return(0);
}












