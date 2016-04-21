/* File:     sf_car_xpc.c
 * Abstract: Demonstrates the use of the xPC Target C-API in Human-Machine
 *           interaction. This file generates a Win32 Console application,
 *           which when invoked loads the sf_car_xpc.dlm compiled application
 *           on to the xPC Target PC.
 *
 *           To build the executable, use the Visual C/C++ project
 *           sf_car_xpc.dsp.
 *
 * Copyright 2000-2003 The MathWorks, Inc.
 */

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

/* max and min are defined by some compilers, so we wrap them in #ifndef's */
#ifndef max
#define max(a, b) (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
#define min(a, b) (((a) < (b)) ? (a) : (b))
#endif

/* Global Variables */
int   mode = TCPIP, comPort = 0;
int   port;
int   thrPID, brakePID, rpmSID, speedSID, gearSID;
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


/* Function: main ============================================================
 * Abstract: Main function for the sf_car_xpc demo                          */
int main(int argc, char *argv[]) {
    printf("\n"
           "*-------------------------------------------------------------*\n"
           "*          xPC Target API Demo: sf_car_xpc.                   *\n"
           "*                                                             *\n"
           "* Copyright (c) 2000 The MathWorks, Inc. All Rights Reserved. *\n"
           "*-------------------------------------------------------------*\n"
           "\n");

    parseArgs(argc, argv);
    atexit(cleanUp);
    /* Initialize the API */
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

    xPCLoadApp(port, ".", "sf_car_xpc"); checkError("LoadApp: ");
    printf("Application sf_car_xpc loaded, SampleTime: %g  StopTime: %g\n\n",
           xPCGetSampleTime(port), xPCGetStopTime(port));
    checkError(NULL);

    findParam("Throttle", "Value", &thrPID);
    findParam("Brake", "Value", &brakePID);
    findSignal("Engine/rpm", &rpmSID);
    findSignal("Vehicle/mph", &speedSID);
    findSignal("shift_logic/ SFunction ", &gearSID);

    processKeys();                      /* Heart of the application */

    if (xPCIsAppRunning(port)) {
        xPCStopApp(port);
    }
    return 0;
} /* end main() */

/* Function: processKeys =====================================================
 * Abstract: This function reads and processes the keystrokes typed by the
 *           user and takes action based on them. This function runs for most
 *           of the program life.                                           */
void processKeys(void) {
    int    c = 0;
    double throttle, brake;

    throttle = getParam(thrPID);
    brake    = getParam(brakePID);
    fputs("\nR    Br    Th  G     VehSpeed     VehRPM  \n", stdout);
    fputs(  "-   ----   --  -    ----------   -------- \n", stdout);
    while (1) {
        if (_kbhit()) {
            c = _getch();
            switch (c) {
              case 't':
                if (throttle)
                    setParam(thrPID, --throttle);
                break;
              case 'T':
                if (brake)
                    setParam(brakePID, (brake = 0));
                if (throttle < 100)
                    setParam(thrPID, ++throttle);
                break;
              case 'b':
                setParam(brakePID, (brake = max(brake - 200, 0)));
                if (brake)
                    setParam(thrPID, (throttle = 0));
                break;
              case 'B':
                if (throttle)
                    setParam(thrPID, (throttle = 0));
                setParam(brakePID, (brake = min(brake + 200, 4000)));
                break;
              case 's':
              case 'S':
                if (xPCIsAppRunning(port)) {
                    xPCStopApp(port);  checkError(NULL);
                } else {
                    xPCStartApp(port); checkError(NULL);
                }
                break;
              case 'q':
              case 'Q':
                return;
                break;
              default:
                fputc(7, stderr);
                break;
            }
        } else {
            Sleep(50);
        }
        printf( "\r%c   %4d  %3d  %1d  %10.3f   %10.3f",
                (xPCIsAppRunning(port) ? 'Y' : 'N'),
                (int)brake, (int)throttle,
                (int)xPCGetSignal(port, gearSID),
                xPCGetSignal(port, speedSID),
                xPCGetSignal(port, rpmSID));
    }
} /* end processKeys() */

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

/** EOF sf_car_xpc.c **/
