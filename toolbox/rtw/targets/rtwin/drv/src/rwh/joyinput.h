/*****************************************************************************
******************************************************************************
*
*		SpaceMouse driver S-function header file
*
*   		$Revision: 1.1.6.1 $
*   		$Date: 2003/12/31 19:45:16 $
*   		$Author: batserve $
*
*   		Copyright 1998-2003 HUMUSOFT s.r.o.
*
******************************************************************************
*****************************************************************************/


/*****************************************************************************
* maximum joystick input/output port sizes
*****************************************************************************/

const int MAXOUTAXES     (8);
const int MAXOUTBUTTONS (32);
const int MAXOUTPOVS     (4);
const int MAXINFORCES    (8);



/*****************************************************************************
* joystick size info
*****************************************************************************/

struct JOYSIZES
{
  int numIWork;
  int numPWork;
  int numAxes;
  int numButtons;
  int numPOVs;
  int numSliders;
  int numForces;
};



/*****************************************************************************
* platform-dependent function prototypes
*****************************************************************************/

const char* joyGetSizes(unsigned int joyid, JOYSIZES& js, bool enableforce, void* devdata=0);
bool joyModuleInit(const char* modulename);
void joyModuleExit(void);
const char* joyStart(unsigned int joyid, bool enableforce, int* iwork, void** pwork, unsigned int mlthread=0);
void joyInputs(unsigned int joyid, double* axes, bool* buttons, double* POVs, int* iwork, void** pwork);
void joyOutputs(unsigned int joyid, const double* forces, int* iwork, void** pwork);
void joyTerminate(unsigned int joyid, int* iwork, void** pwork);
