
#define CAN_BASE              0
#define CAN_MSG1              0x10
#define CAN_MSG2              0x20
#define CAN_MSG3              0x30
#define CAN_MSG4              0x40
#define CAN_MSG5              0x50
#define CAN_MSG6              0x60
#define CAN_MSG7              0x70
#define CAN_MSG8              0x80
#define CAN_MSG9              0x90
#define CAN_MSG10             0xa0
#define CAN_MSG11             0xb0
#define CAN_MSG12             0xc0
#define CAN_MSG13             0xd0
#define CAN_MSG14             0xe0
#define CAN_MSG15             0xf0

#define CAN_CTRL           CAN_BASE + 0x00
#define CAN_STAT           CAN_BASE + 0x01
#define CAN_CPUIR          CAN_BASE + 0x02
#define CAN_STDGBLMASK0    CAN_BASE + 0x06
#define CAN_STDGBLMASK1    CAN_BASE + 0x07
#define CAN_EXTGBLMASK0    CAN_BASE + 0x08
#define CAN_EXTGBLMASK1    CAN_BASE + 0x09
#define CAN_EXTGBLMASK2    CAN_BASE + 0x0a
#define CAN_EXTGBLMASK3    CAN_BASE + 0x0b
#define CAN_MSG15MASK0     CAN_BASE + 0x0c
#define CAN_MSG15MASK1     CAN_BASE + 0x0d
#define CAN_MSG15MASK2     CAN_BASE + 0x0e
#define CAN_MSG15MASK3     CAN_BASE + 0x0f
#define CAN_BUSCON         CAN_MSG2 + 0x0f
#define CAN_BTR0           CAN_MSG3 + 0x0f
#define CAN_BTR1           CAN_MSG4 + 0x0f
#define CAN_IR             CAN_MSG5 + 0x0f
#define CAN_P2CONF         CAN_MSG10 + 0x0f
#define CAN_P2IN           CAN_MSG12 + 0x0f
#define CAN_P2OUT          CAN_MSG13 + 0x0f


#define CTRL_CCE  0x40
#define CTRL_EIE  0x08
#define CTRL_SIE  0x04
#define CTRL_IE   0x02
#define CTRL_INIT 0x1

#define STAT_BOFF  0x80
#define STAT_WARN  0x40
#define STAT_WAKE  0x20
#define STAT_RXOK  0x10
#define STAT_TXOK  0x08

#define CPUIR_RSTST 0X80
#define CPUIR_DSC   0X40
#define CPUIR_DMC   0X20
#define CPUIR_PWD   0X10
#define CPUIR_SLEEP 0X08
#define CPUIR_MUX   0X04
#define CPUIR_CEN   0X01

#define BUSCON_COBY 0X40
#define BUSCON_POL  0X20
#define BUSCON_DCT1 0X08
#define BUSCON_DCR1 0X02
#define BUSCON_DCR0 0X01

/* --- The message objects: */
#define CANmsg(addr, n) ((addr) + (((n)&0x03)<<4) + (((n)&0x0c)<<8))
#define CANmsg_CTRL0    0
#define CANmsg_CTRL1    1
#define CANmsg_ARB      2
#define CANmsg_CONF     6
#define CANmsg_DATA     7

/* Bits in the Message Object Controls: */
/* Control 0: */
#define MsgVal 3
#define TxIE   2
#define RxIE   1
#define IntPnd 0
#define CTRL0_MsgVal (1<<(MsgVal*2+1))
#define CTRL0_TxIE   (1<<(TxIE*2+1))
#define CTRL0_RxIE   (1<<(RxIE*2+1))
#define CTRL0_IntPnd (1<<(IntPnd*2+1))

/* Control 1: */
#define RmtPnd 3
#define TxRqst 2
#define MsgLst 1
#define CPUUpd 1
#define NewDat 0
#define CTRL1_RmtPnd    (1<<(RmtPnd*2+1))
#define CTRL1_TxRqst    (1<<(TxRqst*2+1))
#define CTRL1_MsgLst    (1<<(MsgLst*2+1))
#define CTRL1_CPUUpd    (1<<(CPUUpd*2+1))
#define CTRL1_NewDat    (1<<(NewDat*2+1))

#define SET(x) (255 ^ (1 << ((x)<<1)))
#define CLR(x) (255 ^ (2 << ((x)<<1)))
#define TEST(x) (2 << ((x)<<1))

/* Use as in
 *   CANmessage(1)[CANmsg_Control0] = SET(MsgVal) & CLR(TxIE);
 * or
 *   if (CANmessage(1)[CANmsg_Control0] & TEST(IntPnd)) ...
 */

/* Message Configuration Register: */
#define CANmsg_DLC(n) ((n)<<4)
#define CANmsg_Extended 4
#define CANmsg_Standard 0
#define CANmsg_Transmit 8
#define CANmsg_Receive  0