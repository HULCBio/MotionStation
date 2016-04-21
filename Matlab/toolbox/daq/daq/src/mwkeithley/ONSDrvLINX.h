// ONSDrvLINX.h: Header file for ONSDrvLINX.cpp
//
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:33 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#include "drvlinx.h"
#include "dlcodes.h"
#include "math.h"

#ifndef ONSDrvLINX_H
#define ONSDrvLINX_H

enum ERRORCODES
{
		DL_FALSE = 0,					 //@emem  DL_FALSE
		DL_TRUE = 1,					 //@emem  DL_TRUE
		InvalidWindowHandle = 2,		 //@emem  InvalidWindowHandle
		NULLServiceRequest = 3,			 //@emem  NULLServiceRequest
		DivideByZero = 4,				 //@emem  DivideByZero
		DataConversionFailure = 5,		 //@emem  DataConversionFailure
		IncorrectSubsystem = 6,			 //@emem  IncorrectSubsystem
		InvalidSizeCode = 7,			 //@emem  InvalidSizeCode
		InvalidLDDhandle = 8,	 		 //@emem  InvalidLDDhandle
		NullLDDPointer  = 9,	 		 //@emem  NullLDDPointer
		InvalidMode = 10,		 		 //@emem  InvalidMode
		InvalidSRSize = 11,				 //@emem  InvalidSRSize
		MemoryAllocation = 12,			 //@emem  MemoryAllocation
		InvalidDigitalMask = 13,		 //@emem  InvalidDigitalMask
		AToDConversionFailure = 14		 //@emem  AToDConversionFailure
};

const bool SYNC = true;		// Synchronous (blocking) call
const bool ASYNC = false;	// Asynchronous (non-blocking) call

// Macro to return an error to the engine
#define RETURN_CODE(Code) {CComBSTR _error;if (Code>1) return E_FAIL; else if (Code==DL_FALSE) {_error.LoadString((USHORT)InterpretDriverLINXError(Code)); return CComCoClass<ImwDevice>::Error(_error);}}

// We need to select the correct DriverLINX driver every time we use it, so:
#define SELECTMYDRIVERLINX(DriverHandle) {if (SelectDriverLINX(DriverHandle) == NULL) return Error(_T("Required DriverLINX driver not found."));}

/****************************************************************************
* @doc INTERNAL
*
* @enum DriverLINXState Service Request States
*
* @comm     DriverLINXState are predefined states that the Service Request
*			 can be in. These states are used extensively, within all of the 
*			 examples that are provided, in the document and view classes and
*			 are used to update the graphical user interface.
*
* @devnote  KevinD 8/5/97 11:05:00
*
****************************************************************************/
enum DriverLINXState
{
		Invalid = 0,				 //@emem Invalid
		DriverUnknown = 1,			 //@emem DriverUnknown
		DriverOpen = 2,				 //@emem DriverOpen
		DeviceSelected = 3,			 //@emem DeviceSelected
		DeviceInitialized = 4,		 //@emem DeviceInitialized
		TaskDefined = 5,			 //@emem TaskDefined
		TaskRunning = 6,			 //@emem TaskRunning
		DataReady = 7,				 //@emem DataReady
		TaskInError	= 8				 //@emem TaskInError
		
};

// @const    String  |   PreventOpenDialog   |Defines the string that prevents
// the Open DriverLINX Driver Dialog from opening.

// Note - On 10 April 2001 SK altered the next line from CString to char to get this file 
//  to work with the keithley DAQ adaptor.
const char PreventOpenDialog[]  = "$";

const VAR2CTRL =  FALSE;	// These #constants make DDX clearer
const CTRL2VAR = TRUE;


// Function Prototypes

/*  ---------- Functions that this Library Supports and Utilizes ---------*/
ERRORCODES CheckDigitalProgramming(LPServiceRequest pSR,
								   const int ChannelNumber);
void CloseDriverLINXDriver(const HINSTANCE hInstance);
ERRORCODES ConvertVoltsToADUnits(LPServiceRequest pSR,	  
								 const UINT device, 		  
								 const SubSystems subsystem,  
								 const float userinput, 		 
								 const float gain,			 
								 LONG *lADUNIT);				 
ERRORCODES DoesDeviceSupportDMA(LPServiceRequest pSR);
ERRORCODES DoesDeviceSupportIRQ(LPServiceRequest pSR);
ERRORCODES DoesDeviceSupportAnalogChannelGainList(LPServiceRequest pSR,		
												  const SubSystems subsystem,	
												  const UINT device);
ERRORCODES FreeDriverLINXLDD(LPLDD *pLDD,
							 HANDLE *hLDD);
ERRORCODES GetDriverLINXAIData(LPServiceRequest pSR,
							   unsigned short *pData,
							   const UINT BufIndex,
							   const UINT ChannelsSampled, 
							   const UINT SamplesPerChannel);
ERRORCODES GetDriverLINXAISingleValue(LPServiceRequest pSR,
									  float *pData);
ERRORCODES GetDriverLINXLDD(LPServiceRequest pSR,
							const UINT device,
							HANDLE *hLDD,
							LPLDD *pLDD);
WORD GetDriverLINXStatus(LPServiceRequest pSR,
						 LPSTR pStatus,
						 const UINT dwSize);
ERRORCODES GetExtendedDigitalAddress(const SINT SizeCode,
									 const WORD Channel,
									 WORD *pAddress);

ERRORCODES GetModelName(LPServiceRequest pSR,
						const UINT device,
						LPSTR Model, 
						const SINT Length);
ERRORCODES GetSubSystemsDefaultClock(LPServiceRequest pSR,
									 const UINT device,	
									 SINT *DefaultClock);
ERRORCODES HasDriverLINXSubsystem(LPServiceRequest pSR,
								  const SubSystems subsystem);
ERRORCODES HowManyBitsPerDigitalChannel(LPServiceRequest pSR,
										const WORD Channel,	
										SINT *pBits);
ERRORCODES HowManyBytesPerDigitalChannel(LPServiceRequest pSR,
										 const WORD Channel,
										 SINT *pBytes);
ERRORCODES HowManyDriverLINXLogicalChannels(LPServiceRequest pSR,
											int *ChannelNumber);
ERRORCODES HowManyExtendedDigitalChannels(LPServiceRequest pSR,
										  const int Sizecode,			
										  const int ChannelNumber,	
										  int* ExtendedChannels);
ERRORCODES InitializeDriverLINXDevice(LPServiceRequest pSR,
									  WORD *pResult);
ERRORCODES InitializeDriverLINXSubsystem(LPServiceRequest pSR,
									  WORD *pResult);
UINT InterpretDriverLINXError(const ERRORCODES Code);
ERRORCODES IsExternalDigTrgOrClockChannel(LPServiceRequest pSR, 
										  const int Channel, 
										  BOOLEAN *bClkTrg);
ERRORCODES IsHardwareIntel8255(LPServiceRequest pSR,
							   const int Channel,
							   DigitalTypes *pHardware);
ERRORCODES IsInDriverLINXAnalogRange(LPServiceRequest pSR,
									 const short userinput,
									 const float gain);
ERRORCODES IsInDriverLINXDigitalRange(LPServiceRequest pSR,
									  const UINT device,
									  const SubSystems subsystem,
									  const DWORD userinput);
ERRORCODES IsInDriverLINXExtendedDigitalRange(LPServiceRequest pSR,
											  const int SizeCode,			
											  const DWORD userinput);		
ERRORCODES IsValidServiceRequest(LPServiceRequest pSR);
//ERRORCODES OpenDriverLINXDriver(LPServiceRequest pSR,
//								LPCSTR pDriverName,
//								BOOL bNoDialogBox, 
//								HINSTANCE *DriverInstance);
ERRORCODES PutDriverLINXAOData(LPServiceRequest pSR,
							   unsigned short *pData,
							   const UINT BufIndex,
							   const UINT ChannelsSampled,	
							   const UINT SamplesPerChannel);
ERRORCODES ReadCurrentDigitalIOConfiguration(LPServiceRequest pSR,
											 const SINT Channel,		  
											 LPSTR pStatus,				
											 const UINT dwSize,			
											 int* Configuration);
WORD ShowDriverLINXStatus(LPServiceRequest pSR);
WORD StopDriverLINXSR(LPServiceRequest pSR);

/*  ------------------------- Add Modules -----------------------------*/
void AddChannelGainList(
						LPServiceRequest pSR,
						const int ChannelsSampled,	
						const int* Channels,		 
						const float* Gain,
						const float Termination);
void AddRequestGroupConfigure(LPServiceRequest pSR); 
ERRORCODES AddRequestGroupStart(LPServiceRequest pSR,					
								const BOOL  Synchronous);				
void AddSelectBuffers(LPServiceRequest pSR, 
					  const UINT Buffers, 
					  const UINT SamplesPerChannel,
					  const UINT ChannelsSampled);
void AddSelectSimultaneous(LPServiceRequest pSR, 
						   const BOOL Simultaneous);
void AddSelectSingleChannel(LPServiceRequest pSR,
							const SINT Channel, 
							const float gain);
void AddSelectZeroChannels(LPServiceRequest pSR);
ERRORCODES AddStartEventAnalogTrigger(LPServiceRequest pSR,
									  const SubSystems subsystem,
									  const float Gain,		
									  const float UpperThreshold,	
									  const float LowerThreshold,	
									  const WORD Flags);
void AddStartEventDigitalTrigger(LPServiceRequest pSR,	
								 SINT channel,
								 WORD mask,
								 SINT match,
								 WORD pattern);	
void AddStartEventOnCommand(LPServiceRequest pSR);
void AddStartEventNullEvent(LPServiceRequest pSR);
void AddStartStopList(LPServiceRequest pSR,
					  const SINT StartChannel,	
					  const SINT StopChannel,		
					  const float StartGain,		
					  const float StopGain);
void AddStopEventDigitalTrigger(
								LPServiceRequest pSR,	
								SINT channel,			
								WORD mask,				
								WORD pattern);
ERRORCODES AddStopEventAnalogTrigger( LPServiceRequest pSR,	
									 const UINT device,		
									 const SINT Channel,		
									 const SubSystems subsystem, 
									 const float Gain,		
									 const float UpperThreshold,	
									 const float LowerThreshold,	
									 const WORD Flags);
void AddStopEventOnCommand(LPServiceRequest pSR);
void AddStopEventNullEvent(LPServiceRequest pSR);
void AddStopEventOnTerminalCount(LPServiceRequest pSR);
ERRORCODES AddTimingEventBurstMode(LPServiceRequest pSR,
								   const int ChannelsSampled,	
								   const float Frequency,		
								   const float BurstRate);
ERRORCODES AddTimingEventDefault(LPServiceRequest pSR, 
								 const float Frequency);
void AddTimingEventDIConfigure(LPServiceRequest pSR,
							   const int Channel);
void AddTimingEventExternalDigitalClock(LPServiceRequest pSR);
void AddTimingEventNullEvent(LPServiceRequest pSR);
void AddTimingEventSyncIO(LPServiceRequest pSR,
						  const SINT Clock);			
ERRORCODES SetupDriverLINXInitDIOPort(LPServiceRequest pSR,
									  const UINT device,
									  const SINT Channel,
									  const SubSystems subsystem,
									  const BOOL Synchronous);


ERRORCODES InitializeDriverLINXSubSystem(LPServiceRequest pSR, WORD *pResult);

bool SupportsSubSystem(LDD* ldd, int subsystem);

void AddSelectSingleChannel(LPServiceRequest pSR, 		
							const SINT Channel,			
							const float gain);	
ERRORCODES SetupDriverLINXSingleValueIO(LPServiceRequest pSR,	
										const SINT Channel,		
										const float gain,		
										const BOOL Synchronous);	

#endif