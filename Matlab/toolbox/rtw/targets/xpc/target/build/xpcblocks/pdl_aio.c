/* $Revision: 1.1 $ */
//===========================================================================
//
// NAME:    pdl_aio.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to Analog Input buffering functions
//
// AUTHOR:  Alex Ivchenko
//
// DATE:    12-APR-2000
//
// REV:     0.8
//
// R DATE:  
//
// HISTORY:
//
//      Rev 0.8,     12-MAR-2000,     Initial version.
//
//
//---------------------------------------------------------------------------
//      Copyright (C) 2000 United Electronic Industries, Inc.
//      All rights reserved.
//---------------------------------------------------------------------------
//
// this file is not to be compiled independently
// but to be included into pdfw_lib.c



//
// Function:    pd_register_daq_buffer
//
// Parameters:  int board
//
// Returns:     1 = SUCCESS
//              
//
// Description: register daq buffer. 
//
// Notes: To unregister daq buffer call with databuf = NULL
//
int pd_register_daq_buffer(int board, u32 ScanSize, u32 FrameSize, u32 NumFrames,
                           uint16_t* databuf, int bWrap, int bRecycle)
{
    // parameters check
    if (!(ScanSize && FrameSize && NumFrames && databuf))
        return 0;

    pd_board[board].AinSS.BufInfo.ScanSize = ScanSize;
    pd_board[board].AinSS.BufInfo.FrameSize = FrameSize;
    pd_board[board].AinSS.BufInfo.NumFrames = NumFrames;
    pd_board[board].AinSS.BufInfo.databuf = databuf;
    pd_board[board].AinSS.BufInfo.bWrap = bWrap;
    pd_board[board].AinSS.BufInfo.bRecycle = bRecycle;
    return 1;
}

int pd_unregister_daq_buffer(int board)
{
     pd_board[board].AinSS.BufInfo.databuf = NULL;
     return 1;
}
//
// Function:    pd_clear_daq_buffer
//
// Parameters:  int board
//              int subsystem - subsystem type
//
// Returns:     1 = SUCCESS
//              
//
// Description: The Clear DaqBuf function clears the DAQ Buffer and sets it
//              to the initialized state.
// Notes:
//
//u16 XFBufTemp[0x1000];  //FIXME: temp buffer for debug only: remove after debugging
int pd_clear_daq_buffer(int board, int subsystem)
{
    PTBuf_Info pDaqBuf;

    // AIn
    if (subsystem == AnalogIn)
    {
        if (pd_board[board].AinSS.SubsysState != ssConfig)
        {
    	    //printf_F("pd_clear_daq_buffer error: SubsysState != ssConfig\n");
            return 0;
        }
        pDaqBuf = &pd_board[board].AinSS.BufInfo;

        if (!pDaqBuf->XferBuf)
        {
    	    //printf_F("pd_clear_daq_buffer error: pDaqBuf->XferBuf == NULL\n");
            return 0;
        }
        if (!pDaqBuf->databuf)
        {
    		//printf_F("pd_clear_daq_buffer error: pDaqBuf->databuf == NULL\n");
            return 0;
        }


    	//printf_T("pd_clear_daq_buffer: buffer is prepared to run!\n");

        // Initialize DaqBuf status.
        pDaqBuf->Count = 0;
        pDaqBuf->Head = 0;
        pDaqBuf->Tail = 0;
        pDaqBuf->FrameValues = pd_board[board].AinSS.BufInfo.FrameSize *
                               pd_board[board].AinSS.BufInfo.ScanSize;
        pDaqBuf->ScanValues = pd_board[board].AinSS.BufInfo.ScanSize;
        pDaqBuf->MaxValues = pd_board[board].AinSS.BufInfo.FrameValues *
                             pd_board[board].AinSS.BufInfo.NumFrames;

        pDaqBuf->ValueCount = 0;
        pDaqBuf->WrapCount = 0;
        pDaqBuf->ValueIndex = 0;
        pDaqBuf->ScanIndex = 0;
        pDaqBuf->XferBufValueCount = 0;
//        pDaqBuf->XferBuf = XFBufTemp;
    
        pd_board[board].AinSS.dwEventsNotify = 0;
        pd_board[board].AinSS.dwEventsStatus = 0;
        pd_board[board].AinSS.dwEventsNew = 0;

    }

    //TODO: other subsystems


    return 1;
}

//
//
// Function:    pd_ain_async_init
//
// Parameters:  int board
//              PTAinAsyncCfg pAInCfg  -- AIn async config struct:
//
// Returns:     1 = SUCCESS
//
// Description: The AIn Initialize Asynchronous Buffered Acquisition function
//              initializes the configuration and allocates memory for buffered
//              acquisiton.
//
// Notes:       This driver function does NO checking on the hardware
//              configuration parameters, it is the responsibility of the
//              DLL to verify that the parameters are valid for the device
//              type being configured.
//
//
int pd_ain_async_init(int board, PTAinAsyncCfg pAInCfg)
{

    u32 UserEvents;

    // Get pointer to ((TBuf_Info)pd_board[board].AinSS.BufInfo)
    // FIXME: these are never used in this function?
    // PTBuf_Info pDaqBuf = &pd_board[board].AinSS.BufInfo;
    // TEvents EventsCfg = {0};
    // u32 i;

    // Check for ongoing process
    if (pd_board[board].AinSS.SubsysState == ssRunning) {
	//printf_F("pd_ain_async_init bails!  SubsysState == ssRunning!\n");
        return 0;
    }

    pd_board[board].AinSS.SubsysState = ssConfig;

    // Verify that a buffer has been properly registered.
    if (!pd_board[board].AinSS.BufInfo.databuf) {
	//printf_F("pd_ain_async_init bails!  no databuf!\n");
        return 0;
    }

    // Initialize DaqBuf status.
    if (!pd_clear_daq_buffer(board, AnalogIn)) {
	//printf_F("pd_ain_async_init bails!  pd_clear_daq_buffer failed!\n");
	return 0;
    }

    // Program AIn subsystem:
    pd_board[board].AinSS.dwAInCfg = pAInCfg->dwAInCfg;
    pd_board[board].AinSS.dwAInPreTrigCount = pAInCfg->dwAInPreTrigCount;
    pd_board[board].AinSS.dwAInPostTrigCount = pAInCfg->dwAInPostTrigCount;
    pd_board[board].AinSS.dwCvRate = pAInCfg->dwCvRate;
    pd_board[board].AinSS.dwClRate = pAInCfg->dwClRate;
    pd_board[board].AinSS.dwChListChan = pAInCfg->dwChListSize;
    if (pAInCfg->dwChListSize)
#ifndef _NO_USERSPACE
       copy_from_user(pd_board[board].AinSS.ChList, pAInCfg->dwChList, PD_MAX_CL_SIZE * sizeof(uint32_t));
#else
       memcpy(pd_board[board].AinSS.ChList, pAInCfg->dwChList, PD_MAX_CL_SIZE * sizeof(uint32_t));
#endif
       
    // Configure AIn subsystem
    if (!pd_ain_set_config(board, 
                        pd_board[board].AinSS.dwAInCfg,
                        pd_board[board].AinSS.dwAInPreTrigCount,
                        pd_board[board].AinSS.dwAInPostTrigCount
                       )) {
	//printf_F("pd_ain_async_init bails!  pd_ain_set_config failed!\n");
	return 0;
    }

    if (!pd_ain_set_cv_clock(board, pd_board[board].AinSS.dwCvRate)) {
	//printf_F("pd_ain_async_init bails!  pd_ain_set_cv_clock failed!\n");
	return 0;
    }

    if (!pd_ain_set_cl_clock(board, pd_board[board].AinSS.dwClRate)) {
	//printf_F("pd_ain_async_init bails!  pd_ain_set_cl_clock failed!\n");
	return 0;
    }

    if (!pd_ain_set_channel_list(board, pd_board[board].AinSS.dwChListChan,
                                     pd_board[board].AinSS.ChList)) {
	//printf_F("pd_ain_async_init bails!  pd_ain_set_channel_list failed!\n");
	return 0;
    }

    // Configure AIn firmware event interrupts.
    pd_board[board].FwEventsConfig.AIOIntr = AIB_FHFIm | AIB_FHFSC | AIB_FFIm | AIB_FFSC;
    if (!pd_enable_events(board, &pd_board[board].FwEventsConfig)) {
	//printf_F("pd_ain_async_init bails!  pd_enable_events failed!\n");
	return 0;
    }

    // Set AIn user events.
    UserEvents = eAllEvents;
    if (!pd_clear_user_events(board, AnalogIn, UserEvents)) {
	//printf_F("pd_ain_async_init bails!  pd_clear_user_events failed!\n");
	return 0;
    }

    if ( pAInCfg->dwEventsNotify )
    {
        UserEvents = pAInCfg->dwEventsNotify;
        if(!pd_set_user_events(board, AnalogIn, UserEvents)) {
	    //printf_F("pd_ain_async_init bails!  pd_set_user_events failed! UserEvents = 0x%08X\n", UserEvents);
	    return 0;
	}
    }

    pd_board[board].AinSS.SubsysState = ssStandby;

    return 1;
}

//
//
// Function:    pd_ain_async_term
//
// Parameters:  int board
//
// Returns:     1 = SUCCESS
//
// Description: The AIn Terminate Asynchronous Buffered Acquisition function
//              terminates and releases memory allocated for buffered
//              acquisition.
//
// Notes: 
//
int pd_ain_async_term(int board)
{
    TEvents Events;

    if (!pd_ain_sw_stop_trigger(board)) return 0;
    if (!pd_ain_set_enable_conversion(board, 0)) return 0;

    Events.AIOIntr = AIB_FHFIm;
    if (!pd_disable_events(board, &Events)) return 0;

    pd_board[board].AinSS.SubsysState = ssConfig;

    return 1;
}

//
// Function:    pd_ain_async_start
//
// Parameters:  PADAPTER_INFO pAdapter -- pointer to device extension
//
// Returns:     1 = SUCCESS
//
// Description: The AIn Start Asynchronous Buffered Acquisition function starts
//              buffered acquisition.
//
// Notes: 
//
int pd_ain_async_start(int board)
{
    if (pd_board[board].AinSS.SubsysState != ssStandby) 
    {
	    //printf_F("pd_ain_async_start fails!  SubsysState != ssStandby!\n");
    	return 0;
    }

    if (!pd_adapter_enable_interrupt(board, 1))
    {
        //printf_F("pd_ain_async_start: pd_adapter_enable_interrupt fails");
        return 0;
    }
    
    if (!pd_ain_set_enable_conversion(board, 1))
    {
        //printf_F("pd_ain_async_start: pd_ain_set_enable_conversion fails");
        return 0;
    }

    if ((pd_board[board].AinSS.dwAInCfg & (AIB_STARTTRIG0 | AIB_STARTTRIG1)) == 0)
        if (!pd_ain_sw_start_trigger(board)) 
    {        
        //printf_F("pd_ain_async_start: pd_ain_sw_start_trigger fails");
        return 0;
    }

    pd_board[board].AinSS.SubsysState = ssRunning;
 
    return 1;
}

//
// Function:    pd_ain_async_stop
//
// Parameters:  PADAPTER_INFO pAdapter -- pointer to device extension
//
// Returns:     1 = SUCCESS
//
// Description: The AIn Start Asynchronous Buffered Acquisition function stops
//              buffered acquisition.
//
// Notes: 
//
int pd_ain_async_stop(int board)
{
    if (pd_board[board].AinSS.SubsysState != ssRunning) 
    {
        //printf_F("pd_ain_async_stop: not in ssRunning state\n");
        return 0;
    }


    if (!pd_ain_sw_stop_trigger(board))
    {
        //printf_F("pd_ain_async_stop: not pd_ain_sw_stop_trigger\n");
        return 0;
    }
    
    if (!pd_ain_set_enable_conversion(board, 0))    
    {
        //printf_F("pd_ain_async_stop: not pd_ain_set_enable_conversion\n");
        return 0;
    }


    pd_board[board].AinSS.SubsysState = ssStopped;

    return 1;
}

//
// Function:    pd_ain_get_scans
//
// Parameters:  int board
//              PTScan_Info pScanInfo -- get scan info struct
//                  u32 NumScans      -- IN:  number of scans to get
//                  u32 ScanIndex     -- OUT: buffer index of first scan
//                  u32 NumValidScans -- OUT: number of valid scans available
//
// Returns:     1 = SUCCESS
//
// Description: The AIn Get Scans function returns the oldest scan index
//              in the DAQ buffer and releases (recycles) frame(s) of scans
//              that had been obtained previously.
//
// Notes: 
//
int pd_ain_get_scans(int board, PTScan_Info pScanInfo)
{
    PTBuf_Info pDaqBuf = &pd_board[board].AinSS.BufInfo;
    u32   HeadScan;
    u32   TailScan;
    u32   MaxScans;
    u32   FrameScans;
    u32   ScanIndex;
    u32   NumFramesToInc;
    u32   NewTail;
    u32   AvailScans = 0;

    //printf_P("pd_ain_get_scans:\n");

    // Get new scan index.
    pScanInfo->ScanIndex = ScanIndex = pDaqBuf->ScanIndex;
    HeadScan = pDaqBuf->Head / pDaqBuf->ScanValues;
    TailScan = pDaqBuf->Tail / pDaqBuf->ScanValues;
    MaxScans = pDaqBuf->MaxValues / pDaqBuf->ScanValues;
    FrameScans = pDaqBuf->FrameValues / pDaqBuf->ScanValues;

    //printf_P("pd_ain_get_scans recalc: ScanIdx=0x%x, HeadScan=0x%x, TailScan=0x%x, MaxScans=0x%x, FrameScans=0x%x\n", pScanInfo->ScanIndex, HeadScan, TailScan, MaxScans, FrameScans);


    // Get the maximum number of valid scans available up to the end of
    // the buffer.
    if ( ScanIndex == HeadScan )
        AvailScans = 0;
    else if ( ScanIndex < HeadScan )
        AvailScans = HeadScan - ScanIndex;
    else if ( HeadScan < ScanIndex )
        AvailScans = MaxScans - ScanIndex;

    pScanInfo->NumValidScans = (pScanInfo->NumScans < AvailScans)?
                                pScanInfo->NumScans:AvailScans;

    // Update the next scan index, (this value is used the next time this function is called).
    pDaqBuf->ScanIndex = (ScanIndex + pScanInfo->NumValidScans) % MaxScans;

    // Check if we should recycle frames(s).
    if ( pDaqBuf->bWrap || pDaqBuf->bRecycle )
    {
        // Did the scan index cross one or more frame boundries?
        if ( (ScanIndex / FrameScans) > (TailScan / FrameScans) )
        {
            // Increment Tail to the last frame boundry preceeding the new scan index.
            NumFramesToInc = (ScanIndex / FrameScans) - (TailScan / FrameScans);
            NewTail = ((TailScan / FrameScans) + NumFramesToInc) * pDaqBuf->FrameValues;
            pDaqBuf->Count -= NewTail - pDaqBuf->Tail;

            // Check if we wrapped and notify user.
            if ( NewTail >= pDaqBuf->MaxValues )
            {
                pd_board[board].AinSS.dwEventsNew |= eBufferWrapped;
            }

            pDaqBuf->Tail = NewTail % pDaqBuf->MaxValues;

        }
        else if ( (ScanIndex / FrameScans) < (TailScan / FrameScans) )
        {
            // Current scan index wrapped and is behind the tail.
            // Wrap tail and set it to 0.
            pDaqBuf->Count -= pDaqBuf->MaxValues - pDaqBuf->Tail;
            pDaqBuf->Tail = 0;
        }
    }

    //
    //printf_T("> Tail=%d, Head=%d, Count=%d, ScanIdx=%d, NxtScanIdx=%d, AvlScans=%d, NumScans=%d\n", pDaqBuf->Tail, pDaqBuf->Head,pDaqBuf->Count,ScanIndex,pDaqBuf->ScanIndex,AvailScans,pScanInfo->NumScans);
    //

    // Check if buffer is empty and notify user.
    if ( pDaqBuf->Count == 0 )
        return 0;

    return 1;
}

//
// Function:    pd_get_buf_status
//
// Parameters:  int board
//              int subsystem -- IN:  subsystem type
//              PTBuf_Info pDaqBuf -- DaqBuf status struct:
//                  u32 dwSubsysState    -- OUT: current subsystem state
//                  u32 dwScanIndex      -- OUT: buffer index of first scan
//                  u32 dwNumValidValues -- OUT: number of valid values available
//                  u32 dwNumValidScans  -- OUT: number of valid scans available
//                  u32 dwNumValidFrames -- OUT: number of valid frames available
//                  u32 dwWrapCount      -- OUT: total num times buffer wrapped
//                  u32 dwFirstTimestamp -- OUT: first sample timestamp
//                  u32 dwLastTimestamp  -- OUT: last sample timestamp
//
// Returns:     1 = SUCCESS
//
// Description: The Get DaqBuf status function obtains the current asynchronous
//              acquisition DAQ buffer status.
//
// Notes:
//
int pd_get_buf_status(int board, int subsystem, PTBuf_Info pDaqBuf)
{
    PTBuf_Info pDaqBuffer;

    // AIn
    if (subsystem == AnalogIn)
    {
        pDaqBuffer = &pd_board[board].AinSS.BufInfo;
#ifndef _NO_USERSPACE
        copy_to_user(pDaqBuf, pDaqBuffer, sizeof(TBuf_Info));
#else
        memcpy(pDaqBuf, pDaqBuffer, sizeof(TBuf_Info));
#endif        
        return 1;
    }

    //TODO: other subsystems    

    return 0;
}


