/* $Revision: 1.2.4.2 $ */
//===========================================================================
//
// NAME:    pdl_init.c: 
//
// DESCRIPTION:
//
//          PowerDAQ QNX driver structures initialization functions
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

static int xpcInit[PD_MAX_BOARDS];

void  pd_init_pd_board(int board)
{
    PPD_EEPROM eeprom = &pd_board[board].Eeprom;
    int	n;


    // clean up subsystems
    memset(&pd_board[board].AinSS, 0x00, sizeof(TAinSS));
    memset(&pd_board[board].AoutSS, 0x00, sizeof(TAoutSS));
    memset(&pd_board[board].DioSS, 0x00, sizeof(TDioSS));
    memset(&pd_board[board].UctSS, 0x00, sizeof(TUctSS));

    memset(&pd_board[board].FwEventsConfig, 0x00, sizeof(TEvents));
    memset(&pd_board[board].FwEventsNotify, 0x00, sizeof(TEvents));
    memset(&pd_board[board].FwEventsStatus, 0x00, sizeof(TEvents));

    // read eeprom to get board fifo size
    // printf("Read eeprom to get board fifo size\n");
 
    n = pd_adapter_eeprom_read(board, PD_EEPROM_SIZE, eeprom->u.WordValues);
    if ( n < PD_EEPROM_SIZE)
    {
    	printf( "pd_init_pd_board: eeprom read failed, n = %d, %d\n", n, PD_EEPROM_SIZE);
    } else {
    	//printf( "pd_init_pd_board: eeprom read (%d) -->\n", n);
    	//printf( "\tADC Fifo size: %d CL FIFO Size: %d entries\n", eeprom->u.Header.ADCFifoSize*1024,eeprom->u.Header.CLFifoSize*256);
    	//printf( "\tSerial Number: %s\n", eeprom->u.Header.SerialNumber);
    }
    
    // Initialize analog input subsystem
    //

    // Variables for pd_ain_flush_fifo
    pd_board[board].AinSS.BufInfo.XferBufValues = 0;    	// init later
    pd_board[board].AinSS.BufInfo.XferBuf = NULL;    		// dynamic alloc
    pd_board[board].AinSS.BufInfo.BlkXferValues = AIN_BLKSIZE;              //0x200
    pd_board[board].AinSS.FifoValues = PD_AIN_MAX_FIFO_VALUES;
    pd_board[board].AinSS.SubsysState = ssConfig;
    pd_board[board].AinSS.SubsysConfig = 0xFFFFFFFF;

    // Initialize analog output subsystem


    // Initialize digital input/output subsystem


    // Initialize user counter timer subsystem

}

void  pd_init_calibration(int board)
{
   u32 i, j, dwCalDACValue, size;
   
   // Load calibration for PD_MF series with CALDACs.
   // Does this adapter support autocalibration?
   if ( (pd_board[board].PCI_Config.SubsystemID & ADAPTER_AUTOCAL) )
   {
	  //printf("calibrate\n");

      // If installed board is PD(2) - MF(S) program caldacs
      if (PD_IS_MFX(pd_board[board].PCI_Config.SubsystemID))
      {
         // Set default configuration.
         pd_board[board].AinSS.SubsysConfig = 0;
    
         // Program AIn CALDACs.
         for ( i = 0; i < 4; i++ )
         {
             dwCalDACValue = pd_board[board].Eeprom.u.Header.CalibrArea[i];
             if (!pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                               (((i*2)<<8)|(dwCalDACValue & 0xFF))));
             //printf("PD_CALDACWRITE (1) failed");

             if (!pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                               (((i*2+1)<<8)|((dwCalDACValue & 0xFF00)>>8))));
             //printf("PD_CALDACWRITE (2) failed");
         }
    
         // Program AOut CALDACs.
         for ( i = 0; i < 4; i++ )
         {
             dwCalDACValue = pd_board[board].Eeprom.u.Header.CalibrArea[16 + i];
             if (!pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                               ((1<<11)|((i*2)<<8)|(dwCalDACValue & 0xFF))));
             //printf("PD_CALDACWRITE (3) failed");

             if (!pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                               ((1<<11)|((i*2+1)<<8)|((dwCalDACValue & 0xFF00)>>8))));
             //printf("PD_CALDACWRITE (4) failed");                               
         }
  
         // if reasonable ADC FIFO sizes has found - initializte FlashFifo()
         size = pd_board[board].Eeprom.u.Header.ADCFifoSize;
         if (( size < 1) && (size > 64)) 
            pd_board[board].Eeprom.u.Header.ADCFifoSize = 1;
            
            // we decided to use several 512 transfers instead of one big.
            // it should help with multiboard support
            //   pd_ain_set_xfer_size(board, size*512);  // half-FIFO size
      }
  
      // If installed board is PD2 - AO program caldacs
      if (PD_IS_AO(pd_board[board].PCI_Config.SubsystemID))
      {
		 //printf("is PD2-AO\n");

         for ( i = 0; i < 8; i++ )
           for ( j = 0; j < 8; j++ )
           {
               dwCalDACValue = *((BYTE*)pd_board[board].Eeprom.u.Header.CalibrArea + i*8 + j);
               if (!pd_dsp_cmd_write_ack(board, PD_CALDACWRITE,
                                 ((i<<13)|(1<<12)|(j<<8)|(dwCalDACValue & 0xFF)))
                  );
               //printf("PD_CALDACWRITE (5) failed");                                                               
           }
      }
   }
}

int intcnt;
///////////////////////////////////////////////////////////////////////////////
// Interrupt handler
//
//pid_t far pd_int_handler ()

#ifdef XPC

void pd_int_handler()
{ 
    return; 
} 

#else

pid_t pd_int_handler()
{ 
    return (0); 
}

#endif

#ifndef XPC
 
///////////////////////////////////////////////////////////////////////////////
// Enumerate devices attached to PCI bus and finds PowerDAQ devices
//
// returns 0 if success or error code:
// -EIO : cannot access PCI config space
// -ENODEV : SubsystemVendorID or SubsystemID are incorrect
// -ENOMEM : cannot map PCI address space
//
int pd_deal_with_device(unsigned busnum, unsigned devfuncnum)
{
    unsigned long address;
	char* mem_base, io_base;
    unsigned seg;
    int i, fd, n;
    
    mem_base = NULL;
    io_base = 0;
    seg = 0;

    // printf("pd_deal_with_device");

    // read PCI configuration space into pd_board structure
    if (pci_read_config32(busnum, devfuncnum, 0, 
                                  sizeof(PD_PCI_CONFIG)/sizeof(DWORD),
                                  (char*)&pd_board[num_pd_boards].PCI_Config
                                 ) 
            != PCI_SUCCESS)
        return -EIO;

    pd_board[num_pd_boards].irq = pd_board[num_pd_boards].PCI_Config.InterruptLine;
    pd_board[num_pd_boards].open = 0;
       
    // Now check is it our board?
    printf("SubsystemVendorID=0x%x SubsystemID=0x%x\n", pd_board[num_pd_boards].PCI_Config.SubsystemVendorID, pd_board[num_pd_boards].PCI_Config.SubsystemID);
    
    if (pd_board[num_pd_boards].PCI_Config.SubsystemVendorID != UEI_SUBVENID)
        return -ENODEV;

    if ((pd_board[num_pd_boards].PCI_Config.SubsystemID < PD_SUBSYSTEMID_FIRST) || 
        (pd_board[num_pd_boards].PCI_Config.SubsystemID > PD_SUBSYSTEMID_LAST) ) 
        return -ENODEV;           

    // if we're still dealing with device we need to remap address
    address = pd_board[num_pd_boards].PCI_Config.BaseAddress[0];
   // printf("Base address = 0x%x\n", address);
    
    // check base address
/*     if (PCI_IS_MEM(address))
    {
        seg = qnx_segment_overlay(PCI_MEM_ADDR(address) & ~0xfff, 4096);
        if (seg == -1)
            return -ENOMEM;    
        mem_base = (char*) MK_FP(seg, 0);
        mem_base += PCI_MEM_ADDR(address) & 0xfff;

        mem_base = (char*)PCI_MEM_ADDR(address);
    } else {
         io_base = PCI_IO_ADDR(address);
         return -ENOMEM;
    }

    printf("seg=0x%x mem_base=0x%x io_base=0x%x\n", seg, mem_base, io_base);    



    // now let's map the PCI memory
    pd_board[num_pd_boards].size = 0x8000;
    // open physical memory 
    fd = shm_open ( "physical", O_RDWR | O_CREAT, 0777 );
    if ( fd == -1) 
    { 
        fprintf ( stderr, "open failed:%s\n",strerror (errno)); 
        exit (1); 
    } 

    // Map PCI Base memory address
    
    pd_board[num_pd_boards].size = 0x8000;

    pd_board[num_pd_boards].address =
	    mmap( 0, pd_board[num_pd_boards].size,
            PROT_READ | PROT_WRITE,
            MAP_SHARED, fd, pd_board[num_pd_boards].PCI_Config.BaseAddress[0]); 
*/            

     pd_board[num_pd_boards].size = 0x8000;
 	 pd_board[num_pd_boards].address =
	   mmap_device_memory(0, pd_board[num_pd_boards].size,
              PROT_READ | PROT_WRITE | PROT_NOCACHE, 
              MAP_SHARED, 
              pd_board[num_pd_boards].PCI_Config.BaseAddress[0]); 
              
   // printf("Mapped address: 0x%08x\n", pd_board[num_pd_boards].address);
    if ( pd_board[num_pd_boards].address == (void*) -1) 
    { 
    printf("mmap failed : %s\n", strerror(errno)); 
        pd_board[num_pd_boards].address = NULL; 
        return -ENOMEM;
    }     



    // check FW state and download it if necessarily
   // printf("Downloading FW\n");
    if (!pd_dsp_startup(num_pd_boards))
        return -EIO;    
        
    // allocate irq
    //
    //
   
    // initialize calibration values
    intcnt = 0;
    pd_init_pd_board(num_pd_boards);
    pd_init_calibration(num_pd_boards);

    // allocate DMA ready XferBuf
    n = pd_board[num_pd_boards].Eeprom.u.Header.ADCFifoSize * 0x400;
    pd_board[num_pd_boards].AinSS.BufInfo.XferBufValues = n;
 
    pd_board[num_pd_boards].AinSS.BufInfo.XferBuf = (u16*)malloc(n);
        

    return 0;
}

///////////////////////////////////////////////////////////////////////////////
// Enumerate devices attached to PCI bus and finds PowerDAQ devices
//
int pd_find_devices()
{
	unsigned flags;
    unsigned lastbus, version, hardware;
	unsigned busnum, devfuncnum;
    int pci_index = 0;
    int ret;

    // printf("Try to locate PowerDAQ board(s) on PCI bus...\n");
    num_pd_boards = 0;

    // Attach PCI Server
	pci_attach(flags);
	
    // do we have a PCI BIOS
    //printf("Determine PCI BIOS 1\n");
    if (!(PCI_SUCCESS == pci_present(NULL, NULL, NULL)))
		return -EIO;

    //printf("PCI BIOS OK\n");
	

    // find device on PCI bus with appropriate PCI_DEVICEID and PCI_VENDORID
    while (pci_find_device(PCI_DEVICEID, PCI_VENDORID,
                               pci_index, &busnum, &devfuncnum) 
           == PCI_SUCCESS)
    {
   // printf("Device found %d, dealing with it... busnum=%d devfuncnum=%d\n", num_pd_boards, busnum, devfuncnum);
        ret = pd_deal_with_device(busnum, devfuncnum);
   // printf("pd_deal_with_device returns %d\n", ret);
        if (!ret)
            num_pd_boards++;

        pci_index++;
    }
    if (!pci_index)
        return -ENXIO;

    return num_pd_boards;
}


///////////////////////////////////////////////////////////////////////////////
// De-initialize device and driver
//
int pd_clean_devices()
{
   u32 i, ret;
   
   for (i = 0; i < num_pd_boards; i++)
   {
     // deallocate memory
     if (pd_board[num_pd_boards].AinSS.BufInfo.XferBuf)
     {
        free((void*)pd_board[num_pd_boards].AinSS.BufInfo.XferBuf);
     }

     // unmap physical address
     if (!pd_board[i].address)
     {
        ret = munmap(pd_board[i].address, pd_board[i].size);
     }
   }
   return TRUE;
}

#else

int pd_xpc_assign_device( int subDeviceId,
                          unsigned long address,
                          unsigned short interruptLine)
{
    // Return values:
    //    positive integer => slot in pd_board
    //    -2  Wrong subdevice ID for same address
    //    -3  No empty slots
    //    -4  Error downloading firmware to board

    //unsigned flags;
    //unsigned lastbus, version, hardware;
    //unsigned busnum, devfuncnum;
    //int pci_index = 0;
    int ret;
    char* mem_base, io_base;
    unsigned seg;
    int i, fd, n;
    int board;

    rl32eWaitDouble = (void*) GetProcAddress(GetModuleHandle(NULL),
                                             "rl32eWaitDouble");
    if (rl32eWaitDouble==NULL) {
        printf("rl32eWaitDouble not found\n");
    }

	
    // Assign boards to slots in pd_board, no gaps, no closing of the device.
    for( board = 0 ; board < PD_MAX_BOARDS ; board++ )
    {
        if (xpcInit[board])
        {
            if( pd_board[board].address == (void *)address )
            {
                if( pd_board[board].PCI_Config.SubsystemID == subDeviceId )
                    return board;
                else
                    return -2;  // Subdevice doesn't match
            }
            continue;  // Try next slot
        }
        xpcInit[board]=1;
        break;
    }
    if( board >= PD_MAX_BOARDS )
        return -3;  // No available board slots
    
    num_pd_boards = 0;
      	    
    mem_base = NULL;
    io_base = 0;
    seg = 0;

    pd_board[board].PCI_Config.InterruptLine= interruptLine;
    pd_board[board].PCI_Config.SubsystemID= subDeviceId;
    pd_board[board].PCI_Config.BaseAddress[0]= address;

    pd_board[board].irq = interruptLine;
    pd_board[board].open = 0;
    pd_board[board].size = 0x8000;
    pd_board[board].address= (void *)address;

    // check FW state and download it if necessarily
    //printf("Downloading FW...\n");
    if (!pd_dsp_startup(board))
        return -4;     // Error during board download
        
    // allocate irq
    //
    //

	//printf("Downloading FW finished\n");
   
    // initialize calibration values
    intcnt = 0;
    pd_init_pd_board(board);
    pd_init_calibration(board);

    // allocate DMA ready XferBuf
    n = pd_board[board].Eeprom.u.Header.ADCFifoSize * 0x400;
    pd_board[board].AinSS.BufInfo.XferBufValues = n;
 
    pd_board[board].AinSS.BufInfo.XferBuf = (u16*)malloc(n);
        
    num_pd_boards=1;

	//printf("init finished\n");

    return board;

}

void delay(unsigned int a)
{	
    rl32eWaitDouble((double)a/1000.0);
}


#endif


	
	
