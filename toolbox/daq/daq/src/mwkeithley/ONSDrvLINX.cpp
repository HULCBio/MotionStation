// ONSDrvLINX: OPTI-NUM solutions specific DriverLINX high-level functions
//
// Most taken from DrvVCLib.cpp, culled and rewritten for the Keithley Adaptor.
//
// Copyright 2002-2004 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions
// $Revision: 1.1.6.3 $
// $Date: 2004/04/08 20:49:34 $

#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers
#include "stdafx.h"
#include "ONSDrvLINX.h"
#include "resource.h"
#include "drvlinx.h"

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the channels group portion of the Service Request.
 *
 * @comm     <f AddChannelGainList> sets up the channel group portion of  
 *			 the Service Request. This function sets up the channel group for
 *			 a channel gain list. The user can use this function to acquire
 *			 a single or multiple channel(s) that can be in any order with 
 *			 individual gain codes.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddSelectZeroChannels>, <f AddSelectSingleChannel>,
 *			 <f AddStartStopList>
 *
 ****************************************************************************/

void AddChannelGainList(
	LPServiceRequest pSR, 	 //@parm Pointer to DriverLINX Service Request
	const int ChannelsSampled,	//@parm Number of channels to be sampled
	const int* Channels,		//@parm Pointer to the channel list 
	const float* Gain,		//@parm Pointer to the channel(s) gain setting(s)
	const float Termination)	//Channel termination mode (SE/Diff)
{
	pSR->channels.nChannels = ChannelsSampled;
	pSR->channels.numberFormat = tNATIVE;
	 
	//if previously exist delete and rebuild
	if (pSR->channels.chanGainList != NULL)
	{
		delete [] pSR->channels.chanGainList;
		pSR->channels.chanGainList = NULL;
	}


	pSR->channels.chanGainList = new CHANGAIN[ChannelsSampled];
	//fill in the structure
	for (int i = 0; i < ChannelsSampled; i++)
	{
		pSR->channels.chanGainList[i].channel = Channels[i];
		if((pSR->subsystem == AI) || (pSR->subsystem == AO))
		{
			pSR->channels.chanGainList[i].gainOrRange = 
				static_cast<SINT>(Gain2Code(pSR->device, pSR->subsystem, Gain[i]) + Termination);
		}
		else
		{
			pSR->channels.chanGainList[i].gainOrRange = 0;
		}
	}

	return;
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Setup the request group for polled, interrupt, or DMA operations.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f AddRequestGroupStart> sets up the request group portion 
 *			 of the Service Request for polled, interrupt, or DMA operations.
 *           If task is asynchronous, the function determines the appropriate 
 *			 mode. If the board supports DMA, it sets the mode to DMA. 
 *			 Otherwise, it sets the mode to IRQ. If the board does not support  
 *			 either DMA or IRQ modes, the function will fail.
 *
 * @xref	 <f AddRequestGroupConfigure>, <f AddRequestGroupInitialize>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
// Modified by DR: Removed subsystem and device requirement
ERRORCODES AddRequestGroupStart(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const BOOL  Synchronous)	//@parm Select between sync. and async. task
{
	// ASSERT(pSR != NULL);
	// ASSERT(device >= 0);
	// ASSERT((subsystem >= AI) && (subsystem <= CT));
	BOOL error = FALSE;
	if (Synchronous)
	{
		pSR->mode = POLLED;
	}
	//If data-acquistion mode is Asynchronous then determine the best 
	//mode to use.
	else if (DoesDeviceSupportDMA(pSR) == DL_TRUE)
	{
		pSR->mode = DMA;
	}
	else if (DoesDeviceSupportIRQ(pSR) == DL_TRUE)
	{
	   pSR->mode = INTERRUPT;
	}
	else
	{	   //return error code and set service request to fail
		pSR->mode = OTHER;
		error = TRUE;
	}
	pSR->operation = START;		//assume operation will always be start
	//return error code
	if (error)
	{
		return InvalidMode;
	}
	else 
	{
		return DL_TRUE;
	}

}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the buffers group portion of the Service Request.
 *
 * @comm     <f AddSelectBuffers> sets up the buffers group portion of the 
 *			 Service Request. This function sets the number of buffers and 
 *			 the buffer size.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
// Modified by DR: Remove requirement for device and subsystem args)
void AddSelectBuffers(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const UINT Buffers, 		//@parm Number of buffers to create
	const UINT SamplesPerChannel,	//@parm Number of samples for each channel 
	const UINT ChannelsSampled)		//@parm Number of channels sampled
{  

   DL_BUFFERLIST *pBuffer = pSR->lpBuffers;
   //Check to see if any buffers exist in the service request data structure.
   //If they do delete them and then set the DL_BUFFERLIST data structure to
   //NULL.
   if (pBuffer != NULL)	 //IF data structure exists
   {
	   int i;
	   for (i = 0; i< pBuffer->nBuffers; i++)
	   {
			if (pBuffer->BufferAddr[i] != NULL)	   //Delete old buffers
			{
				BufFree(pBuffer->BufferAddr[i]);
			}
	   }
		delete [] pBuffer;	//Release memory
		pBuffer = NULL;	 //Set data structure to NULL
   }
  
   if (Buffers > 0)
   {
		pBuffer = (DL_BUFFERLIST *) new BYTE[DL_BufferListBytes(Buffers)];
		pBuffer->notify = NOTIFY;
		pBuffer->nBuffers = Buffers;
		pBuffer->bufferSize = Samples2Bytes(pSR->device, pSR->subsystem, 0, 
								(SamplesPerChannel * ChannelsSampled));
		UINT i;
		for ( i = 0; i < Buffers; i++)
		{
			//DriverLINX will allocate buffer memory
			if (pSR->mode == DMA)
			{
				pBuffer->BufferAddr[i] = BufAlloc(GBUF_DMA16, pBuffer->bufferSize);
			}
			else if (pSR->mode == INTERRUPT)
			{
				pBuffer->BufferAddr[i] = BufAlloc(GBUF_INT, pBuffer->bufferSize);
			}
			else if (pSR->mode == POLLED)
			{
				pBuffer->BufferAddr[i] = BufAlloc(GBUF_POLLED, pBuffer->bufferSize);
			}

		}
   }
   pSR->lpBuffers = pBuffer;
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the channels group portion of the Service Request.
 *
 * @comm     <f AddSelectZeroChannels> sets up the channel group portion of  
 *			 the Service Request. This function sets up the channels group
 *			 for zero channels. This function is typically used when 
 *			 initializing the device.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddSelectSingleChannel>, <f AddChannelGainList>,
 *			 <f AddStartStopList>
 *
 ****************************************************************************/
 void AddSelectZeroChannels(
	LPServiceRequest pSR)	  //@parm Pointer to DriverLINX Service Request
{
	// ASSERT(pSR != NULL);
	//Used in Service Requests that do not use events.
	pSR->channels.nChannels = 0;

	// Rather delete the channels first, because we never know when this function will be called.
	if (pSR->channels.chanGainList != NULL)
	{
		delete [] pSR->channels.chanGainList;
		pSR->channels.chanGainList = NULL;
	}

}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the start type event of the Service Request.
 *
 * @comm     <f AddStartEventOnCommand> sets up the start type event portion   
 *			 of the Service Request. This functions tells the Service
 *			 Request to start on command once the Service Request is
 *			 submitted.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStartEventNullEvent>, <f AddStartEventDigitalTrigger>,
 *			 <f AddStartEventAnalogTrigger>
 *
 ****************************************************************************/
void AddStartEventOnCommand(
		LPServiceRequest pSR)	//@parm Pointer to DriverLINX Service Request

{
	// ASSERT(pSR != NULL);
	pSR->start.typeEvent = COMMAND;
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the start type event of the Service Request.
 *
 * @comm     <f AddStarAtEventNullEvent> sets up the start type event portion   
 *			 of the Service Request. This functions tells the Service
 *			 Request that there is no start type event.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStartEventOnCommand>, <f AddStartEventDigitalTrigger>,
 *			 <f AddStartEventAnalogTrigger>
 *
 ****************************************************************************/
void AddStartEventNullEvent(
		LPServiceRequest pSR)	 //@parm Pointer to DriverLINX Service Request

{
	// ASSERT(pSR != NULL);
	pSR->start.typeEvent = NULLEVENT;	 
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the stop type event of the Service Request.
 *
 * @comm     <f AddStopEventOnCommand> sets up the stop type event portion   
 *			 of the Service Request. This functions tells the Service
 *			 Request to run continuously until told to stop by issuing
 *			 a software stop.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStopEventOnTerminalCount>, <f AddStopEventNullEvent>,
 *			 <f StopDriverLINXSR>
 *
 ****************************************************************************/

void AddStopEventOnCommand(
	LPServiceRequest pSR)	  //@parm Pointer to DriverLINX Service Request
{
	// ASSERT(pSR != NULL);
	pSR->stop.typeEvent = COMMAND;	
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the stop type event of the Service Request.
 *
 * @comm     <f AddStopEventNullEvent> sets up the stop type event portion   
 *			 of the Service Request. This functions tells the Service
 *			 Request that there is no stop type event.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStopEventOnTerminalCount>
 *
 ****************************************************************************/
void AddStopEventNullEvent(
	LPServiceRequest pSR)	  //@parm Pointer to DriverLINX Service Request

{
	// ASSERT(pSR != NULL);
	pSR->stop.typeEvent = NULLEVENT;	
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the stop type event of the Service Request.
 *
 * @comm     <f AddStopEventOnTerminalCount> sets up the stop type event    
 *			 portion of the Service Request. This functions tells the Service
 *			 Request to stop acquiring data when all buffers specified are 
 *			 filled.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStopEventNullEvent>, <f AddStopEventOnCommand>
 *
 ****************************************************************************/
void AddStopEventOnTerminalCount(
		LPServiceRequest pSR)	 //@parm Pointer to DriverLINX Service Request
{
	// ASSERT(pSR != NULL);
	pSR->stop.typeEvent = TCEVENT;
}


/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the timing type event of the Service Request.
 *
 * @comm     <f AddTimingEventBurstMode> sets up the timing type event portion   
 *			 of the Service Request. This functions sets up the timing event
 *			 to use the the board's default clock. It sets up the Service 
 *			 Request to sample data using burst mode data acquisition. 
 *			 Function will fail if the Frequency or Burst Rate is 0 because 
 *			 this will cause a divide by zero. 
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddTimingEventNullEvent>, 
 *			 <f AddTimingEventExternalDigitalClock>,
 *			 <f AddTimingEventDefault>,
 *			 <f AddTimingEventDIConfigure>,
 *			 <f AddTimingEventSyncIO>
 *
 ****************************************************************************/
ERRORCODES AddTimingEventBurstMode(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const int ChannelsSampled,	//@parm Number of channels to be sampled
	const float Frequency,		//@parm Frequency at which to sample data(Hz)
	const float BurstRate)		//@parm Burst mode conversion rate (Hz)
{
	// ASSERT(pSR != NULL);
	// ASSERT((subsystem >= AI) && (subsystem <= CT));
    // ASSERT(device >= 0);
	// ASSERT(Frequency >= 0.0f);
	// ASSERT(BurstRate >= 0.0f);
	if ((Frequency != 0) && (BurstRate != 0))
	{
		pSR->timing.typeEvent = RATEEVENT;
		pSR->timing.u.rateEvent.channel = DEFAULTTIMER;
		pSR->timing.u.rateEvent.mode = BURSTGEN;
		pSR->timing.u.rateEvent.clock = INTERNAL1;
		pSR->timing.u.rateEvent.gate = DISABLED;

		pSR->timing.u.rateEvent.period = 
					Sec2Tics(pSR->device, pSR->subsystem, DEFAULTTIMER, 1/Frequency);
		pSR->timing.u.rateEvent.onCount = 
					Sec2Tics(pSR->device, pSR->subsystem, DEFAULTTIMER, 1/BurstRate);
		pSR->timing.u.rateEvent.pulses = ChannelsSampled;
		return DL_TRUE;
	}
	else
	{
		//Frequency or Burst Rate division by zero
		return DivideByZero;
	}
	
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the timing type event of the Service Request.
 *
 * @comm     <f AddTimingEventDefault> sets up the timing type event portion   
 *			 of the Service Request. This functions sets up the timing event
 *			 to use the the board's default clock. It sets up the Service 
 *			 Request to sample a channel at the user defined frequency. 
 *			 Function will fail if the frequency is 0 because this
 *			 will cause a divide by zero. 
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddTimingEventNullEvent>, 
 *			 <f AddTimingEventExternalDigitalClock>,
 *			 <f AddTimingEventBurstMode>,
 *			 <f AddTimingEventDIConfigure>,
 *			 <f AddTimingEventSyncIO>
 *
 ****************************************************************************/
ERRORCODES AddTimingEventDefault(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const float Frequency)		//@parm Frequency at which to sample data(Hz)
{
	// ASSERT(pSR != NULL);
	// ASSERT((subsystem >= AI) && (subsystem <= CT));
    // ASSERT(device >= 0);
	// ASSERT(Frequency >= 0.0f);
	if (Frequency != 0)
	{
		pSR->timing.typeEvent = RATEEVENT;
		pSR->timing.u.rateEvent.channel = DEFAULTTIMER;
		pSR->timing.u.rateEvent.mode = RATEGEN;
		pSR->timing.u.rateEvent.clock = INTERNAL1;
		pSR->timing.u.rateEvent.gate = DISABLED;

		pSR->timing.u.rateEvent.period = 
					Sec2Tics(pSR->device, pSR->subsystem, DEFAULTTIMER, 1/Frequency);
		return DL_TRUE;
	}
	else
	{
		//Frequency division by zero
		return DivideByZero;
	}
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the timing type event of the Service Request.
 *
 * @comm     <f AddTimingEventNullEvent> sets up the timing type event portion   
 *			 of the Service Request. This functions tells the Service
 *			 Request that there is no timing type event.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddTimingEventDefault>, 
 *			 <f AddTimingEventExternalDigitalClock>,
 *			 <f AddTimingEventBurstMode>,
 *			 <f AddTimingEventDIConfigure>,
 *			 <f AddTimingEventSyncIO>
 *
 ****************************************************************************/
void AddTimingEventNullEvent(
	LPServiceRequest pSR)		//@parm Pointer to DriverLINX Service Request
{
	 pSR->timing.typeEvent = NULLEVENT;
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Initializes a logical device.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f InitializeDriverLINXDevice> This function sets the appropriate 
 *			 fields of the Service Request required to initialize a logical
 *			 device. This function executes a Service Request. A device has
 *			 to be initialized before it can perform any data acquisition 
 *			 tasks.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES InitializeDriverLINXDevice(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	WORD *pResult)			//@parm Pointer to the opertions result code
{
// Initialize a Logical Device
// Setup a Service Request to initialize the desired logical device.
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		  *pResult = pSR->result;	//result is meaningless	
		  return ValidSR;	 //return error code associated with the SR
	}

	//----------------- Service Request Group ----------------- 
	// Specify the type of Service Request
	// Store the current subsystem before we do this:
	SubSystems oldSubSystem = pSR->subsystem;
	pSR->subsystem = DEVICE;
	pSR->mode = OTHER;
	pSR->operation = INITIALIZE;

	//Set these fields to 0 or NullEvent if not used in the Service Request.
	//This function is synchronous, therefore, events and buffers are not
	//needed and should be omitted.
		AddStartEventNullEvent(pSR);
		AddStopEventNullEvent(pSR);
		AddTimingEventNullEvent(pSR);

	// Add Select Channel Group
		AddSelectZeroChannels(pSR);

	// Add select Buffer Group
		AddSelectBuffers(pSR, 0,0,0);

		DriverLINX(pSR);

		*pResult = pSR->result;
		pSR->subsystem = oldSubSystem;
		return DL_TRUE;
}

//////////////////////////////////////////////////////////////////////////
// InitializeDriverLINXSubsystem: 
// Initialises the sub-system only, of the required device.
// The sub-system is assumed to be defined in the SR already.
//////////////////////////////////////////////////////////////////////////
ERRORCODES InitializeDriverLINXSubsystem(
	LPServiceRequest pSR,	//Pointer to DriverLINX Service Request
	WORD *pResult)			// Pointer to the opertions result code
{
// Initialize a Logical Subsystem
// Setup a Service Request to initialize the desired logical subsystem.
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		  *pResult = pSR->result;	//result is meaningless	
		  return ValidSR;	 //return error code associated with the SR
	}

	//----------------- Service Request Group ----------------- 
	// Specify the type of Service Request
	pSR->mode = OTHER;
	pSR->operation = INITIALIZE;

	//Set these fields to 0 or NullEvent if not used in the Service Request.
	//This function is synchronous, therefore, events and buffers are not
	//needed and should be omitted.
	AddStartEventNullEvent(pSR);
	AddStopEventNullEvent(pSR);
	AddTimingEventNullEvent(pSR);

	// Add Select Channel Group
	AddSelectZeroChannels(pSR);

	// Add select Buffer Group
	AddSelectBuffers(pSR, 0,0,0);

	DriverLINX(pSR);
	
	*pResult = pSR->result;
	return DL_TRUE;
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Checks whether subsystem supports DMA mode.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f DoesDeviceSupportDMA> Function determines if the subsystem
 *			 supports DMA by querying the LDD.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f DoesDeviceSupportIRQ>
 *
 ****************************************************************************/
ERRORCODES DoesDeviceSupportDMA(
	LPServiceRequest pSR)		//@parm Pointer to DriverLINX Service Request
{
	BOOL DMA = FALSE;	
	BOOL NoSystem = FALSE;

	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		  return ValidSR;	 //return error code associated with the SR
	}

	//Get pointer to the LDD
	HANDLE hLDD = NULL;
	LPLDD pLDD = NULL;
	ERRORCODES Code = GetDriverLINXLDD(pSR, pSR->device, &hLDD, &pLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}

	switch (pSR->subsystem)
	{
		case(AI):
				if (pLDD->AnaChan[1].An_DMAChanBuf[0] != -1)
				{
					DMA = TRUE;
				}
					break;
		case(AO):
				if (pLDD->AnaChan[0].An_DMAChanBuf[0] != -1)
				{
					DMA = TRUE;
				}
				break;
		 case(DI):
				if (pLDD->DigChan[1].Di_DMAChanBuf[0] != -1)
				{
					DMA = TRUE;
				}	
				break;
		case(DO):
				if (pLDD->DigChan[0].Di_DMAChanBuf[0] != -1)
				{
					DMA = TRUE;
				}
				break;
		case(CT):
				DMA = FALSE;
				break;
		default:
				DMA = FALSE;
				NoSystem = TRUE;	//No such subsystem
	}

	//Unlock the pointer and free memory associated with the LDD
	Code = FreeDriverLINXLDD(&pLDD, &hLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}
	if (DMA == TRUE)
	{
		return DL_TRUE;
	}
	else if ((DMA == FALSE) && (NoSystem == TRUE))
	{
		return IncorrectSubsystem;
	}
	else
	{
		return DL_FALSE;
	}
	
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Checks whether subsystem supports Interrupt mode.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f DoesDeviceSupportIRQ> Function determines if the subsystem
 *			 supports interrupts by querying the LDD.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f DoesDeviceSupportDMA>
 *
 ****************************************************************************/
// Modified by DR: Removed need for device and subsystem.
ERRORCODES DoesDeviceSupportIRQ(
	LPServiceRequest pSR)		//@parm Pointer to DriverLINX Service Request
 
{
	BOOL IRQ = FALSE;
	BOOL NoSystem = FALSE;

	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		  return ValidSR;	 //return error code associated with the SR
	}

	//Get pointer to the LDD
	HANDLE hLDD = NULL;
	LPLDD pLDD = NULL;
	ERRORCODES Code = GetDriverLINXLDD(pSR, pSR->device, &hLDD, &pLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}

	switch (pSR->subsystem)
	{
		case(AI):
			if (pLDD->AnaChan[1].An_IntChan != -1)
			{
				IRQ = TRUE;
			}
			break;
		case(AO):
			if (pLDD->AnaChan[0].An_IntChan != -1)
			{
				IRQ = TRUE;
			}
			break;
		case(DI):
			if (pLDD->DigChan[1].Di_IntChan != -1)
			{
				IRQ = TRUE;
			}
			break;
		case(DO):
			if (pLDD->DigChan[0].Di_IntChan != -1)
			{
			IRQ = TRUE;
			}
			break;
		case(CT):
			if (pLDD->CTChan.CT_IntChan != -1)
			{
				IRQ = TRUE;
			}
			break;
		default:
			IRQ = FALSE;
			NoSystem = TRUE;
			break;
	}
	//Unlock the pointer and free memory associated with the LDD
	Code = FreeDriverLINXLDD(&pLDD, &hLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}
		
	if (IRQ == TRUE)
	{
		return DL_TRUE;
	}
	else if ((IRQ = FALSE) && (NoSystem = TRUE))
	{
		return IncorrectSubsystem;
	}
	else
	{
		return DL_FALSE;
	}
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Unlocks the LDD and releases any associated memory.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f FreeDriverLINXLDD> This function unlocks the LDD and releases 
 *			 any memory associated with the LDD.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f GetDriverLINXLDD>
 *
 ****************************************************************************/
ERRORCODES FreeDriverLINXLDD(
				LPLDD *pLDD,	   //@parm Pointer to the LDD
				HANDLE *hLDD)	   //@parm Pointer to the LDD's handle
{
	// ASSERT(pLDD != NULL);
	// ASSERT(hLDD != NULL);
	//Unlock the pointer
	if (*pLDD != NULL)
	{
		UnlockLDD(*pLDD);
		*pLDD = NULL;
		//Free memory associated with the LDD
		if (*hLDD != NULL)
		{
			FreeLDD(*hLDD);
			*hLDD = NULL;
			return DL_TRUE;
		}
		else
		{
			return InvalidLDDhandle;
		}
	}
	else
	{
		return NullLDDPointer;
	}
	
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Converts and returns Analog input data.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f GetDriverLINXAIData> This function converts the A/D data in 
 *			 the buffer(s) to volts while taking into account the channel(s) 
 *			 gain. Data is returned in pData.
 *
 * @xref	 <f PutDriverLINXAIData>
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES GetDriverLINXAIData(
	LPServiceRequest pSR,	//@parm Pointer to DriverLINX Service Request
	unsigned short *pData,			//@parm Pointer to the data that is to be converted
	const UINT BufIndex,	//@parm Buffer of data to convert
	const UINT ChannelsSampled,		//@parm Number of channels sampled
	const UINT SamplesPerChannel)   //@parm Samples Per Channel
{
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		return ValidSR;	   //return error code associated with the SR
	}

	DL_SERVICEREQUEST ssr;	//create second service request
	ssr = *pSR;				//copy users service request.
							//This way current settings are not disturbed.

	ssr.operation = CONVERT;
	ssr.mode = OTHER;
	ssr.taskFlags = 0;
	ssr.start.typeEvent = DATACONVERT;
	ssr.start.u.dataConvert.startIndex = 0;
	ssr.start.u.dataConvert.nSamples = SamplesPerChannel * ChannelsSampled;
	ssr.start.u.dataConvert.numberFormat = tINTEGER;
	ssr.start.u.dataConvert.scaling = 0.0f;
	ssr.start.u.dataConvert.offset = 0.0f;
	ssr.start.u.dataConvert.wBuffer = BufIndex;
	ssr.start.u.dataConvert.lpBuffer = pData;

	DriverLINX(&ssr);  //submit service request
	//Check Status
	const int Length = 80;
	char Status[Length];
	WORD ResultCode = GetDriverLINXStatus( &ssr, Status, Length);
	if (ResultCode != 0)
	{
		pSR->result = ssr.result;
		return DataConversionFailure;
	}
	else
	{
		return DL_TRUE;
	}
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Gets a pointer to the LDD.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f GetDriverLINXLDD> This function returns the LDD's pointer and 
 *			 its handle.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f FreeDriverLINXLDD>
 *
 ****************************************************************************/
ERRORCODES GetDriverLINXLDD(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const UINT device,			//@parm Device number
	HANDLE *hLDD,				//@parm Pointer to the LDD's handle	
	LPLDD *pLDD)				//@parm Pointer to the LDD
{
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		return ValidSR;
	}
	//Get handle for LDD
	HANDLE hLocal = GetLDD(pSR->hWnd, device);
	if (hLocal == NULL)
	{
		return InvalidLDDhandle;
	}
	//Get pointer for LDD
	LPLDD pLocal = LockLDD(hLocal);
	if (pLocal == NULL)
	{
		return NullLDDPointer;
	}
	*hLDD = hLocal;	//return values to calling routine
	*pLDD = pLocal;
	return DL_TRUE;
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Returns the result code and the associated text message.
 *
 * @rdesc    WORD - returns the result code for the operation.
 *
 * @comm     <f GetDriverLINXStatus> This function returns the result code for
 *			 the operation and also returns a pointer to a text message for 
 *			 the associated result code.
 *
 * @xref	 <f ShowDriverLINXStatus>, <f InterpretDriverLINXError>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
WORD GetDriverLINXStatus(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	LPSTR pStatus,				//@parm Pointer to the result code message
	const UINT dwSize)			//@parm Size of the result code message
{
	// ASSERT(pSR != NULL);
	// ASSERT(pStatus != NULL);
	//Get the status message
	ReturnMessageString(pSR->hWnd, pSR->result, pStatus, dwSize);

	//DriverLINX returns the result in the result field
	return pSR->result;
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Displays a message box describing the error code
 *
 * @comm     <f InterpretDriverLINXError> This function displays a message 
 *			 associated with an ERRORCODES, which is an enumerated data  
 *			 type defined in DrvVCLib.h. Messages are defined in DrvVCLib.rc
 *
 * @xref	 <f ERRORCODES>, <f ShowDriverLINXStatus>, <f GetDriverLINXStatus>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
// Edited By SK on 10 April 2001 for use in the keithley adaptor with matlab.
UINT InterpretDriverLINXError(
		const ERRORCODES Code)		//@parm Error code to interpret
{
		// ASSERT(Code >= 0);
		if (Code <= 14)
		{
			 return (IDS_ERROR_FALSE + Code);
		}
		else
		{
			 return (IDS_ERROR_UNDEFINED);
		}
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Verifies the Service Request is valid.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f IsValidServiceRequest> This function provides error checking  
 *			 to verify that the pointer to the Service Request is valid. If
 *			 the Service Request is not valid the function returns the 
 *			 appropriate error code.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES IsValidServiceRequest(
	LPServiceRequest pSR)	  //@parm Pointer to DriverLINX Service Request.
{
	// ASSERT(pSR != NULL);
	if (pSR == NULL)
	{
		return NULLServiceRequest;
	}
	else if (IsWindow(pSR->hWnd) == FALSE)
	{
		return InvalidWindowHandle;	
	}
	else if (pSR->dwSize != sizeof(DL_SERVICEREQUEST))
	{
		return InvalidSRSize;
	}
	else
	{
		return DL_TRUE;
	}
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Writes data to the output buffer.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f PutDriverLINXAOData> This function converts user input 
 *			 voltage(s) and converts them to D/A units and writes it to the output
 *			 buffer. Single value D/A conversions units are returned in the ioValue.
 *
 * @xref	 <f GetDriverLINXAIData>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES PutDriverLINXAOData(
		LPServiceRequest pSR,	 //@parm Pointer to DriverLINX Service Request
		unsigned short *pData,			 //@parm Pointer to the output voltage
		const UINT BufIndex,	//@parm Buffer of data to convert
		const UINT ChannelsSampled,		//@parm Number of channels sampled
		const UINT SamplesPerChannel)   //@parm Samples Per Channel
		
{
	//data is the value in volts to write, the AD units are returned
	//to the ioValue
	// ASSERT(pSR != NULL);
	// ASSERT(pData != NULL);
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		return ValidSR;			//return error code associated with the SR
	}

	DL_SERVICEREQUEST ssr;	//create second service request
	ssr = *pSR;				//copy users service request.
							//This way current settings are not disturbed.

	ssr.operation = CONVERT;
	ssr.mode = OTHER;
	ssr.taskFlags = 0;
	ssr.start.typeEvent = DATACONVERT;
	ssr.start.u.dataConvert.startIndex = 0;
	ssr.start.u.dataConvert.nSamples = ChannelsSampled * SamplesPerChannel;
	ssr.start.u.dataConvert.numberFormat = tINTEGER;
	ssr.start.u.dataConvert.scaling = 0.0f;
	ssr.start.u.dataConvert.offset = 0.0f;
	ssr.start.u.dataConvert.wBuffer = BufIndex;
	ssr.start.u.dataConvert.lpBuffer = pData;

	
	DriverLINX(&ssr);  //submit service request
	//Check Status		
	const int Length = 80;
	char Status[Length];
	WORD ResultCode = GetDriverLINXStatus( &ssr, Status, Length);

	//copy ioValue from temporary service request to
	//ioValue of users service request.
	if (ssr.result == 0)
	{
		pSR->status.u.ioValue = ssr.status.u.ioValue;
		return DL_TRUE;
	}
	else
	{			
		pSR->result = ssr.result;
		return DataConversionFailure;
	}
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Stops an active DriverLINX task 
 *
 * @rdesc    WORD - returns the result code for the operation. 
 *
 * @comm     <f StopDriverLINXSR> This function stops an active DriverLINX
 *			 task.
 *
 * @xref	 <f AddStopEventOnCommand>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
 WORD StopDriverLINXSR(
	 LPServiceRequest pSR)	  //@parm Pointer to DriverLINX Service Request
 {
	Ops OriginalOp;
	
	//If an error has occurred DriverLINX can display a messagebox
	//that describes the status of a Service Request.
	OriginalOp = pSR->operation;	// Save the current operation
	pSR->operation = STOP;	// Change operation to immediately
									// terminate the requested task
	DriverLINX(pSR);
	pSR->operation = OriginalOp;	// Change operation back!
	
	return pSR->result;
 }

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the start type event of the Service Request.
 *
 * @comm     <f AddStartEventDigitalTrigger> sets up the start type event    
 *			 portion of the Service Request. This functions tells the 
 *			 Service Request to start task upon receiving the specified 
 *			 digital input trigger.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStartEventOnCommand>, <f AddStartEventNullEvent>,
 *			 <f AddStartEventAnalogTrigger>
 *
 ****************************************************************************/
void AddStartEventDigitalTrigger(
		LPServiceRequest pSR,	//@parm Pointer to DriverLINX Service Request
		SINT channel,			//@parm The channel to watch
		WORD mask,				//@parm The mask to apply to the channel, to get the line.
		SINT match,				//@parm The condition to test with
		WORD pattern)			//@parm The Pattern to match for - Matches for - Equals to.

{
	// ASSERT(pSR != NULL);
	pSR->start.typeEvent = DIEVENT;
	pSR->start.u.diEvent.channel = channel;//DI_EXTTRG;	//Specify external trigger
	pSR->start.u.diEvent.match = match;
	pSR->start.u.diEvent.mask = mask;
	pSR->start.u.diEvent.pattern = pattern;
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the stop type event of the Service Request.
 *
 * @comm     <f AddStopEventDigitalTrigger> sets up the start type event    
 *			 portion of the Service Request. This functions tells the 
 *			 Service Request to start task upon receiving the specified 
 *			 digital input trigger.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStartEventOnCommand>, <f AddStartEventNullEvent>,
 *			 <f AddStartEventAnalogTrigger>
 *
 ****************************************************************************/
void AddStopEventDigitalTrigger(
		LPServiceRequest pSR,	//@parm Pointer to DriverLINX Service Request
		SINT channel,			//@parm The channel to watch
		WORD mask,				//@parm The mask to apply to the channel, to get the line.
		WORD pattern)			//@parm The Pattern to match for - Matches for - Equals to.

{
	// ASSERT(pSR != NULL);
	pSR->stop.typeEvent = DIEVENT;
	pSR->stop.u.diEvent.channel = channel;//DI_EXTTRG;	//Specify external trigger
	pSR->stop.u.diEvent.match = FALSE;
	pSR->stop.u.diEvent.mask = mask;
	pSR->stop.u.diEvent.pattern = pattern;
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the start type event of the Service Request.
 *
 * @comm     <f AddStopEventAnalogTrigger> sets up the start type event    
 *			 portion of the Service Request. This functions tells the 
 *			 Service Request to start task upon the analog trigger 
 *			 meeting the criteria defined below with the Flags and Threshold
 *			 arguments. 
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddStartEventOnCommand>, <f AddStartEventNullEvent>,
 *			 <f AddStartEventDigitalTrigger>
 *
 ****************************************************************************/
 ERRORCODES AddStopEventAnalogTrigger(
		LPServiceRequest pSR,	//@parm Pointer to DriverLINX Service Request
		const UINT device,		//@parm Device number
		const SINT Channel,		//@parm Channel to be used as the trigger
		const SubSystems subsystem, //@parm Desired subsystem
		const float Gain,		//@parm Selected trigger channels gain
		const float UpperThreshold,	//@parm Upper threshold voltage
		const float LowerThreshold,	//@parm Lower threshold voltage
		const WORD Flags)			//@parm Flags that define the trigger
{
	// ASSERT(pSR != NULL);
	LONG lUpperCode = 0;
	LONG lLowerCode = 0;

	pSR->stop.typeEvent = AIEVENT;
	pSR->stop.u.aiEvent.channel = Channel;	
	pSR->stop.u.aiEvent.gain = Gain2Code(device, AI, Gain);
	pSR->stop.u.aiEvent.flags = Flags;

	ERRORCODES Code = ConvertVoltsToADUnits(pSR, device, subsystem, UpperThreshold,
											Gain, &lUpperCode);
	if (Code == DL_TRUE)
	{
		pSR->stop.u.aiEvent.upperThreshold = static_cast<SINT>(lUpperCode);	
	}
	else //False
	{
		return Code;
	}


	Code = ConvertVoltsToADUnits(pSR, device, subsystem, UpperThreshold,
											Gain, &lLowerCode);
	if (Code == DL_TRUE)
	{
		pSR->stop.u.aiEvent.lowerThreshold = static_cast<SINT>(lLowerCode);	
	}
	else //False
	{
		return Code;
	}

	return DL_TRUE;
}

 /****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Converts a voltage to the equivalent A/D units.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f ConvertVoltsToADUnits> This function converts a voltage to  
 *			 the equivalent A/D units. This function first determines if the 
 *			 device supports a channel gain list. If the device supports a
 *			 channel gain list the user input is compared to limits
 *			 based on the Gain Multiplier Table. If the channel gain list is 
 *			 not supported the user input is compared to the values stored in 
 *			 the Min/Max Range Table. Then the user input is converted to the 
 *			 equivalent A/D units and returned in the lADUNIT argument. If the 
 *			 userinput value is out of range the function will return a 
 *			 AToDConversionFailure error and will fill the lADUNIT with either 
 *			 the maximum or minimum A/D unit based on whether the user
 *			 input is less than the minimum or greater than the maximum A/D 
 *			 value with an AToDConversionFailure 
 *
 * @xref	 <f IsInDriverLINXAnalogRange>,
 *			 <f IsInDriverLINXDigitalRange>,
 *			 <f IsInDriverLINXExtendedDigitalRange>,
 *			 <f DoesDeviceSupportAnalogChannelGainList>
 *
 * @devnote  KevinD 4/16/98 3:15:00PM
 *
 ****************************************************************************/
ERRORCODES ConvertVoltsToADUnits(
	LPServiceRequest pSR,	  //@parm Pointer to DriverLINX Service Request
	const UINT device, 		  //@parm Device number
	const SubSystems subsystem,  //@parm Desired subsystem
	const float userinput, 		 //@parm Analog value(V) to check
	const float gain,			 //@parm Gain code of value to check
	LONG *lADUNIT)				 //@parm Converted A/D value
{
	//Function returns true if value submitted falls between
	//the allowable low and high range analog limits.
	// ASSERT(pSR != NULL);
	// ASSERT((subsystem >= AI) && (subsystem <= CT));
	//// ASSERT(gain != 0);
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		return ValidSR;		//return error code associated with the SR
	}

	//Test for channel gain list support
 	ERRORCODES GainList = DoesDeviceSupportAnalogChannelGainList
												(pSR, subsystem, device);
	if (GainList > DL_TRUE)
	{
		return GainList;
	}

	//Get pointer to the LDD
	HANDLE hLDD = NULL;
	LPLDD pLDD = NULL;
	ERRORCODES Code = GetDriverLINXLDD(pSR, device, &hLDD, &pLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}
	BOOL Range = FALSE;
	BOOL NoSystem = FALSE;
	float TestMin, TestMax;
	SINT AnalogIndex = (subsystem == AO) ? 0 : 1;
	LONG lMinCode;
	LONG lMaxCode;
	BOOL bMatch = FALSE;
	BOOL bBipolar;


	if (gain < 0) {
        bBipolar = TRUE;
	}
    else {
        bBipolar = FALSE;
	}

	if ((subsystem == AI) || (subsystem == AO))
	{
		
		if (GainList == DL_TRUE) //system supports gain list
		{
			
			int i = 0;
			do
			{
				float Result = pLDD->AnaChan[AnalogIndex].lpAnGainMult->ArrayList[i].Multiplier - (float)fabs(gain);
				if (fabs(Result) < 0.1)
				{
					TestMin = 
						pLDD->AnaChan[AnalogIndex].lpAnGainMult->ArrayList[i].min; 
					TestMax = 
						pLDD->AnaChan[AnalogIndex].lpAnGainMult->ArrayList[i].max; 
					//Check to see that we have obtained the correct data from
					//channel gain table
					switch (bBipolar)
					{
					case TRUE:
						{
							if (TestMin < 0) { bMatch = TRUE; }
						}
					case FALSE:
						{
							if (TestMin >= 0) { bMatch = TRUE; }
						}
					}
				}
					i = i++;
				
			} while ((bMatch != TRUE) && (i < pLDD->AnaChan[AnalogIndex].lpAnGainMult->Nentries));

		}
		else	//check the analog min/max range table
		{
			TestMin = pLDD->AnaChan[AnalogIndex].lpAnMinMaxRange->min; 
			TestMax = pLDD->AnaChan[AnalogIndex].lpAnMinMaxRange->max;
		}

		
		//Test userinput versus allowable range
		if ((userinput >= TestMin) && (userinput <= TestMax))
			{
				Range = TRUE;
				//Determine Minimum and Maximum ADUnits that channel supports
				lMinCode = 
					pLDD->AnaChan[AnalogIndex].lpAnMinMaxRange->minCode;
				lMaxCode = 
					pLDD->AnaChan[AnalogIndex].lpAnMinMaxRange->maxCode;
				//Calculate ADUnits
				*lADUNIT = (LONG)((userinput - TestMin)/(TestMax - TestMin) * 
					      ((1L << pLDD->AnaChan[AnalogIndex].AnBits) -1) +
						  lMinCode + 0.5);
			}
			else
			{
				Range = FALSE;
				if (userinput > TestMax)
				{
					*lADUNIT = pLDD->AnaChan[AnalogIndex].lpAnMinMaxRange->maxCode;
				}
				else
				{
					*lADUNIT = pLDD->AnaChan[AnalogIndex].lpAnMinMaxRange->minCode;
				}
			}

		
	}
	else	//Invalid subsystem
	{
		NoSystem = TRUE;
		Range = FALSE;
	}

	  
	//Unlock the pointer and free memory associated with the LDD
	Code = FreeDriverLINXLDD(&pLDD, &hLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}
	
	if (Range == TRUE)
	{
		return DL_TRUE;		//Valid value and Volts have been converted
	}
	else if ((NoSystem == TRUE) && (Range == FALSE))
	{
		lADUNIT = 0;	//invalid AD value
		return IncorrectSubsystem;
	}
	else
	{
		return AToDConversionFailure;	//Out of Range value - Function will 
										//return either min or max value
	}
}

/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Checks whether subsystem supports a channel gain list.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f DoesDeviceSupportAnalogChannelGainList> Function determines  
 *			 if the analog subsystem supports a channel gain list by querying 
 *			 the LDD. Function is only valid for analog IO subsystems.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f IsInDriverLINXAnalogRange>
 *
 ****************************************************************************/
ERRORCODES DoesDeviceSupportAnalogChannelGainList(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const SubSystems subsystem,	//@parm Desired subsystem
	const UINT device) 			//@parm Device number
{
	// ASSERT(pSR != NULL);
	// ASSERT((subsystem >= AI) && (subsystem <= CT));
    // ASSERT(device >= 0);
	BOOL bGainList = FALSE;	

	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		  return ValidSR;	 //return error code associated with the SR
	}

	if ((subsystem != AI) && (subsystem != AO))
	{
		return IncorrectSubsystem;
	}
	//Get pointer to the LDD
	HANDLE hLDD = NULL;
	LPLDD pLDD = NULL;
	ERRORCODES Code = GetDriverLINXLDD(pSR, device, &hLDD, &pLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}

	SINT AnalogIndex = (subsystem == AI) ? 1 : 0; //set the AnalogIndex
	//If the number of entries in the AnChanGainMaxEntries = 0
	//Channel gain lists are not supported.
	WORD Entries = 	pLDD->AnaChan[AnalogIndex].AnChanGainMaxEntries;
	if ((Entries == 0) || (pLDD->AnaChan[AnalogIndex].lpAnGainMult == NULL))  //not supported
	{
		 bGainList = FALSE;
	}
	else   //supported
	{
		bGainList = TRUE;
	}


	//Unlock the pointer and free memory associated with the LDD
	Code = FreeDriverLINXLDD(&pLDD, &hLDD);
	if (Code != DL_TRUE)
	{
		return Code;
	}

	if(bGainList)
	{
		return DL_TRUE;
	}
	else
	{
		return DL_FALSE;
	}
	
}


/****************************************************************************
 * @doc UtilityFunctions
 *
 * @func     Checks whether digital value is within the channels range.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f IsInDriverLINXDigitalRange> This function queries the LDD and 
 *			 compares the user input with the channels acceptable limits.
 *
 * @xref	 <f IsInDriverLINXAnalogRange>, 
 *			 <f IsInDriverLINXExtendedDigitalRange>,
 *			 <f ConvertVoltsToADUnits>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES IsInDriverLINXDigitalRange(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const UINT device,			//@parm Device number
	const SubSystems subsystem, //@parm Desired subsystem
	const DWORD userinput)		//@parm Digital value to check
{
	//Function returns true if value submitted falls between
	//the allowable low and high range digital limits.
	  // ASSERT(pSR != NULL);
	  // ASSERT(device >= 0);
	  // ASSERT((subsystem >= AI) && (subsystem <= CT));
	  // ASSERT(userinput >= 0);
	  ERRORCODES ValidSR = IsValidServiceRequest(pSR);
		if (ValidSR != DL_TRUE)
		{
			return ValidSR;		//return error code associated with the SR
		}
		//Get pointer to the LDD
		HANDLE hLDD = NULL;
		LPLDD pLDD = NULL;
		ERRORCODES Code = GetDriverLINXLDD(pSR, device, &hLDD, &pLDD);
		if (Code != DL_TRUE)
		{
			return Code;
		}
 
		BOOL NoSystem = 
			((subsystem == DO) && (subsystem == DI)) ? TRUE : FALSE;
		BOOL Range = FALSE;
		SINT DigitalIndex = (subsystem == DO) ? 0 : 1;
		if ((userinput >= 0) &&
		  (userinput <= pLDD->DigChan[DigitalIndex].lpDiCapabilities->DiMask))
		{
			Range = TRUE;
		}
		//Unlock the pointer and free memory associated with the LDD
		Code = FreeDriverLINXLDD(&pLDD, &hLDD);
		if (Code != DL_TRUE)
		{
			return Code;
		}
		
		if (Range == TRUE)
			{
				return DL_TRUE;
			}
		else if (NoSystem == TRUE) 
			{
				return IncorrectSubsystem;
			}
		else
			{
				return DL_FALSE;
			}	    
}


/****************************************************************************
 * @doc ServiceRequests
 *
 * @func     Configures a digital IO channel as input or output.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f SetupDriverLINXInitDIOPort> This function sets up a Service 
 *			 Request that configures a digital channel as either an input
 *			 or an output channel if the board supports this feature. This
 *			 Service Requests is aimed at boards such as the Metrabyte PIO
 *			 series boards that have the Intel 8255 chip.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES SetupDriverLINXInitDIOPort(
		LPServiceRequest pSR,	//@parm Pointer to DriverLINX Service Request
		const UINT device, 		//@parm device number
		const SINT Channel,		//@parm Channel to configure
		const SubSystems subsystem, //@parm desired subsystem
		const BOOL Synchronous)	//@parm select between sync. and async. task
{
	// ASSERT(pSR != NULL);
	// ASSERT(device >= 0);
	// ASSERT(Channel >= 0);
	// ASSERT((subsystem == DI) || (subsystem == DO));
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		return ValidSR;
	}
	/*---------------------- Service Request Group --------------------*/
	//AddRequestGroupConfigure(pSR, device, subsystem);
	pSR->mode = OTHER;
	pSR->operation = CONFIGURE;



	/*--------------------------- Event Group -------------------------*/
	//Specify timing event
	AddTimingEventDIConfigure(pSR, Channel);

	//Specify start event
	AddStartEventNullEvent(pSR);
	//Specify stop event
	AddStopEventNullEvent(pSR);


	/*----------------------- Select Channel Group --------------------*/
	//Specify the channels, gain and data format
	AddSelectZeroChannels(pSR);

	/*----------------------- Select Buffers Group --------------------*/
	//Single value transfers do not use buffers
	AddSelectBuffers(pSR, 0, 0, 0);

	/*--------------------------- Select Flags ------------------------*/
	//Single-value I/O doesn't need ServiceStart or ServiceDone events
	WORD flags = CS_NONE; 
	pSR->taskFlags = flags;

	/* NOTE: you do not have to block any messages. However,
			 DriverLINX is somewhat more efficient if you do.
			 
	  NOTE: Your application must submit the service request to execute this 
			function.
	*/
		return DL_TRUE;
	
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the timing type event of the Service Request.
 *
 * @comm     <f AddTimingEventDIConfigure> sets up the timing type 
 *			 event portion of the Service Request. This functions sets up 
 *			 the timing event for configuring digital IO.  
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddTimingEventNullEvent>, <f AddTimingEventDefault>
 *			 <f AddTimingEventBurstMode>,
 *			 <f AddTimingEventExternalDigitalClock>,
 *			 <f AddTimingEventSyncIO>
 *
 ****************************************************************************/
void AddTimingEventDIConfigure(
	LPServiceRequest pSR,		//@parm Pointer to DriverLINX Service Request
	const int Channel)			//@parm Channel to be configured.
{
	// ASSERT(pSR != NULL);
	pSR->timing.typeEvent = DIOSETUP;
	pSR->timing.u.diSetup.channel = Channel;
	pSR->timing.u.diSetup.mode = DIO_BASIC;
	
}

bool SupportsSubSystem(LDD* ldd, int subsystem)
{
	//Convert the subsystem number to a bit-number in the LDD's
	// device feature map
	SINT system = (SINT)pow (2,(SINT)subsystem);
	//Is the bit that corresponds to the requested subsystem
	//set in the LDD's FeatureBitMap?
	if(ldd)
	{
		SINT SupportedSubsystem = (ldd->DevCap.FeatureBitMap & system);
		if(SupportedSubsystem == system)
		{
			if((subsystem == DI))
			{
				
				int numberOfChans = ldd->DigChan[1].NDiChan;
				int numberOfChansLoop = numberOfChans;
				//if channel is an external clock channel or a external
				//trigger channel don't include in channel count
				for ( int i = 0; i < numberOfChansLoop; i++ )
				{
					if ((ldd->DigChan[1].lpDiCapabilities[ i ].DiType == ExtTrgChn) || 
						(ldd->DigChan[1].lpDiCapabilities[ i ].DiType == ExtClkChn))
					// We have found a problem with the DDA-08. It has digital Trigger and Clocking
					//  and gating channels but no DI subsystem, but checking the type does not pick
					//  up the gating 
					//if (ldd->DigChan[1].lpDiCapabilities[ i ].DiMask == 1)
					{
						(numberOfChans)--;
					}
				}

				if (numberOfChans == 0) return false;
				else return true;
			}
			else
				return true;
		}
		
	}

	return false;
}

/****************************************************************************
 * @doc ServiceRequests
 *
 * @func     Reads or writes single I/O value.
 *
 * @rdesc    ERRORCODES - returns if succeeded or failed, if failed returns an
 *			 appropriate error code.
 *
 * @comm     <f SetupDriverLINXSingleValueIO> This function sets up a Service 
 *			 Request that either inputs or outputs one value from/to a  
 *			 subsystem. 
 *
 * @xref	 <f PutDriverLINXAIData>,<f GetDriverLINXAIData>
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 ****************************************************************************/
ERRORCODES SetupDriverLINXSingleValueIO(
		LPServiceRequest pSR,	//@parm Pointer to DriverLINX Service Request
		const SINT Channel,		//@parm Channel to read or write to
		const float gain,		//@parm channels gain setting, 0 if Digital
		const BOOL Synchronous)	//@parm select between sync. and async. task
{
	const SINT ChannelsSampled = 1;
	ERRORCODES ValidSR = IsValidServiceRequest(pSR);
	if (ValidSR != DL_TRUE)
	{
		return ValidSR;
	}
	/*---------------------- Service Request Group --------------------*/
	ERRORCODES Code = AddRequestGroupStart(pSR, Synchronous);
	if (Code != DL_TRUE)
	{
		return Code;
	}


	/*--------------------------- Event Group -------------------------*/
	//Specify timing event
	AddTimingEventNullEvent(pSR);

	//Specify start event
	AddStartEventNullEvent(pSR);
	//Specify stop event
	AddStopEventNullEvent(pSR);


	/*----------------------- Select Channel Group --------------------*/
	//Specify the channels, gain and data format
	AddSelectSingleChannel(pSR, Channel, gain);

	/*----------------------- Select Buffers Group --------------------*/
	//Single value transfers do not use buffers
	AddSelectBuffers(pSR, 0, 0, 0);

	/*--------------------------- Select Flags ------------------------*/
	//Single-value I/O doesn't need ServiceStart or ServiceDone events
	WORD flags = (NO_SERVICESTART | NO_SERVICEDONE);
	pSR->taskFlags = flags;

	/* NOTE: you do not have to block any messages. However,
			 DriverLINX is somewhat more efficient if you do.
			 
	  NOTE: Your application must submit the service request to execute this 
			function.

	  NOTE: For output Service Requests make sure to set the ioValue prior to
			submitting the service request.
	*/
		return DL_TRUE;
	
}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the channels group portion of the Service Request.
 *
 * @comm     <f AddSelectSingleChannel> sets up the channel group portion of  
 *			 the Service Request. This function sets up the channel group for
 *			 a single channel.
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddSelectZeroChannels>, <f AddChannelGainList>,
 *			 <f AddStartStopList>
 *
 ****************************************************************************/
void AddSelectSingleChannel(
	LPServiceRequest pSR, 		//@parm Pointer to DriverLINX Service Request
	const SINT Channel,			//@parm Selected channel
	const float gain)	//@parm Selected channel gain, 0 for a digital channel
{
	 pSR->channels.nChannels = 1;
	 pSR->channels.numberFormat = tNATIVE;
	 pSR->channels.chanGain[0].channel = Channel;
	 pSR->channels.chanGain[1].channel = 0;
	 pSR->channels.chanGainList = NULL;		//zero when not used
	 int i;
	 for (i = 0; i < 1; i++)
	 {
		// For analog subsystems, you can specify a gain
		// supported by your hardware. Use a positive gain factor for 
		// unipolar I/O, or use a negative gain factor for bipolar I/O.
		if ((pSR->subsystem == AI) || (pSR->subsystem == AO))
		{	
			pSR->channels.chanGain[i].gainOrRange = 
										Gain2Code(pSR->device, pSR->subsystem, gain);		
		}
		else
		{
		 // For other subsystems, set the gain to zero.
			pSR->channels.chanGain[i].gainOrRange = 0;
		}
	 }

}

/****************************************************************************
 * @doc AddFunctions
 *
 * @func     Sets up the timing type event of the Service Request.
 *
 * @comm     <f AddTimingEventExternalDigitalClock> sets up the timing type 
 *			 event portion of the Service Request. This functions sets up 
 *			 the timing event to use an external clock source. It sets up
 *			 the Service Request to sample a channel at the external
 *			 clocks frequency.  
 *
 * @devnote  KevinD 8/5/97 11:05:00
 *
 * @xref	 <f AddTimingEventNullEvent>, <f AddTimingEventDefault>
 *			 <f AddTimingEventBurstMode>,
 *			 <f AddTimingEventDIConfigure>,
 *			 <f AddTimingEventSyncIO>
 *
 ****************************************************************************/
void AddTimingEventExternalDigitalClock(
	LPServiceRequest pSR)		//@parm Pointer to DriverLINX Service Request
{
	pSR->timing.typeEvent = DIEVENT;
	pSR->timing.delay = 0;
	pSR->timing.u.diEvent.channel = DI_EXTCLK;
	pSR->timing.u.diEvent.match = FALSE;
	pSR->timing.u.diEvent.mask = 1;
	pSR->timing.u.diEvent.pattern = 0;
	
}
