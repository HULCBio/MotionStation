/* $Revision: 1.1 $ */
/****************************************************************************/
/*                                                                          */
/*   Softing GmbH          Richard-Reitzner-Allee 6       85540 Haar        */
/*                                                                          */
/****************************************************************************/
/*                                                                          */
/*   Copyright (C) by Softing GmbH, 1997, All rights reserved.              */
/*                                                                          */
/****************************************************************************/
/*                                                                          */
/*                               C A N L A Y 2 . H                          */
/*                                                                          */
/****************************************************************************/
/*                                                                          */
/* MODULE_DESCRIPTION  CANLAY2.H                                            */
/* VERSION             4.0                                                  */
/* DATE                08.12.97                                             */
/*                     include file for CAN Layer 2 Library                 */
/*                     function prototypes and return codes                 */
/*                                                                          */
/****************************************************************************/
#ifndef _CANLAY2_H
#define _CANLAY2_H


#define  CANPC_SOCKET_AUTO   0xFFFF    /* Socket automatically searched     */
#define  CANPC_NO_IRQ        0x0       /* no interrupt requested            */
#define  CANPC_IRQ_AUTO      0xFFFF    /* interrupt automatically assigned  */
#define  CANPC_BASE_AUTO     0x0L      /* DPR-Base automatically assigned   */
#define  CANPC_SIZE_AUTO     0x0L      /* DPR-Size automatically assigned   */
#define  CANPC_AI_AUTO       0x0       /* chip does no matter               */
#define  CANPC_AI_DB8        0x01      /* chip is Databook                  */

typedef enum ChipTypeEnum
{   _82365SL_,
    _DB86082_
}  ChipType;

#pragma pack(1)                        /* pack alignment must be one        */
typedef struct canpc_ressources_s {
    unsigned short uSocket;
    unsigned short uInterrupt;
    unsigned long  ulDPRMemBase;
    unsigned long  ulDPRMemSize;
    ChipType       uChip;
    unsigned short uIOAdress;
    unsigned short uRegisterBase;
} CANPC_RESSOURCES;


typedef struct  {
                  unsigned long Ident;
                  int  DataLength;
                  int  RecOverrun_flag;
                  int  RCV_fifo_lost_msg;
         unsigned char  RCV_data[8];
                  int  AckOverrun_flag;
                  int  XMT_ack_fifo_lost_acks;
                  int  XMT_rmt_fifo_lost_remotes;
                  int  Bus_state;
                  int  Error_state;
                  int  Can;
         unsigned long  Time;
                } param_struct;

#pragma pack()

/* ---- FUNCTION PROTOTYPES AND FUNCTION RETURN VALUES  --------------------*/
/* default return values -- valid for all functions (if no other value is 
   described)                                                               */
/* default return values -- valid for all functions                         */
#define  CANPC_OK                          0  /* function successful        */
#define  CANPC_ERR                        -1  /* function not successful    */
#define  CANPC_ERR_DPR                    -3  /* error accessing dpram (only  
                                                 CAN-AC2)                   */
#define  CANPC_ACCESS_TIMEOUT             -4  /* firmware communication 
                                                 timeout                    */
#define  CANPC_BOARD_NOT_INITIALIZED     -99  /* board not initialized:
                                                 INIPC_initialize_board_mb1(.) 
                                                 was not yet called, or a 
                                                 INIPC_close_board_mb1 was done */

/* ---- INIPC_initialize_board_mb1   -------------------------------------------*/

/* -- CANcard return values                                                 */
/* --  return codes for card services access with WINDOWS 3.11              */
#define  INIPC_IB_ERR_WINSYSRES       0xFFFF  /* not enough windows system 
                                                 resources                  */

/* --  return codes for card services access with DOS or WINDOWS 3.11       */

/* return values between 0x0201 and 0x3622: card services call failed       */

#define  INIPC_IB_ERR_NO_CARD_FOUND   0xFFEF  /* no pcmcia card found       */
#define  INIPC_IB_ERR_NO_CS_INSTALLED 0xFFEE  /* no card services installed */
#define  INIPC_IB_ERR_WRONG_VERSION   0xFFED  /* card services version not
                                                 supported                  */
#define  INIPC_IB_ERR_IRQ             0xFFEC  /* interrupt number invalid 
                                                 or in use                  */
#define  INIPC_IB_ERR_DPRAM           0xFFEB  /* failed allocating dpr-window: 
                                                 out of resources or in use */                           
#define  INIPC_IB_ERR_ACCESS_DPRAM    0xFFEA  /* DOS: invalid dpram address 
                                                      (above 1MB) 
                                                 WIN: failed allocating
                                                      selector              */

/* -- CANcard and CAN-AC2 return values                                     */
/* --  return codes for access with WIN32 (WINDOWS-NT 4.0 and WINDOWS 95)   */
/* return values between 0xFE0201 and 0x3622: card services call failed     */
#define  INIPC_IB_PNP_NO_DEVICE_FOUND  0xFE00 /* no can device found        */
#define  INIPC_IB_ERR_VC_INTERNALERROR 0xFE01 /* internal error             */
#define  INIPC_IB_ERR_VC_GENERALERROR  0xFE02 /* general error              */
#define  INIPC_IB_ERR_VC_TIMEOUT       0xFE03 /* Timeout                    */
#define  INIPC_IB_ERR_VC_IOPENDING     0xFE04 /* driver call pending        */
#define  INIPC_IB_ERR_VC_IOCANCELLED   0xFE05 /* driver call cancelled      */
#define  INIPC_IB_ERR_VC_ILLEGALCALL   0xFE06 /* illegal driver call        */
#define  INIPC_IB_ERR_VC_NOTSUPPORTED  0xFE07 /* driver call not supported  */
#define  INIPC_IB_ERR_VC_VERSIONERROR  0xFE08 /* wrong driver-dll version   */
#define  INIPC_IB_ERR_VC_DRIVERVERSIONERROR   0xFE09 /*wrong driver version */
#define  INIPC_IB_ERR_VC_DRIVERNOTFOUND   0xFE0A /* driver not found        */
#define  INIPC_IB_ERR_VC_NOTENOUGHMEMORY  0xFE0B /* not enough memory       */
#define  INIPC_IB_ERR_VC_TOOMANYDEVICES   0xFE0C /* too many devices        */
#define  INIPC_IB_ERR_VC_UNKNOWNDEVICE    0xFE0D /* unknown device          */
#define  INIPC_IB_ERR_VC_DEVICEALREADYEXISTS 0xFE0E /* Device ardy exists   */
#define  INIPC_IB_ERR_VC_DEVICEACCESSERROR   0xFE0F /* device ardy open     */
#define  INIPC_IB_ERR_VC_RESOURCEALREADYREGISTERED 0xFE10 /* Resource in use*/
#define  INIPC_IB_ERR_VC_RESOURCECONFLICT 0xFE11 /* Resource-conflict       */
#define  INIPC_IB_ERR_VC_RESOURCEACCESSERROR 0xFE12 /* Resource access error*/
#define  INIPC_IB_ERR_VC_PHYSMEMORYOVERRUN 0xFE13 /* invalid phys.mem-access*/
#define  INIPC_IB_ERR_VC_TOOMANYPORTS    0xFE14     /* too many I/O ports   */
#define  INIPC_IB_ERR_VC_UNKNOWNRESOURCE  0xFE15 /* unknown resource        */



/* +--- CANPC_reset_board_mb1        -------------------------------------------*/
/* -- CANcard return values                                                 */
/* -- return values for access with DOS only                                */
#define  CANPC_RB_INI_FILE           -1  /* can't open IniFile              */              
#define  CANPC_RB_ERR_FMT_INI        -2  /* format error in INI-file        */    
#define  CANPC_RB_ERR_OP_BIN         -3  /* error opening binary-file       */    
#define  CANPC_RB_ERR_RD_BIN         -4  /* error reading binary-file       */    
#define  CANPC_RB_BIN_TOO_LONG       -5  /* binary-file too long            */    

/* -- return values for access with DOS and WINDOWS (WIN16, WIN32)          */
#define  CANPC_RB_ERR_BIN_FMT        -6  /* binary-data format error        */    
#define  CANPC_RB_ERR_BIN_CS         -7  /* binary-data checksum error      */    
#define  CANPC_RB_NO_CARD           -16  /* no card present                 */    
#define  CANPC_RB_NO_PHYS_MEM       -17  /* no physical memory              */    
#define  CANPC_RB_INVLD_IRQ         -18  /* invalid IRQ-number              */    
#define  CANPC_RB_ERR_DPRAM_ACCESS  -19  /* error accessing dpram           */    
#define  CANPC_RB_ERR_CRD_RESP      -20  /* bad response from card          */    
#define  CANPC_RB_ERR_SRAM          -21  /* sram seems to be damaged        */    
#define  CANPC_RB_ERR_PRG           -22  /* invalid program start address   */    
#define  CANPC_RB_ERR_REC           -23  /* invalid record type             */    
#define  CANPC_RB_ERR_NORESP        -24  /* no response after program start */    
#define  CANPC_RB_ERR_BADRESP       -25  /* bad response after program start*/    
#define  CANPC_RB_PCMCIA_NSUPP      -26  /* pcmcia chip not supported       */    
#define  CANPC_RB_ERR_RD_PCMCIA     -27  /* error reading ocmcia parameters */    
#define  CANPC_RB_INIT_CHIP         -38  /* error initializing chip         */    


/* -- CAN-AC2 return values                                                 */
/* -- boot-download error                                                   */

/* ErrorCode = ErrorBase + ErrorDetail                                      */
/* ErrorBase codes                                                          */
#define CANPC_RB_BOOT_BASE         -100  /* boot-data errors                */
#define CANPC_RB_LOAD_BASE         -200  /* load-data errors                */
#define CANPC_RB_APP_BASE          -300  /* application-data errors         */
#define CANPC_RB_CPY_BASE          -400  /* copy-data errors                */
#define CANPC_RB_RUN_BASE          -500  /* run-data errors                 */
/* ErrorDetail codes                                                        */
#define  CANPC_RB_NO_RESPONSE        -1  /* no response from CAN-AC2        */
#define  CANPC_RB_ERR_FMT            -8  /* boot-data format error          */
#define  CANPC_RB_ERR_INT1           -2  /* internal error 1                */
#define  CANPC_RB_ERR_INT2           -3  /* internal error 2                */
#define  CANPC_RB_ERR_INT3           -4  /* internal error 3                */
#define  CANPC_RB_ERR_INT4           -9  /* internal error 4                */
#define  CANPC_RB_ERR_INT5          -10  /* internal error 5                */
#define  CANPC_RB_ERR_OPEN           -5  /* file open error (DOS only)      */
#define  CANPC_RB_ERR_READ           -6  /* file read error (DOS only)      */
#define  CANPC_RB_ERR_CLOSE          -7  /* file close error (DOS only)     */

PRAEDECL int MIDDECL INIPC_initialize_board_mb1(CANPC_RESSOURCES * ulDPRMemBase, int pci_slot);



PRAEDECL int MIDDECL CANPC_reset_board_mb1(void);

/* +--- CANPC_reset_chip_mb1         -------------------------------------------*/
PRAEDECL int MIDDECL CANPC_reset_chip_mb1(void);

/* +--- CANPC_initialize_chip_mb1(2) -------------------------------------------*/
#define  CANPC_IC_PARAM_ERR               -1  /* Parameter error            */
PRAEDECL int MIDDECL CANPC_initialize_chip_mb1 (int presc,
                               int sjw,
                               int tseg1,
                               int tseg2,
                               int sam);

PRAEDECL int MIDDECL CANPC_initialize_chip2_mb1(int presc,
                               int sjw,
                               int tseg1,
                               int tseg2,
                               int sam);

/* +--- CANPC_set_mode_mb1(2)        -------------------------------------------*/
PRAEDECL int MIDDECL CANPC_set_mode_mb1 (int SleepMode,
                        int SpeedMode);

PRAEDECL int MIDDECL CANPC_set_mode2_mb1(int SleepMode,
                        int SpeedMode);

/* +--- CANPC_set_acceptance_mb1(2)  -------------------------------------------*/
PRAEDECL int MIDDECL CANPC_set_acceptance_mb1 (unsigned int AccCodeStd,
                              unsigned int AccMaskStd,
                              unsigned long AccCodeXtd,
                              unsigned long AccMaskXtd);

PRAEDECL int MIDDECL CANPC_set_acceptance2_mb1(unsigned int AccCodeStd,
                              unsigned int AccMaskStd,
                              unsigned long AccCodeXtd,
                              unsigned long AccMaskXtd);

/* +--- CANPC_set_output_control_mb1(2)  ---------------------------------------*/
PRAEDECL int MIDDECL CANPC_set_output_control_mb1 (int OutputControl);

PRAEDECL int MIDDECL CANPC_set_output_control2_mb1(int OutputControl);

/* +--- CANPC_initialize_interface_mb1   ---------------------------------------*/
#define  CANPC_II_REA_CONFLICT            -6  /* Parameter conflict: 
                                                 ReceiveEnableAll with dyn.
                                                 obj. buffer or fifo mode   */
#define  CANPC_II_DPR_STATIC              -5  /* DPRAM size conflict:
                                                 DPRAM is not 64k, but
                                                 static object buffer is 
                                                 requested(only CAN-AC2)    */

PRAEDECL int MIDDECL CANPC_initialize_interface_mb1(int ReceiveFifoEnable,
                                   int ReceivePollAll,
                                   int ReceiveEnableAll,
                                   int ReceiveIntEnableAll,
                                   int AutoRemoteEnable,
                                   int TransmitReqFifoEnable,
                                   int TransmitPollAll,
                                   int TransmitAckEnableAll,
                                   int TransmitAckFifoEnable,
                                   int TransmitRmtFifoEnable);

/* +--- CANPC_define_object_mb1(2)          ------------------------------------*/
#define  CANPC_DO_PARAM_ERR               -1  /* Parameter error            */
#define  CANPC_DO_NO_DYNOBJ               -2  /* dyn. obj. buf. not enabled 
                                                (only CANPC_define_object2_mb1) */
#define  CANPC_DO_DPR_STATIC              -5  /* DPRAM size conflict:
                                                 DPRAM is not 64k, but
                                                 static object buffer is 
                                                 requested(only CAN-AC2)    */
#define  CANPC_DO_TOO_MANY_OBJECTS        -6  /* too many objects defined   */

PRAEDECL int MIDDECL CANPC_define_object_mb1 (unsigned long Handle,
                             int  * ObjectNumber,
                             int Type,
                             int ReceiveIntEnable,
                             int AutoRemoteEnable,
                             int TransmitAckEnable);

PRAEDECL int MIDDECL CANPC_define_object2_mb1(unsigned long Handle,
                             int  * ObjectNumber,
                             int Type,
                             int ReceiveIntEnable,
                             int AutoRemoteEnable,
                             int TransmitAckEnable);

/* +--- CANPC_define_cyclic_mb1(2)        --------------------------------------*/
#define  CANPC_DC_INVLD_OBJ_NR            -1  /* invalid object number      */
#define  CANPC_DC_NO_DYN_OBJBUF           -2  /* no object dyn. buffer 
                                                 enabled (only CAN-AC2)     */

PRAEDECL int MIDDECL CANPC_define_cyclic_mb1 (int ObjectNumber,
                             unsigned int Rate,
                             unsigned int Cycles);

PRAEDECL int MIDDECL CANPC_define_cyclic2_mb1(int ObjectNumber,
                             unsigned int Rate,
                             unsigned int Cycles);

/* +--- CANPC_enable_fifo_mb1            ---------------------------------------*/

PRAEDECL int MIDDECL CANPC_enable_fifo_mb1(void);

/* +--- CANPC_optimize_rcv_speed_mb1     ---------------------------------------*/
/* this function has no effect on the CANcard                               */
#define  CANPC_ORS_PARAM_ERR              -1  /* Parameter error            */

PRAEDECL int MIDDECL CANPC_optimize_rcv_speed_mb1(void);

/* +--- CANPC_enable_dyn_obj_buf_mb1     ---------------------------------------*/

PRAEDECL int MIDDECL CANPC_enable_dyn_obj_buf_mb1(void);

/* +--- CANPC_enable_timestamps_mb1      ---------------------------------------*/
/* this function has no effect on the CANcard                               */
#define  CANPC_ET_NO_FIFO                 -6  /* fifo not enabled 
                                                 (only CAN-AC2)             */

PRAEDECL int MIDDECL CANPC_enable_timestamps_mb1(void);
/* +--- CANPC_enable_fifo_transmit_ack_mb1  ------------------------------------*/

PRAEDECL int MIDDECL CANPC_enable_fifo_transmit_ack_mb1 (void);

PRAEDECL int MIDDECL CANPC_enable_fifo_transmit_ack2_mb1(void);

/* +--- CANPC_get_version_mb1            ---------------------------------------*/
/* the parameter hw_version is not used with the CAN-AC2                    */

PRAEDECL int MIDDECL CANPC_get_version_mb1(int  * sw_version, 
                                       int  * fw_version,
                                       int  * hw_version,
                                       int  * license,
                                       int  * can_chip_type);

/* +--- CANPC_get_serial_number_mb1      ---------------------------------------*/
/* this function has no effect on the CAN-AC2                               */

PRAEDECL int MIDDECL CANPC_get_serial_number_mb1(unsigned long  * ser_number);

/* +--- CANPC_start_chip_mb1             ---------------------------------------*/

PRAEDECL int MIDDECL CANPC_start_chip_mb1(void);

/* +--- CANPC_send_remote_object_mb1(2)  ---------------------------------------*/
#define  CANPC_SRO_PEND                   -1  /* last request still pending */    
#define  CANPC_SRO_TX_FIFO_FULL           -3  /* transmit fifo full         */    

PRAEDECL int MIDDECL CANPC_send_remote_object_mb1 (int ObjectNumber,
                                  int DataLength);

PRAEDECL int MIDDECL CANPC_send_remote_object2_mb1(int ObjectNumber,
                                  int DataLength);

/* +--- CANPC_supply_object_data_mb1(2)  ---------------------------------------*/
#define  CANPC_SOD_REQ_OVR                -1  /* request overrun            */    

PRAEDECL int MIDDECL CANPC_supply_object_data_mb1 (int  ObjectNumber,
                                  int  DataLength,
                                  unsigned char  * pData);

PRAEDECL int MIDDECL CANPC_supply_object_data2_mb1(int  ObjectNumber,
                                  int  DataLength,
                                  unsigned char  * pData);

/* +--- CANPC_supply_rcv_object_data_mb1(2)-------------------------------------*/

PRAEDECL int MIDDECL CANPC_supply_rcv_object_data_mb1 (int  ObjectNumber,
                                      int  DataLength,
                                      unsigned char  * pData);

PRAEDECL int MIDDECL CANPC_supply_rcv_object_data2_mb1(int  ObjectNumber,
                                      int  DataLength,
                                      unsigned char  * pData);

/* +--- CANPC_send_object_mb1(2)         ---------------------------------------*/
#define  CANPC_SO_REQ_OVR                 -1  /* request overrun            */    
#define  CANPC_SO_FIFO_FULL               -3  /* job fifo full              */    

PRAEDECL int MIDDECL CANPC_send_object_mb1 (int  ObjectNumber,
                           int  DataLength);

PRAEDECL int MIDDECL CANPC_send_object2_mb1(int  ObjectNumber,
                           int  DataLength);

/* +--- CANPC_write_object_mb1(2)        ---------------------------------------*/
#define  CANPC_WO_REQ_OVR                 -1  /* request overrun            */    
#define  CANPC_WO_FIFO_FULL               -3  /* transmit fifo full         */    

PRAEDECL int MIDDECL CANPC_write_object_mb1 (int  ObjectNumber,
                            int  DataLength,
                            unsigned char  * pData);

PRAEDECL int MIDDECL CANPC_write_object2_mb1(int  ObjectNumber,
                            int  DataLength,
                            unsigned char  * pData);

/* +--- CANPC_read_rcv_data_mb1(2)       ---------------------------------------*/
#define  CANPC_RRD_NO_DATA                 0  /* no new data received       */    
#define  CANPC_RRD_DATAFRAME               1  /* data frame received        */    
#define  CANPC_RRD_REMOTEFRAME             2  /* remote frame received      */    
#define  CANPC_RRD_RCV_OVR                -1  /* receive data overrun       */    
#define  CANPC_RRD_RF_OVR                 -2  /* rec. rem. frame overrun    */    
#define  CANPC_RRD_OBJ_INACTIVE           -3  /* object not active          */    
#define  CANPC_RDD_ACCESS_TIMEOUT         -7  /* firmware communication 
                                                 timeout (only CAN-AC2)     */

PRAEDECL int MIDDECL CANPC_read_rcv_data_mb1 (int  ObjectNumber,
                             unsigned char  * pRCV_Data,
                             unsigned long  * Time);

PRAEDECL int MIDDECL CANPC_read_rcv_data2_mb1(int  ObjectNumber,
                             unsigned char  * pRCV_Data,
                             unsigned long  * Time);

/* +--- CANPC_read_xmt_data_mb1(2)       ---------------------------------------*/
#define  CANPC_RXD_NO_DATA                 0  /* no message was transmitted */    
#define  CANPC_RXD_DATAFRAME               1  /* message was transmitted    */    
#define  CANPC_RXD_XMT_OVR                -1  /* transmit ack. overrun      */    
#define  CANPC_RXD_NO_DYN_OBJBUF          -3  /* no dyn. obj-buffer enabled
                                                 (only CAN-AC2/527)         */    

PRAEDECL int MIDDECL CANPC_read_xmt_data_mb1 (int  ObjectNumber,
                             int  * pDataLength,
                             unsigned char  * pXMT_Data);

PRAEDECL int MIDDECL CANPC_read_xmt_data2_mb1(int  ObjectNumber,
                             int  * pDataLength,
                             unsigned char  * pXMT_Data);

/* +--- CANPC_read_ac_mb1                ---------------------------------------*/
#define  CANPC_RA_NO_DATA                 0  /* no new data received        */    
#define  CANPC_RA_DATAFRAME               1  /* std. data frame received    */    
#define  CANPC_RA_REMOTEFRAME             2  /* std. remote frame received  */    
#define  CANPC_RA_TX_DATAFRAME            3  /* transmission of std. data-
                                                frame is confirmed          */    
#define  CANPC_RA_TX_FIFO_OVR             4  /* remote tx fifo overrun      */    
#define  CANPC_RA_CHG_BUS_STATE           5  /* change of bus status        */    
#define  CANPC_RA_ERR_ADD                 7  /* additional error causes     */    
#define  CANPC_RA_TX_REMOTEFRAME          8  /* transmission of std. data-
                                                frame is confirmed          */    
#define  CANPC_RA_XTD_DATAFRAME           9  /* xtd. data frame received    */    
#define  CANPC_RA_XTD_TX_DATAFRAME       10  /* transmission of xtd. data-
                                                frame is confirmed          */    
#define  CANPC_RA_XTD_TX_REMOTEFRAME     11  /* transmission of xtd. remote-
                                                frame is confirmed          */    
#define  CANPC_RA_XTD_REMOTEFRAME        12  /* xtd. remote frame received 
                                                (only CANcard)              */    
#define  CANPC_RA_ERRORFRAME             15  /* error frame detected  
                                                (only CANcard)              */    

PRAEDECL int MIDDECL CANPC_read_ac_mb1(param_struct  * param);

/* +--- CANPC_send_data_mb1              ---------------------------------------*/
#define  CANPC_SD_FIFO_FULL               -1  /* transmit fifo full         */    

PRAEDECL int MIDDECL CANPC_send_data_mb1 (unsigned long Ident,
                         int Xtd,
                         int DataLength,
                         unsigned char  * pData);

PRAEDECL int MIDDECL CANPC_send_data2_mb1(unsigned long Ident,
                         int Xtd,
                         int DataLength,
                         unsigned char  * pData);

/* +--- CANPC_send_remote_mb1            ---------------------------------------*/
#define  CANPC_SR_FIFO_FULL               -1  /* transmit fifo full         */    
PRAEDECL int MIDDECL CANPC_send_remote_mb1 (unsigned long Ident,
                           int Xtd,
                           int DataLength);

PRAEDECL int MIDDECL CANPC_send_remote2_mb1(unsigned long Ident,
                           int Xtd,
                           int DataLength);

/* +--- CANPC_get_trigger_mb1(2)            ---------------------------------------*/
/* these functions have no effect on the CANcard                               */
PRAEDECL int MIDDECL CANPC_get_trigger_mb1 (int  * level);

PRAEDECL int MIDDECL CANPC_get_trigger2_mb1(int  * level);

/* +--- CANPC_set_trigger_mb1            ---------------------------------------*/
#define  CANPC_ST_FIFO_FULL               -1  /* transmit fifo full         */    

PRAEDECL int MIDDECL CANPC_set_trigger_mb1 (int level);

PRAEDECL int MIDDECL CANPC_set_trigger2_mb1(int level);

/* +--- CANPC_reinitialize_mb1           ---------------------------------------*/
PRAEDECL int MIDDECL CANPC_reinitialize_mb1(void);

/* +--- CANPC_get_time_mb1               ---------------------------------------*/
PRAEDECL int MIDDECL CANPC_get_time_mb1(unsigned long  * time);

/* +--- CANPC_get_bus_state_mb1          ---------------------------------------*/
#define  CANPC_GBS_ERROR_ACTIVE            0  /* error active               */    
#define  CANPC_GBS_ERROR_PASSIVE           1  /* error passive              */    
#define  CANPC_GBS_ERROR_BUS_OFF           2  /* bus off                    */    

PRAEDECL int MIDDECL CANPC_get_bus_state_mb1(int Can);


/* +--- CANPC_reset_rcv_fifo_mb1         ---------------------------------------*/
PRAEDECL int MIDDECL CANPC_reset_rcv_fifo_mb1(void);

/* +--- CANPC_reset_xmt_fifo_mb1         ---------------------------------------*/
PRAEDECL int MIDDECL CANPC_reset_xmt_fifo_mb1(void);

/* +--- CANPC_reset_lost_msg_counter_mb1  --------------------------------------*/
PRAEDECL int MIDDECL CANPC_reset_lost_msg_counter_mb1(void);

/* +--- CANPC_read_rcv_fifo_level_mb1    ---------------------------------------*/
/* returns number of items in receive fifo   */
PRAEDECL int MIDDECL CANPC_read_rcv_fifo_level_mb1(void);

/* +--- CANPC_read_xmt_fifo_level_mb1    ---------------------------------------*/
/* returns number of items in transmit fifo  */
PRAEDECL int MIDDECL CANPC_read_xmt_fifo_level_mb1(void);

/* +--- CANPC_set_path_mb1               ---------------------------------------*/
#define  CANPC_SP_STRING_TOO_LONG        -1  /* path string too long        */    
PRAEDECL int MIDDECL CANPC_set_path_mb1(char  * path);

/* +--- INIPC_close_board_mb1            ---------------------------------------*/
PRAEDECL int MIDDECL INIPC_close_board_mb1(void);
#define  INIPC_CB_ERR                     -1  /* error unlocking rerssources*/    

/* +--- CANPC_enable_error_frame_detection_mb1  --------------------------------*/
/* this function has no effect on the CAN-AC2                               */
PRAEDECL int MIDDECL CANPC_enable_error_frame_detection_mb1(void);


#endif  /*_CANLAY2_H */


