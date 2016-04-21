/* $Revision: 1.1.2.1 $ */
//===========================================================================
//
// NAME:    pdl_event.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver interface to event-related FW functions
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
//---------------------------------------------------------------------------//
//
// this file is not to be compiled independently
// but to be included into pdfw_lib.c

//////////////////////////////////////////////////////////////////////
//
// EVENT-RELATED FUNCTIONS
//
//////////////////////////////////////////////////////////////////////

//
// Function:    pd_enable_events
//
// Parameters:  int board
//              PTEvents pEvents     -- board events struct
//
// Returns:     1 = SUCCESS
//
// Description: Enable mask and/or clear status of interrupt event bits
//              of the four board event interrupt/status registers.
//
//              Specifying an event interrupt mask bit will enable the
//              event interrupt. Specifying an event interrupt status
//              bit will clear the event status, thus re-enabling the
//              event interrupt.
//
//              Event interrupt mask and status bits that are not specified
//              are not affected.
//
//              The four event registers used are:
//
//              ADUIntr   -- (ADUEIntrStat) AIn/AOut/DIn/UCT/ExTrig intr/stat
//              AIOIntr   -- (AIOIntr) AIn/AOut interrupt registers #1 & #2
//              AInIntr   -- (AInIntrStat) AIn Subsystem interrupt/status
//              AOutIntr  -- (AOutIntrStat) AOut Subsystem interrupt/status
//
// Notes:       AO, DIO and UCT events are to be implemented
//
//
int pd_enable_events(int board, PTEvents pEvents)
{

    u32 dwIntrStatus, dwIntrClear;
    u32 Status = 1;

    //-----------------------------------------------------------------------
    // ADUEIntrStat: AIn/AOut/DIn/UCT/ExTrig Interrupt/Status Register
    //
    if ( pEvents->ADUIntr )
    {
        // Set specified mask bits.
        pd_board[board].FwEventsConfig.ADUIntr |=
            (  (pEvents->ADUIntr & (UTB_Uct0Im | UTB_Uct1Im | UTB_Uct2Im | DIB_IntrIm))
             | (  BRDB_ExTrigIm | BRDB_ExTrigReSC | BRDB_ExTrigFeSC
                | UTB_Uct0IntrSC | UTB_Uct1IntrSC | UTB_Uct2IntrSC | DIB_IntrSC ) );

        // Clear specified status bits.
        dwIntrClear = pEvents->ADUIntr & (UTB_Uct0IntrSC | UTB_Uct1IntrSC | UTB_Uct2IntrSC | DIB_IntrSC);
        dwIntrStatus = pd_board[board].FwEventsConfig.ADUIntr & (~dwIntrClear);

        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_enable_events ADUIntr: 0x%x\n", dwIntrStatus);

        Status = pd_adapter_set_board_event1(board, dwIntrStatus);        
    }

    //-----------------------------------------------------------------------
    // AIOIntr: AIn/AOut Interrupt Registers #1 & #2
    if ( pEvents->AIOIntr )
    {
        // Set specified mask bits.
        pd_board[board].FwEventsConfig.AIOIntr |=
            (  (pEvents->AIOIntr & (  AIB_FHFIm | AIB_FFIm
                                    | AIB_CVStrtErrIm | AIB_CLStrtErrIm
                                    | AIB_OTRLowIm | AIB_OTRHighIm ))
             | (  AIB_CLDoneIm | AIB_CLDoneSC | AIB_FHFSC | AIB_FFSC
                | AIB_CVStrtErrSC | AIB_CLStrtErrSC | AIB_OTRLowSC | AIB_OTRHighSC ) );

        // Clear specified status bits.
        dwIntrStatus = pd_board[board].FwEventsConfig.AIOIntr
                        & ~(  pEvents->AIOIntr
                            & (  AIB_FHFSC | AIB_FFSC | AIB_CVStrtErrSC | AIB_CLStrtErrSC
                               | AIB_OTRLowSC | AIB_OTRHighSC ) );

        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_enable_events AIOIntr: 0x%x\n", dwIntrStatus);

        Status = pd_adapter_set_board_event2(board, dwIntrStatus);
    }

    //-----------------------------------------------------------------------
    // AIn Subsystem Interrupt/Status (AInIntrStat) Bits
    if ( pEvents->AInIntr )
    {
        //printf("pd_enable_events AInIntr: 0x%x\n", pEvents->AInIntr);
        // Set specified mask bits.
        pd_board[board].FwEventsConfig.AInIntr |=
            (  (pEvents->AInIntr & (  AIB_StartIm | AIB_StopIm
                                    | AIB_SampleIm | AIB_ScanDoneIm
                                    | AIB_ErrIm | AIB_BMPgDoneIm
                                    | AIB_BMErrIm | AIB_BMEmptyIm ))
             | (  AIB_StartSC | AIB_StopSC | AIB_SampleSC | AIB_ScanDoneSC
             | AIB_ErrSC | AIB_BMPg0DoneSC | AIB_BMPg1DoneSC | AIB_BMErrSC ) );


        // Clear specified status bits.
        dwIntrStatus = pd_board[board].FwEventsConfig.AInIntr
                & ~(  pEvents->AInIntr
                & (  AIB_StartSC | AIB_StopSC | AIB_SampleSC | AIB_ScanDoneSC
                | AIB_ErrSC | AIB_BMPg0DoneSC | AIB_BMPg1DoneSC | AIB_BMErrSC ) );
		dwIntrStatus |= pEvents->AInIntr & 0xf0000;
		
        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf("pd_enable_events AInIntr: 0x%x\n", dwIntrStatus);
                
        Status = pd_ain_set_events(board, dwIntrStatus);
    }
    
    //-----------------------------------------------------------------------
    // AOut Subsystem Interrupt/Status (AOutIntrStat) Bits
    //
    if ( pEvents->AOutIntr )
    {
        // Set specified mask bits.
        pd_board[board].FwEventsConfig.AOutIntr |=
            (  (pEvents->AOutIntr & (  AOB_StartIm | AOB_StopIm
                                     | AOB_ScanDoneIm | AOB_HalfDoneIm
                                     | AOB_BufDoneIm
                                     | AOB_UndRunErrIm | AOB_CVStrtErrIm ))
             | (  AOB_StartSC | AOB_StopSC | AOB_ScanDoneSC | AOB_HalfDoneSC
                | AOB_BufDoneSC | AOB_UndRunErrSC | AOB_CVStrtErrSC ) );

        // Clear specified status bits.
        dwIntrStatus = pd_board[board].FwEventsConfig.AOutIntr
                        & ~(  pEvents->AOutIntr
                            & (  AOB_StartSC | AOB_StopSC | AOB_ScanDoneSC | AOB_HalfDoneSC
                               | AOB_BufDoneSC | AOB_UndRunErrSC | AOB_CVStrtErrSC ) );

        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_enable_events AOutIntr: 0x%x\n", dwIntrStatus);
                
        Status = pd_aout_set_events(board, dwIntrStatus);
    }
#ifdef PD_DEBUG_T
    pd_debug_show_events( pEvents, "events from pd_enable_events");
#endif
    return Status;
}

//
// Function:    pd_disable_events
//
// Parameters:  int board
//              PTEvents pEvents     -- board events struct
//
// Returns:     1 = SUCCESS
//
// Description: Disable event interrupt mask bits of the four board event
//              interrupt/status registers.
//
//              Specifying an event interrupt mask bit will disable the
//              event interrupt. Interrupt status bits are left unchanged.
//
//              Event interrupt mask bits that are not specified are not
//              affected.
//
//              The four event registers used are:
//
//              ADUIntr   -- (ADUEIntrStat) AIn/AOut/DIn/UCT/ExTrig intr/stat
//              AIOIntr   -- (AIOIntr) AIn/AOut interrupt registers #1 & #2
//              AInIntr   -- (AInIntrStat) AIn Subsystem interrupt/status
//              AOutIntr  -- (AOutIntrStat) AOut Subsystem interrupt/status
//
// Notes:       AO, DIO and UCT events are to be implemented
//
//
//
int pd_disable_events(int board, PTEvents pEvents)
{
    u32 Status = 1;

    //-----------------------------------------------------------------------
    // ADUEIntrStat: AIn/AOut/DIn/UCT/ExTrig Interrupt/Status Register
    //
    if ( pEvents->ADUIntr )
    {
        // Clear specified mask bits.
        pd_board[board].FwEventsConfig.ADUIntr &=
            ~(pEvents->ADUIntr & (UTB_Uct0Im | UTB_Uct1Im | UTB_Uct2Im | DIB_IntrIm));

        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_disable_events ADUIntr: 0x%x\n", pd_board[board].FwEventsConfig.ADUIntr);

        Status = pd_adapter_set_board_event1(board, pd_board[board].FwEventsConfig.ADUIntr);
    }

    //-----------------------------------------------------------------------
    // AIOIntr: AIn/AOut Interrupt Registers #1 & #2
    //
    if ( pEvents->AIOIntr )
    {
        // Clear specified mask bits.
        pd_board[board].FwEventsConfig.AIOIntr &=
            ~(pEvents->AIOIntr & (  AIB_FHFIm | AIB_FFIm | AIB_CVStrtErrIm | AIB_CLStrtErrIm
                                  | AIB_OTRLowIm | AIB_OTRHighIm ));


        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_disable_events AIOIntr: 0x%x\n", pd_board[board].FwEventsConfig.AIOIntr);

        Status = pd_adapter_set_board_event2(board, pd_board[board].FwEventsConfig.AIOIntr);
    }

    //-----------------------------------------------------------------------
    // AIn Subsystem Interrupt/Status (AInIntrStat) Bits
    //
    if ( pEvents->AInIntr )
    {
        // Clear specified mask bits.
        pd_board[board].FwEventsConfig.AInIntr &=
            ~(pEvents->AInIntr 
	       & (  AIB_StartIm | AIB_StopIm | AIB_SampleIm | AIB_ScanDoneIm
              | AIB_ErrIm | AIB_BMPgDoneIm | AIB_BMErrIm ));

        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_disable_events AInIntr: 0x%x\n", pd_board[board].FwEventsConfig.AInIntr);
                
        Status = pd_ain_set_events(board, pd_board[board].FwEventsConfig.AInIntr );
    }

    //-----------------------------------------------------------------------
    // AOut Subsystem Interrupt/Status (AOutIntrStat) Bits
    //
    if ( pEvents->AOutIntr )
    {
        // Clear specified mask bits.
        pd_board[board].FwEventsConfig.AOutIntr &=
            ~(pEvents->AOutIntr & (  AOB_StartIm | AOB_StopIm
                                   | AOB_ScanDoneIm | AOB_HalfDoneIm | AOB_BufDoneIm
                                   | AOB_UndRunErrIm | AOB_CVStrtErrIm ));

        // Set new interrupt mask bits and clear specified interrupt status bits.
        //printf_T("pd_disable_events AOutIntr: 0x%x\n", pd_board[board].FwEventsConfig.AOutIntr);
                
        Status = pd_ain_set_events(board, pd_board[board].FwEventsConfig.AOutIntr);
    }
    
    return Status;
}

//
//
//
//
// AIn Subsystem Events.
//
//      eStartTrig      <-- AInIntr:AIB_StartIm/AIB_StartSC
//      eStopTrig       <-- AInIntr:AIB_StopIm/AIB_StopSC
//      eInputTrig      <-- na
//
//      eDataAvailable  <-- driver
//      eScanDone       <-- driver | AInIntr:AIB_ScanDoneSC
//      eFrameDone      <-- driver
//      eFrameRecycled  <-- driver
//      eBlockDone      <-- na
//      eBufferDone     <-- driver
//      eBufListDone    <-- na
//      eBufferWrapped  <-- driver
//
//      eConvError      <-- AIOIntr:AIB_CVStrtErrSC
//      eScanError      <-- AIOIntr:AIB_CLStrtErrSC
//      eDataError      <-- AIOIntr:AIB_OTRLowSC/AIB_OTRHighSC
//      eBufferError    <-- driver
//      eTrigError      <-- firmware
//      eStopped        <-- driver
//      eTimeout        <-- driver
//
//

//
// Function:    pd_set_user_events
//
// Parameters:  int board
//              u32 subsystem
//              u32 events
//
// Returns:     1 = SUCCESS
//
// Description: The Set User Events function sets and enables event
//              notification of specified user defined DAQ events.
//
//              Event bit:  1 -- enable event notification upon assertion
//                               of this event and clear event status bit.
//                          0 -- no change to event configuration or status.
//
//              Setting an event for notification enables the hardware or
//              driver event for notification upon assertion and clears the
//              event status bit.
//
//              Once the event asserts and the status bit is set, the
//              DLL/User notification is triggered and the event is
//              automatically disabled from notification and must be set
//              again before DLL/User can be notified of its subsequent
//              assertion.
//
//              User events operate in latched mode and must be cleared
//              either by calling PdSetUserEvents or PdClearUserEvents
//              to clear the event status bits.
//
// Notes:       AO, DIO and UCT events are to be implemented
//
int pd_set_user_events(int board, u32 subsystem, u32 events)
{
    TEvents  FwEvents = {0};
    int      Status = 1;

    //printf_P("pd_set_user_events subsystem=%d, events=0x%08X\n", subsystem, events);

    //-----------------------------------------------------------------------
    // AIn Subsystem Events.
    if ( subsystem == AnalogIn )
    {
        // Set driver event notification bits and clear event status bits.
        pd_board[board].AinSS.dwEventsNotify |= events;
        pd_board[board].AinSS.dwEventsStatus &= ~events;

        FwEvents.AIOIntr = AIB_FHFIm | AIB_FFIm;

        // Set firmware events.
        if ( events & ( eStartTrig | eStopTrig | eScanDone
                                   | eConvError | eScanError | eDataError | eBufferError | eFrameDone | eBufferDone | eBufferWrapped) )
        {
            if ( events & eStartTrig )
                FwEvents.AInIntr |= AIB_StartIm | AIB_StartSC;

            if ( events & eStopTrig )
                FwEvents.AInIntr |= AIB_StopIm | AIB_StopSC;

            if ( events & eScanDone )
                FwEvents.AInIntr |= AIB_ScanDoneSC;

            if ( events & eConvError )
                FwEvents.AIOIntr |= AIB_CVStrtErrSC;

            if ( events & eScanError )
                FwEvents.AIOIntr |= AIB_CLStrtErrSC;

            Status = pd_enable_events(board, &FwEvents);
	    //printf_T("pd_enable_events returns %d\n", Status);
        }
    } 
    
    //-----------------------------------------------------------------------
    // AOut Subsystem Events.
    else if ( subsystem == AnalogOut )
    {
        // Set driver event notification bits and clear event status bits.
        pd_board[board].AoutSS.dwEventsNotify |= events;
        pd_board[board].AoutSS.dwEventsStatus &= ~events;

        // Set firmware events.
        if ( events & (  eStartTrig | eStopTrig | eScanDone
                                    | eConvError | eScanError| eFrameDone
                                    | eBufferDone | eBufferError) )
        {   // trigger events
            if ( events & eStartTrig )
                FwEvents.AOutIntr |= AOB_StartIm | AOB_StartSC;

            if ( events & eStopTrig )
                FwEvents.AOutIntr |= AOB_StopIm | AOB_StopSC;

            // buffer events
            if ( events & eFrameDone )
                FwEvents.AOutIntr |= AOB_HalfDoneIm | AOB_HalfDoneSC;

            if ( events & eBufferDone )
                FwEvents.AOutIntr |= AOB_BufDoneIm | AOB_BufDoneSC;

            if ( events & eBufferError )
                FwEvents.AOutIntr |= AOB_UndRunErrIm | AOB_UndRunErrSC;

            // misc.
            if ( events & eScanDone )
                FwEvents.AOutIntr |= AOB_ScanDoneSC;

            if ( events & eConvError )
                FwEvents.AOutIntr |= AOB_CVStrtErrSC;

            Status = pd_enable_events(board, &FwEvents);
        }
    }

    //-----------------------------------------------------------------------
    // DIn Subsystem Events.
    else if ( subsystem == DigitalIn )
    {
        // Set driver event notification bits and clear event status bits.
        pd_board[board].DioSS.dwEventsNotify |= events;
        pd_board[board].DioSS.dwEventsStatus &= ~events;

        // trigger events
        if ( events & eDInEvent )
        {
             FwEvents.ADUIntr |= DIB_IntrIm | DIB_IntrSC;
             Status = pd_enable_events(board, &FwEvents);
        }
    }    
    
    //-----------------------------------------------------------------------
    // UCT Subsystem Events.
    else if ( subsystem == CounterTimer )
    {
        // Set driver event notification bits and clear event status bits.
        pd_board[board].UctSS.dwEventsNotify |= events;
        pd_board[board].UctSS.dwEventsStatus &= ~events;

        if ( events & (  eUct0Event | eUct1Event | eUct2Event))
        {
        // trigger events
        if ( events & eUct0Event )
             FwEvents.ADUIntr |= UTB_Uct0Im | UTB_Uct0IntrSC;

        if ( events & eUct1Event )
             FwEvents.ADUIntr |= UTB_Uct1Im | UTB_Uct1IntrSC;

        if ( events & eUct2Event )
             FwEvents.ADUIntr |= UTB_Uct2Im | UTB_Uct2IntrSC;

            Status = pd_enable_events(board, &FwEvents);
        }
    }    
    else 
    {
    	//printf_F("error in pd_set_user_events - unknown subsystem\n");
    	Status = 0;
    }
    return Status;
}

//
// Function:    pd_clear_user_events
//
// Parameters:  int board
//              u32 subsystem
//              u32 events
//
// Returns:     1 = SUCCESS
//
// Description: The Clear User Events function clears and disables event
//              notification of specified user defined DAQ events.
//
//              Event bit:  1 -- disable event notification of this event and
//                               clear the event status bit.
//                          0 -- no change to event configuration or status.
//
//              Clearing an event from notification disables the hardware
//              or driver event for notification upon assertion and clears
//              the event status bit.
//
//              All DLL calls waiting on the events that are cleared are
//              signalled.
//
//              This function can also be called to clear event status bits
//              on events that are checked by polling and were not enabled
//              for notification.
//
// Notes:       AO, DIO and UCT events are to be implemented
//
int pd_clear_user_events(int board, u32 subsystem, u32 events)
{
    TEvents  FwEvents = {0};
    int      Status = 1;

    //-----------------------------------------------------------------------
    // AIn Subsystem Events.
    if ( subsystem == AnalogIn )
    {
        // Clear driver event notification bits and clear event status bits.
        pd_board[board].AinSS.dwEventsNotify &= ~events;
        pd_board[board].AinSS.dwEventsStatus &= ~events;

        // Clear firmware events.
        if ( events & (  eStartTrig | eStopTrig | eScanDone
                       | eConvError | eScanError | eDataError) )
        {
            if ( events & eStartTrig )
                FwEvents.AInIntr |= AIB_StartIm | AIB_StartSC;

            if ( events & eStopTrig )
                FwEvents.AInIntr |= AIB_StopIm | AIB_StopSC;

            if ( events & eScanDone )
                FwEvents.AInIntr |= AIB_ScanDoneSC;

            if ( events & eConvError )
                FwEvents.AIOIntr |= AIB_CVStrtErrSC;

            if ( events & eScanError )
                FwEvents.AIOIntr |= AIB_CLStrtErrSC;

            if ( events & eDataError )
                FwEvents.AIOIntr |= AIB_OTRLowSC | AIB_OTRHighSC;

            Status = pd_disable_events(board, &FwEvents);
        }
    }
    //-----------------------------------------------------------------------
    // AOut Subsystem Events.
    else if ( subsystem == AnalogOut )
    {
        // Clear driver event notification bits and clear event status bits.
        pd_board[board].AoutSS.dwEventsNotify &= ~events;
        pd_board[board].AoutSS.dwEventsStatus &= ~events;

        // Clear firmware events.
        if ( events & (  eStartTrig | eStopTrig | eScanDone
                                    | eConvError | eScanError| eFrameDone
                                    | eBufferDone| eBufferError) )
        {
            if ( events & eStartTrig )
                FwEvents.AOutIntr |= AOB_StartIm | AOB_StartSC;

            if ( events & eStopTrig )
                FwEvents.AOutIntr |= AOB_StopIm | AOB_StopSC;

            // buffer events
            if ( events & eFrameDone )
                FwEvents.AOutIntr |= AOB_HalfDoneIm | AOB_HalfDoneSC;

            if ( events & eBufferDone )
                FwEvents.AOutIntr |= AOB_BufDoneIm | AOB_BufDoneSC;

            if ( events & eBufferError )
                FwEvents.AOutIntr |= AOB_UndRunErrIm | AOB_UndRunErrSC;

            if ( events & eScanDone )
                FwEvents.AOutIntr |= AOB_ScanDoneSC;

            if ( events & eConvError )
                FwEvents.AOutIntr |= AOB_CVStrtErrSC;

            Status = pd_disable_events(board, &FwEvents);
        }
    }
    //-----------------------------------------------------------------------
    // DIn Subsystem Events.
    else if ( subsystem == DigitalIn )
    {
        // Set driver event notification bits and clear event status bits.
        pd_board[board].DioSS.dwEventsNotify |= ~events;
        pd_board[board].DioSS.dwEventsStatus &= ~events;

        // trigger events
        if ( events & eDInEvent )
        {
             FwEvents.ADUIntr |= DIB_IntrIm | DIB_IntrSC;
             Status = pd_disable_events(board, &FwEvents);
        }
    }    

    //-----------------------------------------------------------------------
    // UCT Subsystem Events.
    else if ( subsystem == CounterTimer )
    {
        // Set driver event notification bits and clear event status bits.
        pd_board[board].UctSS.dwEventsNotify |= ~events;
        pd_board[board].UctSS.dwEventsStatus &= ~events;

        if ( events & (eUct0Event | eUct1Event | eUct2Event))
        {
          // trigger events
          if ( events & eUct0Event )
               FwEvents.ADUIntr |= UTB_Uct0Im | UTB_Uct0IntrSC;
  
          if ( events & eUct1Event )
               FwEvents.ADUIntr |= UTB_Uct1Im | UTB_Uct1IntrSC;
  
          if ( events & eUct2Event )
               FwEvents.ADUIntr |= UTB_Uct2Im | UTB_Uct2IntrSC;
  
          Status = pd_disable_events(board, &FwEvents);
        }
    }    
    
    else 
    {
    	//printf_F("error in pd_set_user_events - unknown subsystem\n");
    	Status = 0;
    }
    return Status;
}

//
// Function:    pd_get_user_events
//
// Parameters:  int board
//              u32 subsystem
//              u32 events
//
// Returns:     1 = SUCCESS
//
// Description: The Get User Events function gets the current user event
//              status. The event configuration and status are not changed.
//
//              Event bit:  0 -- event had not asserted.
//                          1 -- event asserted.
//
//              User events are not automatically re-enabled. Clearing
//              and thus re-enabling of user events is initiated by DLL.
//
// Notes:       AO, DIO and UCT events are to be implemented
//
int pd_get_user_events(int board, u32 subsystem, u32* events)
{
    ULONG EventsStatus = 0;

    //-----------------------------------------------------------------------
    // AIn Subsystem Events
    if ( subsystem == AnalogIn )
    {
        // Set driver events.
        EventsStatus = pd_board[board].AinSS.dwEventsStatus;

        // Set firmware events.
        if ( pd_board[board].FwEventsStatus.AInIntr & AIB_StartSC )
            EventsStatus |= eStartTrig;

        if ( pd_board[board].FwEventsStatus.AInIntr & AIB_StopSC )
            EventsStatus |= eStopTrig;

        if ( pd_board[board].FwEventsStatus.AInIntr & AIB_ScanDoneSC )
            EventsStatus |= eScanDone;

        if ( pd_board[board].FwEventsStatus.AIOIntr & AIB_CVStrtErrSC )
            EventsStatus |= eConvError;

        if ( pd_board[board].FwEventsStatus.AIOIntr & AIB_CLStrtErrSC )
            EventsStatus |= eScanError;
    }
    //-----------------------------------------------------------------------
    // AOut Subsystem Events
    else if ( subsystem == AnalogOut )
    {
        // Set driver events.
        EventsStatus = pd_board[board].AoutSS.dwEventsStatus;

        // Set firmware events.
        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_StartSC )
            EventsStatus |= eStartTrig;

        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_StopSC )
            EventsStatus |= eStopTrig;

       // buffer events
        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_HalfDoneSC )
            EventsStatus |= eFrameDone;

        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_BufDoneSC )
            EventsStatus |= eBufferDone;

        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_UndRunErrSC )
            EventsStatus |= eBufferError;

        // misc
        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_ScanDoneSC )
            EventsStatus |= eScanDone;

        if ( pd_board[board].FwEventsStatus.AOutIntr & AOB_CVStrtErrSC )
            EventsStatus |= eConvError;
    }
    //-----------------------------------------------------------------------
    // DIn Subsystem Events
    else if ( subsystem == DigitalIn )
    {
        // Set driver events.
        EventsStatus = pd_board[board].DioSS.dwEventsStatus;

        if ( pd_board[board].FwEventsStatus.ADUIntr & DIB_IntrSC )
            EventsStatus |= eDInEvent;

    }
    //-----------------------------------------------------------------------
    // UCT Subsystem Events.
    else if ( subsystem == CounterTimer )
    {
        // Set driver events
        EventsStatus = pd_board[board].UctSS.dwEventsStatus;

        if ( pd_board[board].FwEventsStatus.ADUIntr & UTB_Uct0IntrSC )
            EventsStatus |= eUct0Event;

        if ( pd_board[board].FwEventsStatus.ADUIntr & UTB_Uct1IntrSC )
            EventsStatus |= eUct1Event;

        if ( pd_board[board].FwEventsStatus.ADUIntr & UTB_Uct2IntrSC )
            EventsStatus |= eUct2Event;
    }

    *events = EventsStatus;
    return TRUE;
}

//
// Function:    pd_immediate_update
//
// Parameters:  int board
//
// Returns:     1 = SUCCESS
//
// Description: The Immediate Update function immediately updates the adapter
//              status, events, gets all samples acquired from adapter and
//              updates the latest sample counts.
//
// Notes:
//
void pd_process_events(int);
//
int pd_immediate_update(int board)
{
    pd_board[board].bImmUpdate = TRUE;
    pd_process_events(board);
    pd_board[board].bImmUpdate = TRUE;
    
    return 1;
}


// Function:    pd_debug_show_events
// Purpoes:     test only function
// print out event status
void pd_debug_show_events ( TEvents *Event, char* msg)
{
    char str[256];
    
    // prints out the events received
    //printf_T("pd_debug_show_events: %s\n", msg);

    // ADUIntr -----------------------------
    //printf_T("--- ADUIntr --> 0x%x\n", Event->ADUIntr);
    str[0] = '\0';
    if ( Event->ADUIntr & BRDB_ExTrigLevel)	strcat( str, "ExTrigLevel ");
    if ( Event->ADUIntr & UTB_Uct2Out)		strcat( str, "UTB_Uct2Out ");
    if ( Event->ADUIntr & UTB_Uct1Out)		strcat( str, "UTB_Uct1Out ");
    if ( Event->ADUIntr & UTB_Uct0Out)		strcat( str, "UTB_Uct0Out ");
    if ( Event->ADUIntr & AIB_CLDone)		strcat( str, "AIB_CLDone ");
    if ( Event->ADUIntr & AIB_CVDone)		strcat( str, "AIB_CVDone ");
    if ( Event->ADUIntr & AIB_FF)		strcat( str, "AIB_FF ");
    if ( Event->ADUIntr & AIB_FHF)		strcat( str, "AIB_FHF ");
    if ( Event->ADUIntr & AIB_FNE)		strcat( str, "AIB_FNE ");
    if ( Event->ADUIntr & BRDB_ExTrigFeSC)	strcat( str, "ExTrigFeSC ");
    if ( Event->ADUIntr & BRDB_ExTrigReSC)	strcat( str, "ExTrigReSC ");
    if ( Event->ADUIntr & BRDB_ExTrigIm)	strcat( str, "ExTrigIm ");
    if ( Event->ADUIntr & DIB_IntrSC)		strcat( str, "DIB_IntrSC ");
    if ( Event->ADUIntr & DIB_IntrIm)		strcat( str, "DIB_IntrIm ");
    if ( Event->ADUIntr & UTB_Uct2IntrSC)	strcat( str, "UTB_Uct2IntrSC ");
    if ( Event->ADUIntr & UTB_Uct1IntrSC)	strcat( str, "UTB_Uct1IntrSC ");
    if ( Event->ADUIntr & UTB_Uct0IntrSC)	strcat( str, "UTB_Uct0IntrSC ");
    if ( Event->ADUIntr & UTB_Uct2Im)		strcat( str, "UTB_Uct2Im ");
    if ( Event->ADUIntr & UTB_Uct1Im)		strcat( str, "UTB_Uct1Im ");
    if ( Event->ADUIntr & UTB_Uct0Im)		strcat( str, "UTB_Uct0Im ");
    //printf_T ( "%s\n", str);

    // AIOIntr -----------------------------
    //printf_T("--- AIOIntr --> 0x%x\n", Event->AIOIntr);
    str[0] = '\0';
    if (Event->AIOIntr & AIB_OTRHighSC)		strcat( str, "AIB_OTRHighSC ");
    if (Event->AIOIntr & AIB_OTRLowSC)		strcat( str, "AIB_OTRLowSC ");
    if (Event->AIOIntr & AIB_CLStrtErrSC)	strcat( str, "AIB_CLStrtErrSC ");
    if (Event->AIOIntr & AIB_CVStrtErrSC)	strcat( str, "AIB_CVStrtErrSC ");
    if (Event->AIOIntr & AIB_FFSC)			strcat( str, "AIB_FFSC ");
    if (Event->AIOIntr & AIB_OTRHighIm)		strcat( str, "AIB_OTRHighIm ");
    if (Event->AIOIntr & AIB_OTRLowIm)		strcat( str, "AIB_OTRLowIm ");
    if (Event->AIOIntr & AIB_CLStrtErrIm)	strcat( str, "AIB_CLStrtErrIm ");
    if (Event->AIOIntr & AIB_CVStrtErrIm)	strcat( str, "AIB_CVStrtErrIm ");
    if (Event->AIOIntr & AIB_FFIm)			strcat( str, "AIB_FFIm ");
//    if (Event->AIOIntr & AOB_CVDoneSC)		strcat( str, "AOB_CVDoneSC ");
//    if (Event->AIOIntr & AOB_CVDoneIm)		strcat( str, "AOB_CVDoneIm ");
    if (Event->AIOIntr & AIB_CLDoneSC)		strcat( str, "AIB_CLDoneSC ");
    if (Event->AIOIntr & AIB_FHFSC)			strcat( str, "AIB_FHFSC ");
//    if (Event->AIOIntr & AIB_FNESC)		strcat( str, "AIB_FNESC ");
    if (Event->AIOIntr & AIB_CLDoneIm)		strcat( str, "AIB_CLDoneIm ");
    if (Event->AIOIntr & AIB_FHFIm)			strcat( str, "AIB_FHFIm ");
//    if (Event->AIOIntr & AIB_FNEIm)		strcat( str, "AIB_FNEIm ");
    //printf_T ( "%s\n", str);

    // AInIntr -----------------------------
    //printf_T("--- AInIntr --> 0x%x\n", Event->AInIntr);
    str[0] = '\0';
    if (Event->AInIntr & AIB_BMActive)		strcat( str, "AIB_BMActive ");
    if (Event->AInIntr & AIB_BMEnabled)		strcat( str, "AIB_BMEnabled ");
    if (Event->AInIntr & AIB_Active)		strcat( str, "AIB_Active ");
    if (Event->AInIntr & AIB_Enabled)		strcat( str, "AIB_Enabled ");
    if (Event->AInIntr & AIB_BMPg0DoneSC)	strcat( str, "AIB_BMPg0DoneSC ");
    if (Event->AInIntr & AIB_BMPg1DoneSC)	strcat( str, "AIB_BMPg1DoneSC ");
    if (Event->AInIntr & AIB_ErrSC)			strcat( str, "AIB_ErrSC ");
    if (Event->AInIntr & AIB_ScanDoneSC)	strcat( str, "AIB_ScanDoneSC ");
    if (Event->AInIntr & AIB_SampleSC)		strcat( str, "AIB_SampleSC ");
    if (Event->AInIntr & AIB_StopSC)		strcat( str, "AIB_StopSC ");
    if (Event->AInIntr & AIB_StartSC)		strcat( str, "AIB_StartSC ");
    if (Event->AInIntr & AIB_BMEmptyIm)		strcat( str, "AIB_BMEmptyIm ");
    if (Event->AInIntr & AIB_BMErrIm)		strcat( str, "AIB_BMErrIm ");
    if (Event->AInIntr & AIB_BMPgDoneIm)	strcat( str, "AIB_BMPgDoneIm ");
    if (Event->AInIntr & AIB_ErrIm)			strcat( str, "AIB_ErrIm ");
    if (Event->AInIntr & AIB_ScanDoneIm)	strcat( str, "AIB_ScanDoneIm ");
    if (Event->AInIntr & AIB_SampleIm)		strcat( str, "AIB_SampleIm ");
    if (Event->AInIntr & AIB_StopIm)		strcat( str, "AIB_StopIm ");
    if (Event->AInIntr & AIB_StartIm)		strcat( str, "AIB_StartIm ");
    //printf_T ( "%s\n", str);

    // AOutIntr -----------------------------
    //printf_T("--- AOutIntr --> 0x%x\n", Event->AOutIntr);
    str[0] = '\0';
    if (Event->AOutIntr & AOB_QFULL)		strcat( str, "AOB_QFULL ");
    if (Event->AOutIntr & AOB_QHF)		strcat( str, "AOB_QHF ");
    if (Event->AOutIntr & AOB_QEMPTY)		strcat( str, "AOB_QEMPTY ");
    if (Event->AOutIntr & AOB_BufFull)		strcat( str, "AOB_BufFull ");
    if (Event->AOutIntr & AOB_Active)		strcat( str, "AOB_Active ");
    if (Event->AOutIntr & AOB_Enabled)		strcat( str, "AOB_Enabled ");
    if (Event->AOutIntr & AOB_CVStrtErrSC)	strcat( str, "AOB_CVStrtErrSC ");
    if (Event->AOutIntr & AOB_UndRunErrSC)	strcat( str, "AOB_UndRunErrSC ");
    if (Event->AOutIntr & AOB_BlkYDoneSC)	strcat( str, "AOB_BlkYDoneSC ");
    if (Event->AOutIntr & AOB_BlkXDoneSC)	strcat( str, "AOB_BlkXDoneSC ");
    if (Event->AOutIntr & AOB_BufDoneSC)	strcat( str, "AOB_BufDoneSC ");
    if (Event->AOutIntr & AOB_HalfDoneSC)	strcat( str, "AOB_HalfDoneSC ");
    if (Event->AOutIntr & AOB_ScanDoneSC)	strcat( str, "AOB_ScanDoneSC ");
    if (Event->AOutIntr & AOB_StopSC)		strcat( str, "AOB_StopSC ");
    if (Event->AOutIntr & AOB_StartSC)		strcat( str, "AOB_StartSC ");
    if (Event->AOutIntr & AOB_CVStrtErrIm)	strcat( str, "AOB_CVStrtErrIm ");
    if (Event->AOutIntr & AOB_UndRunErrIm)	strcat( str, "AOB_UndRunErrIm ");
    if (Event->AOutIntr & AOB_BlkYDoneIm)	strcat( str, "AOB_BlkYDoneIm ");
    if (Event->AOutIntr & AOB_BlkXDoneIm)	strcat( str, "AOB_BlkXDoneIm ");
    if (Event->AOutIntr & AOB_BufDoneIm)	strcat( str, "AOB_BufDoneIm ");
    if (Event->AOutIntr & AOB_HalfDoneIm)	strcat( str, "AOB_HalfDoneIm ");
    if (Event->AOutIntr & AOB_ScanDoneIm)	strcat( str, "AOB_ScanDoneIm ");
    if (Event->AOutIntr & AOB_StopIm)		strcat( str, "AOB_StopIm ");
    if (Event->AOutIntr & AOB_StartIm)		strcat( str, "AOB_StartIm ");
    //printf_T ( "%s\n", str);     
    
}

