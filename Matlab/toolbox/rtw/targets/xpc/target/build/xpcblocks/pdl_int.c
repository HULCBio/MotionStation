/* $Revision: 1.1 $ */
//===========================================================================
//
// NAME:    pdl_int.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to interrupt processing functions
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


////////////////////////////////////////////////////////////////////////
//   
// INTERRUP PROCESSING SECTION
//
////////////////////////////////////////////////////////////////////////


//
// Function:    PdStopAndDisableAIn
//
// Parameters:  int board
//
// Returns:     VOID
//
// Description: Stop and disable AIn data acquisition operation.
//
//              Driver event eStopped is asserted.
//
// Notes:       * This routine must be called with device spinlock held! *
//
//
void pd_stop_and_disable_ain(int board)
{
    // Stop acquisition and disable A/D conversions.
    if (!pd_ain_sw_stop_trigger(board))
        //printf_F("pd_stop_and_disable_ain: cannot execute pd_ain_sw_stop_trigger\n");

    pd_board[board].AinSS.SubsysState = ssStopped;

    // Stop acquisition and disable A/D conversions.
    if (!pd_ain_set_enable_conversion(board, 0))
        //printf_F("pd_stop_and_disable_ain: cannot execute pd_ain_enable_conversion\n");

    pd_board[board].AinSS.dwEventsNew |= eStopped;

    //printf_E("i>pd_stop_and_disable_ain: stopped AIn.\n");
}


//
// Function:    PdProcessAInGetSamples
//
// Parameters:  int board
//              int bFHFState      -- flag: FHF state
//
// Returns:     VOID
// Returns:     NTSTATUS    -- STATUS_SUCCESS
//                          -- STATUS_UNSUCCESSFUL
//
// Description: Process AIn Get Samples to get all samples from board.
//              This function is called from a DPC to process the AIn
//              FHF hardware interrupt event by transferring data from
//              board to designated DAQ buffer.
//
//              Three types of buffer operation to handle:
//              1. Straight buffer, stop acquisiton when end is reached.
//              2. Wrapped buffer, functions like a queue, we add new samples
//                 at the Head and user removes samples from the Tail. Stop
//                 acquisiton when Head reaches Tail.
//              3. Recycled buffer, same as wrapped buffer, except that the
//                 Tail moves (by frame size increments) when buffer becomes
//                 full. (This is a very small variation from wrapped buffer).
//                 Solution is to check if less than a frame remains, recycle
//                 by incrementing ValueIndex if so, then proceed as with #2.
//
//              Three types of copy conditions to handle:
//              1. Straight buffer, copy from ValueIndex up to MaxValues.
//              2. Wrapped buffer, copy from Head up to end of buffer.
//              3. Wrapped buffer had wrapped, copy from Head up to Tail.
//
//              Driver events are updated on change of status.
//
// Notes:       * This routine must be called with device spinlock held! *
//
//
void pd_process_pd_ain_get_samples(int board, int bFHFState)
{

    u32   Count;                  // num samples in buffer (queue)
    u32   Head;                   // queue head (wrapped buffer)
    u32   Tail;                   // queue tail (wrapped buffer)
    u32   FrameValues;            // num values in frame
    u32   MaxValues;              // max buffer samples

    u32   NumSamplesRead;         // num samples read from board
    u32   NumToCopy;              // num samples to copy to buffer
    u32   NumCopied = 0;          // num samples already copied

    u16* pBuf = pd_board[board].AinSS.BufInfo.XferBuf;
    int  bWrapped = FALSE;

    //printf_T("i>pd_process_pd_ain_get_samples: board %d\n", board);

    // Verify that a driver buffer has been allocated.
    if ( !pBuf )
    {
        // Stop acquisition and disable A/D conversions.
        pd_stop_and_disable_ain(board);
        //printf_F("i>pd_stop_and_disable_ain: no driver buffer allocated\n");
        return;
    }

    // Verify that a buffer has been registered.
    if ( !pd_board[board].AinSS.BufInfo.databuf )
    {
        // Stop acquisition and disable A/D conversions.
        pd_stop_and_disable_ain(board);

        //printf_F("i>pd_stop_and_disable_ain: no registered Daq Buffer\n");
        return;
    }

    // Set parameters.
    Count = pd_board[board].AinSS.BufInfo.Count;
    Head  = pd_board[board].AinSS.BufInfo.Head;
    Tail  = pd_board[board].AinSS.BufInfo.Tail;
    FrameValues = pd_board[board].AinSS.BufInfo.FrameValues;
    MaxValues = pd_board[board].AinSS.BufInfo.MaxValues;

    //printf_T("(1)Count 0x%x Head 0x%x Tail 0x%x FrameValues 0x%x MaxValues 0x%x\n",Count, Head, Tail, FrameValues, MaxValues );

    if ( bFHFState )
    {
        //printf_E("i>pd_process_pd_ain_get_samples: bFHFState\n");

        // Get samples acquired and stored on board using AIn Block Transfer
        // We should get 512 samples in the BURST mode (4+512+4 clocks)
        // and rest of them in GETSAMPLES mode (samples*4 clocks)
        if ( !pd_ain_flush_fifo(board))
        {
            // Error: cannot execute PdAInFlushFifo.
            //printf_F("i>pd_process_pd_ain_get_samples: cannot execute pd_ain_flush_fifo\n");
            return;
        }
    }
    else
    {
        //printf_E("i>pd_process_pd_ain_get_samples: !bFHFState\n");

        // Get all samples acquired and stored on board.
        pd_board[board].AinSS.BufInfo.XferBufValueCount = 
        pd_ain_get_samples(board, 
                        pd_board[board].AinSS.BufInfo.XferBufValues,
                        pd_board[board].AinSS.BufInfo.XferBuf
                       );

        if (!pd_board[board].AinSS.BufInfo.XferBufValueCount)
        {
            //printf_F("i>pd_process_pd_ain_get_samples: cannot execute pd_ain_get_samples\n");
            return;
        }
    }

    //printf_T("i>pd_process_pd_ain_get_samples Xfer: requested: 0x%x returned 0x%x \n",pd_board[board].AinSS.BufInfo.XferBufValues,pd_board[board].AinSS.BufInfo.XferBufValueCount);


    //Alex: Imediate update fix
    if ( !bFHFState || pd_board[board].bImmUpdate)
    {
        // Get all samples acquired when ImediateUpdate is called
        pd_board[board].AinSS.BufInfo.XferBufValueCount = 
        pd_ain_get_samples(board, 
                        pd_board[board].AinSS.BufInfo.XferBufValues,
                        pd_board[board].AinSS.BufInfo.XferBuf
                       );
    }

    NumSamplesRead = pd_board[board].AinSS.BufInfo.XferBufValueCount;

    if ( NumSamplesRead == 0 )
    {
        //printf_E("i>pd_process_pd_ain_get_samples: no samples acquired since we last checked\n");
        return;
    }

    //-----------------------------------------------------------------------
    // Check if we need to recycle a frame past NumSamples read.
    if ( pd_board[board].AinSS.BufInfo.bRecycle )
    {
        if ( (Count + NumSamplesRead) >= MaxValues )
        {
            // Increment Tail to the next frame boundry.
            u32 NewTail = ( ((Head + NumSamplesRead + FrameValues) % MaxValues)
                              / FrameValues) * FrameValues;
            Count -= (NewTail >= Tail) ? (NewTail - Tail)                // not wrapped
                                       : ((MaxValues - Tail) + NewTail); // wrapped
            Tail = NewTail;

            pd_board[board].AinSS.dwEventsNew |= eFrameRecycled;
            //printf_E("i>pd_process_pd_ain_get_samples: eFrameRecycled.");
        }
    }

    //-----------------------------------------------------------------------
    // Check if buffer is full.
    //printf_T("(2)Count 0x%x Head 0x%x Tail 0x%x FrameValues 0x%x MaxValues 0x%x\n",Count, Head, Tail, FrameValues, MaxValues );

    if ( !pd_board[board].AinSS.BufInfo.bRecycle && (Count == MaxValues) )
    {
        // Stop acquisition and disable A/D conversions.
        if (pd_board[board].AinSS.BufInfo.bWrap)        
            pd_board[board].AinSS.dwEventsNew |= eFrameRecycled | eBufferError;
        pd_stop_and_disable_ain(board);

        //printf_Q("i>pd_process_pd_ain_get_samples: Buffer Full: eStopped."); //????
        return;
    }

    // Copy samples to buffer starting at Head up to end of buffer.
    // (Cases #1 and #2a).
    if ( Head >= Tail )
    {
        NumToCopy = (NumSamplesRead < (MaxValues - Head))?NumSamplesRead:(MaxValues - Head);
        //printf_T("(2)Copy: Dest: 0x%x Src: 0x%x NumToCopy: %d\n",(u32)pd_board[board].AinSS.BufInfo.databuf + Head,(u32)pBuf,NumToCopy);

#ifndef _NO_USERSPACE
        copy_to_user( (pd_board[board].AinSS.BufInfo.databuf + Head),
                      pBuf, (NumToCopy * 2) );
#else                      
              memcpy( (pd_board[board].AinSS.BufInfo.databuf + Head),
                      pBuf, (NumToCopy * 2) );
#endif

//        //printf_T("(2)Data Copied\n");

        Count += NumToCopy;
        Head = (Head + NumToCopy) % MaxValues;
        NumCopied = NumToCopy;

        // Check if we wrapped.
        if ( (NumCopied > 0) && (Head == 0) )
        {
            if (   pd_board[board].AinSS.BufInfo.bWrap
                || pd_board[board].AinSS.BufInfo.bRecycle )
            {
                ++pd_board[board].AinSS.BufInfo.WrapCount;
                pd_board[board].AinSS.dwEventsNew |= eBufferWrapped;
                //printf_E("i>pd_process_pd_ain_get_samples: eBufferWrapped\n");
            }
            bWrapped = TRUE;
        }
    }

    //printf_T("(3)Count 0x%x Head 0x%x Tail 0x%x FrameValues 0x%x MaxValues 0x%x\n", Count, Head, Tail, FrameValues, MaxValues );

    // Wrap buffer: copy samples to buffer starting at Head up to Tail
    // (Cases #2b and #3).
    if ( (NumSamplesRead - NumCopied > 0) && (Head < Tail) )
    {
        NumToCopy = ((NumSamplesRead - NumCopied) < (Tail - Head))?
                    (NumSamplesRead - NumCopied) : (Tail - Head);

        //printf_T("(3)Copy: Dest: 0x%x Src: 0x%x NumToCopy: %d\n", (u32)pd_board[board].AinSS.BufInfo.databuf + Head,(u32)pBuf,NumToCopy);
#ifndef _NO_USERSPACE
        copy_to_user((pd_board[board].AinSS.BufInfo.databuf + Head),
                     (pBuf + NumCopied), (NumToCopy * 2) );
#else
              memcpy((pd_board[board].AinSS.BufInfo.databuf + Head),
                     (pBuf + NumCopied), (NumToCopy * 2) );
#endif
//        //printf_t("(3)Data Copied\n");
        
        Count += NumToCopy;

        Head += NumToCopy;          // should never wrap (these cases cannot wrap buffer)
        NumCopied += NumToCopy;
    }

    // Set buffer event flags to alert DLL.
    if ( NumCopied > 0 )
    {
        pd_board[board].AinSS.dwEventsNew |= eDataAvailable;

        // Check if we reached end of buffer.
        if ( bWrapped )
        {
           pd_board[board].AinSS.dwEventsNew |= eBufferDone;
           //printf_E("i>pd_process_pd_ain_get_samples: eBufferDone\n");
        }

        // Check if we crossed a frame boundry.
        if ( bWrapped || ((Head / pd_board[board].AinSS.BufInfo.FrameValues)
                            > (pd_board[board].AinSS.BufInfo.Head
                                / pd_board[board].AinSS.BufInfo.FrameValues)) )
        {
            pd_board[board].AinSS.dwEventsNew |= eFrameDone;
            //printf_E("i>pd_process_pd_ain_get_samples: eFrameDone\n");
        }

        pd_board[board].AinSS.BufInfo.Count = Count; // value count
        pd_board[board].AinSS.BufInfo.Head  = Head;
        pd_board[board].AinSS.BufInfo.Tail  = Tail;
    }

    //printf_T("i>Count 0x%x Head 0x%x Tail 0x%x\n", Count, Head, Tail );

    pd_board[board].AinSS.BufInfo.XferBufValueCount = 0;

    // Check if buffer is full and acquistion needs to be stopped.
    if ( !pd_board[board].AinSS.BufInfo.bRecycle && (Count == MaxValues) )
    {
        // Buffer is full: stop acquisition.
        pd_stop_and_disable_ain(board);
        //printf_E("i>pd_process_pd_ain_get_samples: eStopped: values acquired\n");
    }

}


//
// Function:    PdProcessDriverEvents
//
// Parameters:  int board
//              pEvents     -- asserted board events struct
//
// Returns:     VOID
//
// Description: Process board events interrupt. This function is called
//              from a DPC to initiate processing of all driver handled
//              board events and re-enable the processed events.
//
// Notes:       * This routine must be called with device spinlock held! *
//
void pd_process_driver_events(int board, PTEvents pEvents)
{

    TEvents ClearEvents = {0};

    // Check AIn FF hardware interrupt event.
    if (pEvents->AIOIntr & AIB_FFSC)
    {
        // Process AIn Fifo Full (Overrun Error) hardware interrupt event.
        if ( pd_board[board].AinSS.dwChListChan > 1 )
        {
            // Stop acquisition and disable A/D conversions.
            pd_stop_and_disable_ain(board);
            pd_board[board].AinSS.dwEventsNew |= eStopped | eBufferError;
        }

        //TODO: MORE WORK HERE:
        // Apparently add restart flag and if it's set:
        // stop ; clear FIFO; adjust buffer; start 

        if ( !(pd_board[board].AinSS.dwEventsNew & eStopped) )
        {
            ClearEvents.AIOIntr |= AIB_FFSC;
            pd_board[board].AinSS.dwEventsNew |= eBufferError;
        }
        //printf_E("i>pd_process_driver_events: AIB_FF\n");
    }

    //--------------------------------------------------------------------
    // AIn
    // Check AIn FHF hardware interrupt event.
    if ( (pEvents->ADUIntr & AIB_FHF) || (pEvents->AIOIntr & AIB_FHFSC) )
    {
        // Process AIn Fifo Half Full hardware interrupt event.
        pd_process_pd_ain_get_samples(board, TRUE);

        if ( !(pd_board[board].AinSS.dwEventsNew & eStopped) )
            ClearEvents.AIOIntr |= AIB_FHFSC;
    }
    else
    {
        // Process any samples acquired upto this point.
        pd_process_pd_ain_get_samples(board, FALSE);
    }


    //--------------------------------------------------------------------
    // AOut
    // Check AOut Underrun Error hardware interrupt event.
    if (pEvents->AOutIntr & AOB_UndRunErrSC)
    {
        // Process AOut Underrun Error hardware interrupt event.
        if ( !(pd_board[board].AoutSS.dwEventsNew & eStopped) )
            ClearEvents.AOutIntr |= AOB_UndRunErrSC;

        pd_board[board].AoutSS.dwEventsNew |= eBufferError;
    }

    // Check AOut Half Done hardware interrupt event.
    if (pEvents->AOutIntr & AOB_HalfDoneSC) 
    {
        // Process AOut Half Done hardware interrupt event.
        if ( !(pd_board[board].AoutSS.dwEventsNew & eFrameDone) )
            ClearEvents.AOutIntr |= AOB_HalfDoneSC;

        pd_board[board].AoutSS.dwEventsNew |= eFrameDone;
    }

    // Check AOut Buffer done hardware interrupt event
    if (pEvents->AOutIntr & AOB_BufDoneSC) 
    {
        // Process AOut Buffer Done hardware interrupt event.
        if ( !(pd_board[board].AoutSS.dwEventsNew & eBufferDone) )
            ClearEvents.AOutIntr |= AOB_BufDoneSC;

        pd_board[board].AoutSS.dwEventsNew |= eBufferDone;
    }

    //--------------------------------------------------------------------
    // DIn
    // Check digital input hardware interrupt event
    if (pEvents->ADUIntr & DIB_IntrSC) //AI90821
    {
        // Process DIn hardware interrupt event.
        if ( !(pd_board[board].DioSS.dwEventsNew & eDInEvent) )
            ClearEvents.ADUIntr |= DIB_IntrSC;

        pd_board[board].DioSS.dwEventsNew |= eDInEvent;
    }

    //--------------------------------------------------------------------
    // UCT
    // Check UCT countdown hardware interrupt event
    if (pEvents->ADUIntr & (UTB_Uct0IntrSC|UTB_Uct1IntrSC|UTB_Uct2IntrSC))
    {
        //printf_E("i>PdProcessDriverEvents: UTB_UctXIntrSC");

        // Process Uct hardware interrupt event.
        if ( !(pd_board[board].UctSS.dwEventsNew & eUct0Event) )
        {

            if (pEvents->ADUIntr & UTB_Uct0IntrSC)
            {
                ClearEvents.ADUIntr |= UTB_Uct0IntrSC;
                pd_board[board].UctSS.dwEventsNew |= eUct0Event;
            }
        }

        if ( !(pd_board[board].UctSS.dwEventsNew & eUct1Event) )
        {
            if (pEvents->ADUIntr & UTB_Uct1IntrSC)
            {
                ClearEvents.ADUIntr |= UTB_Uct1IntrSC;
                pd_board[board].UctSS.dwEventsNew |= eUct1Event;
            }
        }

        if ( !(pd_board[board].UctSS.dwEventsNew & eUct2Event) )
        {
            if (pEvents->ADUIntr & UTB_Uct2IntrSC)
            {
                ClearEvents.ADUIntr |= UTB_Uct2IntrSC;
                pd_board[board].UctSS.dwEventsNew |= eUct2Event;
            }
        }
    }

    // re-enable events 
    pd_enable_events(board, &ClearEvents);
}


//
// Function:    PdNotifyUserEvents
//
// Parameters:  int board
//              PPD_EVENTS pEvents     -- asserted board events struct
//
// Returns:     BOOLEAN status  -- TRUE:  there are user events to report
//                                 FALSE: no events to report
//
// Description: Notify DLL of user events. This function is called from
//              a DPC to notify DLL of selected user events.
//
//              User events are not automatically re-enabled. Clearing
//              and thus re-enabling of user events is initiated by DLL.
//
//              The algorithm reports events to DLL/User for which the
//              notification bit is set and the new event bit is set.
//              The event notification bits are cleared for which events
//              asserted and the driver event status bits are cleared.
//
// Notes:       This function is called for each hardware interrupt,
//              therefore, we need to be as efficient as possible here.
//
//              * This routine must be called with device spinlock held! *
//
//
int pd_notify_user_events(int board, PTEvents pNewFwEvents)
{
    PTEvents pFwEventsNotify = &(pd_board[board].FwEventsNotify);
    int bNotifyUser = 0;

    // Check if there are any hardware interrupt events to report.
    if (  (pFwEventsNotify->ADUIntr  & pNewFwEvents->ADUIntr)
        | (pFwEventsNotify->AIOIntr  & pNewFwEvents->AIOIntr)
        | (pFwEventsNotify->AInIntr  & pNewFwEvents->AInIntr)
        | (pFwEventsNotify->AOutIntr & pNewFwEvents->AOutIntr) )
    {
        // Report hardware interrupt event to pending user IRP.
        bNotifyUser = TRUE;

        // Clear notification of asserted hardware interrupt events.
        pFwEventsNotify->ADUIntr  &= ~pNewFwEvents->ADUIntr;
        pFwEventsNotify->AIOIntr  &= ~pNewFwEvents->AIOIntr;
        pFwEventsNotify->AInIntr  &= ~pNewFwEvents->AInIntr;
        pFwEventsNotify->AOutIntr &= ~pNewFwEvents->AOutIntr;
    }

    //----------------------------------------------------------------------------
    // AIn
    // Check if there are any new AIn Driver generated events to report.
    if ( pd_board[board].AinSS.dwEventsNotify & pd_board[board].AinSS.dwEventsNew )
    {
        // Report AIn Driver generated events.
        bNotifyUser = TRUE;

        // Clear notification of asserted AIn Driver events.
        pd_board[board].AinSS.dwEventsNotify &= ~pd_board[board].AinSS.dwEventsNew;
        pd_board[board].AinSS.dwEventsStatus |= pd_board[board].AinSS.dwEventsNew;
        pd_board[board].AinSS.dwEventsNew = 0;
    }

    //printf_E("i>pd_notify_user_events: dwEventsNotify: 0x%x dwEventsStatus: 0x%x\n",  pd_board[board].AinSS.dwEventsNotify, pd_board[board].AinSS.dwEventsStatus);

    //----------------------------------------------------------------------------
    // AOut
    // Check if there are any new AOut Driver generated events to report.
    if ( pd_board[board].AoutSS.dwEventsNotify & pd_board[board].AoutSS.dwEventsNew )
    {
        // Report AOut Driver generated events.
        bNotifyUser = TRUE;

        // Clear notification of asserted AOut Driver events.
        pd_board[board].AoutSS.dwEventsNotify &= ~pd_board[board].AoutSS.dwEventsNew;
        pd_board[board].AoutSS.dwEventsStatus |= pd_board[board].AoutSS.dwEventsNew;
        pd_board[board].AoutSS.dwEventsNew = 0;
    }

    //----------------------------------------------------------------------------
    // DIn
    // Check if there are any DIn Driver generated events to report.
    if ( pd_board[board].DioSS.dwEventsNotify & pd_board[board].DioSS.dwEventsNew )
    {
        // Report DIn Driver generated events.
        bNotifyUser = TRUE;

        // Clear notification of asserted DIn Driver events.
        pd_board[board].DioSS.dwEventsNotify &= ~pd_board[board].DioSS.dwEventsNew;
        pd_board[board].DioSS.dwEventsStatus |= pd_board[board].DioSS.dwEventsNew;
        pd_board[board].DioSS.dwEventsNew = 0;
    }

    //----------------------------------------------------------------------------
    // UCT
    // Check if there are any UCT Driver generated events to report.
    if ( pd_board[board].UctSS.dwEventsNotify & pd_board[board].UctSS.dwEventsNew )
    {
        // Report UCT Driver generated events.
        bNotifyUser = TRUE;

        // Clear notification of asserted UCT Driver events.
        pd_board[board].UctSS.dwEventsNotify &= ~pd_board[board].UctSS.dwEventsNew;
        pd_board[board].UctSS.dwEventsStatus |= pd_board[board].UctSS.dwEventsNew;
        pd_board[board].UctSS.dwEventsNew = 0;
    }
    return bNotifyUser;
}


//
//
//
// Function:    PdProcessEvents
//
// Parameters:  int board
//
// Returns:     VOID
//
// Description: Process interrupt events. This function is called from
//              a DPC to get all board events, initiate processing of
//              driver handled events, notify DLL of user events, and
//              finally re-enable adapter interrupt.
//
void pd_process_events(int board)
{
    TEvents  EventsNew;

    //printf_E("i>pd_process_events: get it\n");
    
    // Get board status if not already done so in ISR.      (BS 28-JUL-98)
    pd_adapter_get_board_status(board, &EventsNew);

#ifdef PD_DEBUG_T
    pd_debug_show_events( &EventsNew, "i>events from bottom half");
#endif
    
    memcpy(&pd_board[board].FwEventsStatus, &EventsNew, sizeof(TEvents));

    // Process driver handled events.
    pd_process_driver_events(board, &EventsNew);
    
    //printf_S("i>pd_process_events: AIOIntr: 0x%x\n", EventsNew.AIOIntr);

    if (pd_notify_user_events(board, &EventsNew))
    {
        // if any process has registered for asynchronous notification,
        // notify them
        if (pd_board[board].fasync) 
        {
            //kill_fasync(pd_board[board].fasync, SIGIO);
            //printf_S("i>pd_notify_user_events\n");
        }
    }
}




