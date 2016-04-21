#include <windows.h>
#include "rterror.h"
#include "rtrwh.h"

const int UPDATE_PERIOD(20);    // update period in milliseconds

static HANDLE ThreadHandle;
static HANDLE FinishEvent;
static int (*HelperCallback) (int, void*, void*);


/*****************************************************************************
;*
;*		MouseThread
;*		thread servicing the joystick
;*
;*              Input:	pointer to driver number
;*              Output:	thrad exit code
;*
;****************************************************************************/

static DWORD WINAPI MouseThread(void* ref)
{
  int drvn = *((int*) ref);

  RECT screen;
  GetWindowRect(GetDesktopWindow(), &screen);  // get screen coordinates for normalizing

  while (WaitForSingleObject(FinishEvent, UPDATE_PERIOD)==WAIT_TIMEOUT)
  {
    POINT cur;
    struct
    {
      int msgid;
      int mptr[2];
    } drvmsg;

    // read and translate mouse coordinates
    GetCursorPos(&cur);
    drvmsg.msgid = 0;
    drvmsg.mptr[0] = ((2*cur.x-screen.right) * (1<<15)) / screen.right;
    drvmsg.mptr[1] = ((screen.bottom-2-2*cur.y) * (1<<15)) / screen.bottom;

    // update the mouse driver
    HelperCallback(drvn, &drvmsg, NULL);
  }

  return(0);
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
  HelperCallback = helpercallback;
  FinishEvent = CreateEvent(NULL, FALSE, FALSE, NULL);
  ThreadHandle = CreateThread(NULL, 4096, MouseThread, &drvn, 0, NULL);
  SetThreadPriority(ThreadHandle, THREAD_PRIORITY_TIME_CRITICAL);
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
  SetEvent(FinishEvent);
  return(WaitForSingleObject(ThreadHandle, THREAD_TIMEOUT) == WAIT_OBJECT_0 ? ERR_OK : ERR_INITHW);
}
