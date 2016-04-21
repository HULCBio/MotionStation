#include <windows.h>

#include "joyinput.h"
#include "rtwin.h"
#include "rterror.h"
#include "rtrwh.h"

const int UPDATE_PERIOD(20);    // update period in milliseconds

struct JOYRECORD
{
  int joyid;
  JOYSIZES js;
  HANDLE ThreadHandle;
  HANDLE FinishEvent;
  DWORD MLThreadId;
};

static JOYRECORD JoyRecord[MAXDRIVER];
static JOYRECORD temprecord;

static bool DI8OK;
static int (*HelperCallback) (int, void*, void*);



/*****************************************************************************
;*
;*		JoystickThread
;*		thread servicing the joystick
;*
;*              Input:	pointer to driver number
;*              Output:	thrad exit code
;*
;****************************************************************************/

static DWORD WINAPI JoystickThread(void* ref)
{
  int drvn = *((int*) ref);
  int* iwork = new int[JoyRecord[drvn].js.numIWork];
  void** pwork = new void*[JoyRecord[drvn].js.numPWork];

  /* start the device, return immediately if error */
  /* error handling should be improved here */
  if (joyStart(JoyRecord[drvn].joyid, DI8OK, iwork, pwork, JoyRecord[drvn].MLThreadId)!=NULL)
  {
    delete[] pwork;
    delete[] iwork;
    return(ERR_INITHW);
  }

  /* loop until thread terminated from outside */
  while (WaitForSingleObject(JoyRecord[drvn].FinishEvent, UPDATE_PERIOD)==WAIT_TIMEOUT)
  {
    double axes[MAXOUTAXES];
    bool buttons[MAXOUTBUTTONS];
    double forces[MAXINFORCES];
    int i;

    /* input message for the driver */
    struct
    {
      int msgid;
      int axes[MAXOUTAXES];
      unsigned buttons;
      double POVs[MAXOUTPOVS];
    } drvinmsg;
    memset(&drvinmsg, 0, sizeof(drvinmsg));

    /* get values from joystick */
    joyInputs(JoyRecord[drvn].joyid, axes, buttons, drvinmsg.POVs, iwork, pwork);

   /* convert values into 16-bit range */
    for (i=0; i<JoyRecord[drvn].js.numAxes; i++)
    {
      drvinmsg.axes[i] = (int) (0x8000*axes[i]);
      if (drvinmsg.axes[i]>0x7FFF)
        drvinmsg.axes[i] = 0x7FFF;
    }
    for (i=0; i<JoyRecord[drvn].js.numButtons; i++)
      if (buttons[i])
        drvinmsg.buttons |= 1<<i;

    /* output message for the driver */
    struct
    {
      int msgid;
      int forces[MAXINFORCES];
    } drvoutmsg;
    memset(&drvoutmsg, 0, sizeof(drvoutmsg));

    /* call the joystick driver */
    HelperCallback(drvn, &drvinmsg, &drvoutmsg);

    /* convert forces from 32-bit range */
    for (i=0; i<JoyRecord[drvn].js.numForces; i++)
      forces[i] = drvoutmsg.forces[i] / (double) (1<<31);

    /* apply the forces */
    joyOutputs(JoyRecord[drvn].joyid, forces, iwork, pwork);
  }

  /* clean up */
  delete[] pwork;
  delete[] iwork;

  return(ERR_OK);
};



/*****************************************************************************
;*
;*		DriverDetect
;*		detect driver device
;*
;*              Input:	driver address
;*              	number of parameters
;*              	pointer to parameter array
;*              Output:	error code
;*
;****************************************************************************/

int WINAPI DriverDetect(unsigned addr, int np, double* tp)
{
  /* extract the joystick ID from parameters */
  temprecord.joyid = addr-1;

  /* get joystick sizes - use force-feedback only with DirectX 8 */
  memset(&temprecord.js, 0, sizeof(JOYSIZES));
  if (joyGetSizes(temprecord.joyid, temprecord.js, DI8OK)!=NULL)
    return(ERR_INITHW);

  return(ERR_OK);
}



/*****************************************************************************
;*
;*		DriverRun
;*		start driver helper loop
;*
;*              Input:	driver number
;*              	pointer to helper callback
;*              Output:	error code
;*
;****************************************************************************/

int WINAPI DriverRun(int drvn, int (*helpercallback) (int, void*, void*))
{
  /* store helper callback address */
  if (HelperCallback==NULL)
    HelperCallback = helpercallback;

  /* copy temporary record created in DriverDetect */
  JoyRecord[drvn] = temprecord;

  /* create service thread */
  JoyRecord[drvn].MLThreadId = GetCurrentThreadId();
  JoyRecord[drvn].FinishEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
  JoyRecord[drvn].ThreadHandle = CreateThread(NULL, 4096, JoystickThread, &drvn, 0, NULL);

  /* boost thread priority - the thread is active for very short period of time only */
  SetThreadPriority(JoyRecord[drvn].ThreadHandle, THREAD_PRIORITY_TIME_CRITICAL);
  return(ERR_OK);
}



/*****************************************************************************
;*
;*		DriverFinish
;*		start driver helper loop
;*
;*              Input:	driver number
;*              Output:	error code
;*
;****************************************************************************/

int WINAPI DriverFinish(int drvn)
{
  const int THREAD_TIMEOUT(2000);    // thread cleanup timeout in milliseconds

  /* set the thread loop event and wait for the thread to terminate */
  SetEvent(JoyRecord[drvn].FinishEvent);
  return(WaitForSingleObject(JoyRecord[drvn].ThreadHandle, THREAD_TIMEOUT) == WAIT_OBJECT_0 ? ERR_OK : ERR_INITHW);
}



/*****************************************************************************
;*
;*		DllMain
;*		DLL initialization/cleanup function
;*
;*              Input:	module instance
;*              	reason for calling
;*              	reserved
;*              Output:	TRUE (success) or FALSE (failure)
;*
;****************************************************************************/

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD Reason, LPVOID Reserved)
{
  switch(Reason)
  {
    // initialize module on process_attach
    case DLL_PROCESS_ATTACH:
      DI8OK = joyModuleInit(NULL);
    break;

    // cleanup module on process_attach
    case DLL_PROCESS_DETACH:
      joyModuleExit();
    break;
  }
  return(TRUE);  // Successful DLL_PROCESS_ATTACH.
}
