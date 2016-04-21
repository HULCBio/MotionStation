/*****************************************************************************
******************************************************************************
*
*		Joystick driver S-function (Win32-specific)
*
*   		$Revision: 1.1.6.1 $
*   		$Date: 2003/12/31 19:45:17 $
*   		$Author: batserve $
*
*   		Copyright 1998-2003 HUMUSOFT s.r.o.
*
******************************************************************************
*****************************************************************************/

#include <windows.h>
#include <mmsystem.h>

#define DIRECTINPUT_VERSION 0x0800
#include <dinput.h>

#include "joyinput.h"


/* S-function IWork - common */

enum {
      IWORKNUMAXES = 0,
      IWORKNUMBUTTONS,
      IWORKNUMPOVS,
      IWORKNUMFORCES
};

/* S-function IWork for traditional joystick */

enum {
      IWORKXOFFSET = IWORKNUMFORCES + 1,
      IWORKXRANGE,
      IWORKYOFFSET,
      IWORKYRANGE,
      IWORKZOFFSET,
      IWORKZRANGE,
      IWORKROFFSET,
      IWORKRRANGE,
      IWORKUOFFSET,
      IWORKURANGE,
      IWORKVOFFSET,
      IWORKVRANGE,
      JOYNUMIWORK
};

/* S-function IWork for DirectInput8 */

enum {
      IWORKAXESFLAGS = IWORKNUMFORCES + 1,
      DI8NUMIWORK
};

/* S-function PWork for traditional joystick */

enum {
      JOYNUMPWORK = 0,
};

/* S-function PWork for DirectInput8 */

enum {
      PWORKDEVICE = 0,
      PWORKEFFECT,
      DI8NUMPWORK
};


/* joystick axes flags */
union JOYAXESFLAGS
{
  struct
  {
    bool X  : 1;
    bool Y  : 1;
    bool Z  : 1;
    bool Rx : 1;
    bool Ry : 1;
    bool Rz : 1;
    bool S1 : 1;
    bool S2 : 1;
  };
  int flags;
};


/* joystick device data for both DirectInput8 and joyXxx */
union JOYDEVDATA
{
  JOYCAPS jc;
  struct
  {
    LPDIRECTINPUTDEVICE8 Device;
    JOYAXESFLAGS AxesFlags;
    JOYAXESFLAGS ForceFlags;
  };
};


/* maximum joystick value gfor DirectInput8 */
#define DI8JOYMAXVALUE DI_FFNOMINALMAX

/* global DirectInput8 interface pointer */
static LPDIRECTINPUT8 DI8;



/*****************************************************************************
;*
;*		joyModuleInit
;*		module initialization
;*
;*              Input:	module name
;*              Output:	none
;*
;****************************************************************************/

bool joyModuleInit(const char* modulename)
{

/* create DirectInput8 interface instance */
CoCreateInstance(CLSID_DirectInput8, NULL, CLSCTX_INPROC_SERVER, IID_IDirectInput8, (void**) &DI8);

if (DI8!=NULL)
{
  if (DI8->Initialize(GetModuleHandle(modulename), DIRECTINPUT_VERSION) != DI_OK)
  {
    DI8->Release();
    DI8 = NULL;
  }
}

return(DI8!=NULL);
}



/*****************************************************************************
;*
;*		DI8JoyEnumDevices
;*		enumerate joystick devices
;*
;*              Input:	device instance
;*                      context
;*              Output:	0 - failure, 1 - success
;*
;****************************************************************************/

struct FFENUMDEVDATA
{
  int ID;
  LPDIRECTINPUTDEVICE8 Device;
};

static BOOL CALLBACK DI8JoyEnumDevices(const DIDEVICEINSTANCE* instance, void* context)
{
LPDIRECTINPUTDEVICE8 Device;
FFENUMDEVDATA* devicedata = (FFENUMDEVDATA*) context;

if (devicedata->ID-- > 0 || FAILED(DI8->CreateDevice(instance->guidInstance, &Device, NULL)))
  return(DIENUM_CONTINUE);

devicedata->Device = Device;
return(DIENUM_STOP);
}



/*****************************************************************************
;*
;*		DI8JoyEnumObjects
;*		enumerate joystick device objects
;*
;*              Input:	device instance
;*                      context
;*              Output:	0 - failure, 1 - success
;*
;****************************************************************************/

struct FFENUMOBJDATA
{
  LPDIRECTINPUTDEVICE8 Device;
  JOYSIZES* js;
  JOYAXESFLAGS axesflags;
  JOYAXESFLAGS forceflags;
};

static BOOL CALLBACK DI8JoyEnumObjects(const DIDEVICEOBJECTINSTANCE* instance, void* context)
{
FFENUMOBJDATA* objdata = (FFENUMOBJDATA*) context;
int i;

static const GUID* const GUID_Axes[] =
{
  &GUID_XAxis,
  &GUID_YAxis,
  &GUID_ZAxis,
  &GUID_RxAxis,
  &GUID_RyAxis,
  &GUID_RzAxis,
  &GUID_Slider
};

DIPROPRANGE diprg;
diprg.diph.dwSize       = sizeof(DIPROPRANGE);
diprg.diph.dwHeaderSize = sizeof(DIPROPHEADER);
diprg.diph.dwHow        = DIPH_BYID;
diprg.diph.dwObj        = instance->dwType;
diprg.lMin              = -DI8JOYMAXVALUE;
diprg.lMax              = DI8JOYMAXVALUE;

/* detect axes */
for (i=0; i<sizeof(GUID_Axes)/sizeof(GUID*); i++)
{
  /* find the appropriate axis and flag it */
  if (instance->guidType == *(GUID_Axes[i]))
  {
    if (i==sizeof(GUID_Axes)/sizeof(GUID*)-1 && objdata->axesflags.S1) i++; // adjust for second slider
    objdata->js->numAxes++;
    objdata->axesflags.flags |= (1<<i);
    objdata->Device->SetProperty(DIPROP_RANGE, &diprg.diph);
    if (instance->dwFFMaxForce > 0)
    {
      objdata->js->numForces++;
      objdata->forceflags.flags |= (1<<i);
    }
    return(DIENUM_CONTINUE);
  }
}

/* detect buttons */
if (instance->guidType == GUID_Button)
{
  objdata->js->numButtons++;
}

/* detect POVs */
else if (instance->guidType == GUID_POV)
{
  objdata->js->numPOVs++;
}

return(DIENUM_CONTINUE);
}



/*****************************************************************************
;*
;*		joyGetSizes
;*		get joystick sizes
;*
;*              Input:	joystick ID
;*                      pointer to output data structure
;*                      enable force-feedback flag
;*              Output:	OK = NULL or error = pointer to error message
;*
;****************************************************************************/

const char* joyGetSizes(unsigned int joyid, JOYSIZES& js, bool enableforce, void* devdata)
{
JOYDEVDATA* jd = (JOYDEVDATA*) devdata;

/**********************************************
**************** DirectInput 8 ****************
**********************************************/

if (DI8 != NULL)
{
  /* enumerate DirectInput8 devices */
  FFENUMDEVDATA devicedata = {joyid, NULL};
  HRESULT hr = DI8->EnumDevices(DI8DEVCLASS_GAMECTRL, DI8JoyEnumDevices, &devicedata, DIEDFL_ATTACHEDONLY);
  if ( FAILED(hr) || devicedata.Device==NULL || FAILED(devicedata.Device->SetDataFormat(&c_dfDIJoystick2)) )
    return("Joystick not installed.\n");

  /* enumerate DirectInput8 device objects */
  FFENUMOBJDATA objdata = {devicedata.Device, &js};
  objdata.axesflags.flags = objdata.forceflags.flags = 0;
  hr = devicedata.Device->EnumObjects(DI8JoyEnumObjects, &objdata, DIDFT_ALL);
  if (FAILED(hr))
    return("Error reading joystick parameters.\n");

  /* fill in the JOYSIZES structure */
  js.numIWork = DI8NUMIWORK;
  js.numPWork = DI8NUMPWORK;
  if (devdata != NULL)
  {
    jd->Device = devicedata.Device;
    jd->AxesFlags = objdata.axesflags;
    jd->ForceFlags = objdata.forceflags;
  }
  else
    devicedata.Device->Release();
}


/**********************************************
******************* joyXxx *******************
**********************************************/

else   // no DirectInput8 found
{
  /* test for force-feedback enable */
  if (enableforce)
    return("DirectX 8.0 or later must be installed to use force-feedback.\nYou can download it at http://www.microsoft.com//windows/directx .\n");
  if (joyid >= joyGetNumDevs())
    return("Joystick not installed.\n");

  /* get joystick paramters */
  JOYCAPS jc;
  if (joyGetDevCaps(joyid, &jc, sizeof(JOYCAPS)) != JOYERR_NOERROR)
    return("Error reading joystick parameters.\n");

  /* fill in the JOYSIZES structure */
  js.numIWork = JOYNUMIWORK;
  js.numPWork = JOYNUMPWORK;
  js.numAxes = jc.wNumAxes;
  js.numButtons = jc.wNumButtons;
  js.numSliders = 0;
  js.numPOVs = (jc.wCaps & JOYCAPS_HASPOV) != 0;
  js.numForces = 0;
  if (devdata != NULL)
    memcpy(&(jd->jc), &jc, sizeof(JOYCAPS));
}

/* if force-feedback is disabled then disable it even if found */
if (!enableforce)
  js.numForces = 0;

return(NULL);
}



/*****************************************************************************
;*
;*		FindMLWindow
;*		find MATLAB window
;*
;*              Input:	candidate window handle
;*                      pointer to result
;*              Output:	status
;*
;****************************************************************************/

#define WINDOWTITLE "MATLAB Command Window"

BOOL CALLBACK FindMLWindow(HWND hwnd, LPARAM lparam)
{
HWND* result = (HWND*) lparam;
char winname[sizeof(WINDOWTITLE)];

GetWindowText(hwnd, winname, sizeof(winname));
if (strcmp(winname, WINDOWTITLE)==0)
{
  *result = hwnd;
  return(FALSE);
}

return(TRUE);
}



/*****************************************************************************
;*
;*		joyStart
;*		joystick initialization
;*
;*              Input:	joystick ID
;*                      enable force-feedback flag
;*                      pointer to integer work vector
;*                      pointer to pointer work vector
;*                      MATLAB thread ID
;*              Output:	OK = NULL or error = pointer to error message
;*
;****************************************************************************/

const char* joyStart(unsigned int joyid, bool enableforce, int* iwork, void** pwork, unsigned int mlthread)
{
JOYSIZES js;
JOYDEVDATA jd;
JOYINFOEX ji;
const char* errmsg;

/* get joystick capabilities */
memset(&js, 0, sizeof(js));
errmsg = joyGetSizes(joyid, js, enableforce, &jd);
if (errmsg != NULL)
  return(errmsg);

/* fill IWork with number of axes and number of buttons */
iwork[IWORKNUMAXES] = js.numAxes;
iwork[IWORKNUMBUTTONS] = js.numButtons;
iwork[IWORKNUMPOVS] = js.numPOVs;
iwork[IWORKNUMFORCES] = js.numForces;


/**********************************************
**************** DirectInput 8 ****************
**********************************************/

if (DI8 != NULL)
{
  LPDIRECTINPUTEFFECT Effect = NULL;

  /* prepare for force-feedback */
  pwork[PWORKEFFECT] = NULL;
  if (js.numForces>0)
  {
    /* disable auto-center spring */
    DIPROPDWORD dipdw;
    dipdw.diph.dwSize       = sizeof(DIPROPDWORD);
    dipdw.diph.dwHeaderSize = sizeof(DIPROPHEADER);
    dipdw.diph.dwObj        = 0;
    dipdw.diph.dwHow        = DIPH_DEVICE;
    dipdw.dwData            = FALSE;
    if (FAILED(jd.Device->SetProperty(DIPROP_AUTOCENTER, &dipdw.diph)))
      return("Cannot set force-feedback properties.");

    /* set cooperative level - attach to MATLAB command window */
    HWND mlwin = NULL;
    EnumThreadWindows(mlthread!=0 ? mlthread : GetCurrentThreadId(), FindMLWindow, (LPARAM) &mlwin);
    if (mlwin==NULL || FAILED(jd.Device->SetCooperativeLevel(mlwin, DISCL_EXCLUSIVE | DISCL_BACKGROUND)))
      return("Cannot associate force-feedback joystick with application.");

    /* prepare effect axes array */
    DWORD axes[MAXINFORCES];
    int i = 0;
    if (jd.ForceFlags.X)  axes[i++] = DIJOFS_X;
    if (jd.ForceFlags.Y)  axes[i++] = DIJOFS_Y;
    if (jd.ForceFlags.Z)  axes[i++] = DIJOFS_Z;
    if (jd.ForceFlags.Rx) axes[i++] = DIJOFS_RX;
    if (jd.ForceFlags.Ry) axes[i++] = DIJOFS_RY;
    if (jd.ForceFlags.Rz) axes[i++] = DIJOFS_RZ;
    if (jd.ForceFlags.S1) axes[i++] = DIJOFS_SLIDER(0);
    if (jd.ForceFlags.S2) axes[i++] = DIJOFS_SLIDER(1);

    LONG direction[MAXINFORCES];
    memset(direction, 0, sizeof(direction));
    DICONSTANTFORCE cf = { 0 };

    /* create force-feedback effect */
    DIEFFECT eff;
    memset(&eff, 0, sizeof(eff));
    eff.dwSize                  = sizeof(DIEFFECT);
    eff.dwFlags                 = DIEFF_CARTESIAN | DIEFF_OBJECTOFFSETS;
    eff.dwDuration              = INFINITE;
    eff.dwGain                  = DI_FFNOMINALMAX;
    eff.dwTriggerButton         = DIEB_NOTRIGGER;
    eff.dwTriggerRepeatInterval = INFINITE;
    eff.cAxes                   = iwork[IWORKNUMFORCES];
    eff.rgdwAxes                = axes;
    eff.rglDirection            = direction;
    eff.cbTypeSpecificParams    = sizeof(DICONSTANTFORCE);
    eff.lpvTypeSpecificParams   = &cf;

    if (FAILED(jd.Device->CreateEffect(GUID_ConstantForce, &eff, &Effect, NULL)))
      return("Cannot create force-feedback effect.");

  } // end of force-feedback preparation

  /* acquire the device */
  if (FAILED(jd.Device->Acquire()))
    return("Cannot acquire DirectInput8 joystick device.");

  /* store device parameters */
  pwork[PWORKDEVICE] = jd.Device;
  pwork[PWORKEFFECT] = Effect;
  iwork[IWORKAXESFLAGS] = jd.AxesFlags.flags;
}


/**********************************************
******************* joyXxx *******************
**********************************************/

else
{
  switch(iwork[IWORKNUMAXES])
  {
    case 6 : iwork[IWORKVOFFSET] = jd.jc.wVmin+jd.jc.wVmax; iwork[IWORKVRANGE] = jd.jc.wVmax-jd.jc.wVmin;
    case 5 : iwork[IWORKUOFFSET] = jd.jc.wUmin+jd.jc.wUmax; iwork[IWORKURANGE] = jd.jc.wUmax-jd.jc.wUmin;
    case 4 : iwork[IWORKROFFSET] = jd.jc.wRmin+jd.jc.wRmax; iwork[IWORKRRANGE] = jd.jc.wRmax-jd.jc.wRmin;
    case 3 : iwork[IWORKZOFFSET] = jd.jc.wZmin+jd.jc.wZmax; iwork[IWORKZRANGE] = jd.jc.wZmax-jd.jc.wZmin;
    case 2 : iwork[IWORKYOFFSET] = jd.jc.wYmin+jd.jc.wYmax; iwork[IWORKYRANGE] = jd.jc.wYmax-jd.jc.wYmin;
    case 1 : iwork[IWORKXOFFSET] = jd.jc.wXmin+jd.jc.wXmax; iwork[IWORKXRANGE] = jd.jc.wXmax-jd.jc.wXmin;
  }

  /* test if joystick connected */
  ji.dwSize = sizeof(ji);
  ji.dwFlags = JOY_RETURNALL;
  if (joyGetPosEx(joyid, &ji) == JOYERR_UNPLUGGED)
    return("Joystick is not connected.");
}

return(NULL);
}



/*****************************************************************************
;*
;*		helper functions for joyInputs
;*
;****************************************************************************/

static inline double di8torange(int val)
  { return(((double) val)/DI8JOYMAXVALUE); };

static inline LONG di8fftorange(double val)
  { return((LONG) (DI_FFNOMINALMAX * min(max(val, -1), 1)) ); };

static inline double joytorange(int val, int offset, double range)
  { return((2*val-offset)/range); };


/*****************************************************************************
;*
;*		joyInputs
;*		read joystick values
;*
;*              Input:	joystick ID
;*                      pointer to axes output
;*                      pointer to buttons output
;*                      pointer to POVs output
;*                      pointer to integer work vector
;*                      pointer to pointer work vector
;*              Output:	none
;*
;****************************************************************************/

void joyInputs(unsigned int joyid, double* axes, bool* buttons, double* POVs, int* iwork, void** pwork)
{
/* retrieve variables work vectors */
int naxes = iwork[IWORKNUMAXES];
int nbutt = iwork[IWORKNUMBUTTONS];
int npovs = iwork[IWORKNUMPOVS];


/**********************************************
**************** DirectInput 8 ****************
**********************************************/

if (DI8 != NULL)
{
  LPDIRECTINPUTDEVICE8 Device =(LPDIRECTINPUTDEVICE8) pwork[PWORKDEVICE];
  DIJOYSTATE2 jdata;
  int i;

  /* read the joystick data */
  if (FAILED(Device->Poll()) || FAILED(Device->GetDeviceState(sizeof(DIJOYSTATE2), &jdata)))
  {
    if (axes!=NULL)
      memset(axes, 0, naxes*sizeof(double));
    if (buttons!=NULL)
      memset(buttons, 0, nbutt*sizeof(bool));
    if (POVs!=NULL)
      for (i=0; i<npovs; i++)
        POVs[i] = -1.;
    return;
  }

  /* fill in axes status */
  if (axes!=NULL)
  {
    JOYAXESFLAGS f;
    f.flags = iwork[IWORKAXESFLAGS];
    i=0;
    if (f.X)  axes[i++] = di8torange(jdata.lX);
    if (f.Y)  axes[i++] = di8torange(jdata.lY);
    if (f.Z)  axes[i++] = di8torange(jdata.lZ);
    if (f.Rx) axes[i++] = di8torange(jdata.lRx);
    if (f.Ry) axes[i++] = di8torange(jdata.lRy);
    if (f.Rz) axes[i++] = di8torange(jdata.lRz);
    if (f.S1) axes[i++] = di8torange(jdata.rglSlider[0]);
    if (f.S2) axes[i++] = di8torange(jdata.rglSlider[1]);
  }

  /* fill in buttons status */
  if (buttons!=NULL)
    for (i=0; i<nbutt; i++)
      buttons[i] = (jdata.rgbButtons[i] & 0x80) != 0;

  /* fill in POV status */
  if (POVs!=NULL)
    for (i=0; i<npovs; i++)
      POVs[i] = (LOWORD(jdata.rgdwPOV[i]) == 0xFFFF) ? -1. : jdata.rgdwPOV[i]/DI_DEGREES;

}


/**********************************************
******************* joyXxx *******************
**********************************************/

else
{
  JOYINFOEX ji;
  int i;
  unsigned b;

  /* in case of error set all outputs to zero */
  ji.dwSize = sizeof(ji);
  ji.dwFlags = JOY_RETURNALL;
  if (joyGetPosEx(joyid, &ji) != JOYERR_NOERROR)
  {
    if (axes!=NULL)
      memset(axes, 0, naxes*sizeof(double));
    if (buttons!=NULL)
      memset(buttons, 0, nbutt*sizeof(bool));
    if (POVs!=NULL && npovs>0)
      POVs[0] = -1;
    return;
  }

  /* convert and fill joystick positions */
  if (axes!=NULL)
    switch(naxes)
    {
      case 6 : axes[5] = joytorange(ji.dwVpos, iwork[IWORKVOFFSET], iwork[IWORKVRANGE]);
      case 5 : axes[4] = joytorange(ji.dwUpos, iwork[IWORKUOFFSET], iwork[IWORKURANGE]);
      case 4 : axes[3] = joytorange(ji.dwRpos, iwork[IWORKROFFSET], iwork[IWORKRRANGE]);
      case 3 : axes[2] = joytorange(ji.dwZpos, iwork[IWORKZOFFSET], iwork[IWORKZRANGE]);
      case 2 : axes[1] = joytorange(ji.dwYpos, iwork[IWORKYOFFSET], iwork[IWORKYRANGE]);
      case 1 : axes[0] = joytorange(ji.dwXpos, iwork[IWORKXOFFSET], iwork[IWORKXRANGE]);
    }

  /* fill joystick button states */
  if (buttons!=NULL)
    for (i=0, b=ji.dwButtons; i<nbutt; i++, b>>=1)
      buttons[i] = b & 0x1;

  /* fill the POV value */
  if (POVs!=NULL && npovs>0)
    POVs[0] = (ji.dwPOV & 0xFFFF) != 0xFFFF ? ji.dwPOV/100. : -1;
}

}



/*****************************************************************************
;*
;*		joyOutputs
;*		set joystick feedback
;*
;*              Input:	joystick ID
;*                      pointer to forces input
;*                      pointer to integer work vector
;*                      pointer to pointer work vector
;*              Output:	none
;*
;****************************************************************************/

void joyOutputs(unsigned int joyid, const double* forces, int* iwork, void** pwork)
{
/* retrieve variables work vectors */
int nforces = iwork[IWORKNUMFORCES];


/**********************************************
**************** DirectInput 8 ****************
**********************************************/

if (DI8 == NULL || forces==NULL || nforces<=0)
  return;

/* force-feedback effect */
LPDIRECTINPUTEFFECT Effect = (LPDIRECTINPUTEFFECT) pwork[PWORKEFFECT];

/* prepare force-feedback coordinates */
LONG direction[MAXINFORCES];
DICONSTANTFORCE cf;
LONG maxforce = 0;

int i;
for (i=0; i<nforces; i++)
{
  LONG f = di8fftorange(forces[i]);
  direction[i] = f;
  maxforce = max(maxforce, abs(f));
}
cf.lMagnitude = maxforce;

/* apply force-feedback */
DIEFFECT eff;
memset(&eff, 0, sizeof(eff));
eff.dwSize                  = sizeof(DIEFFECT);
eff.dwFlags                 = DIEFF_CARTESIAN;
eff.cAxes                   = nforces;
eff.rglDirection            = direction;
eff.cbTypeSpecificParams    = sizeof(DICONSTANTFORCE);
eff.lpvTypeSpecificParams   = &cf;

HRESULT hr = Effect->SetParameters(&eff, DIEP_DIRECTION |
					 DIEP_START |
					 DIEP_TYPESPECIFICPARAMS);

}



/*****************************************************************************
;*
;*		joyTerminate
;*		cleanup
;*
;*              Input:	joystick ID
;*                      pointer to integer work vector
;*                      pointer to pointer work vector
;*              Output:	none
;*
;****************************************************************************/

void joyTerminate(unsigned int joyid, int* iwork, void** pwork)
{

if (DI8 != NULL)
{
  LPDIRECTINPUTEFFECT Effect = (LPDIRECTINPUTEFFECT) pwork[PWORKEFFECT];
  if (Effect != NULL) Effect->Release();
  LPDIRECTINPUTDEVICE8 Device = (LPDIRECTINPUTDEVICE8) pwork[PWORKDEVICE];
  Device->Unacquire();
  Device->Release();
}

}



/*****************************************************************************
;*
;*		joyModuleExit
;*		module termination
;*
;*              Input:	none
;*              Output:	none
;*
;****************************************************************************/

void joyModuleExit(void)
{

/* release DirectInput8 interface instance */
if (DI8 != NULL)
  DI8->Release();

}
