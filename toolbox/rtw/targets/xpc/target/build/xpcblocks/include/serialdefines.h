
/* $Revision: 1.1 $ $Date: 2003/01/07 22:06:16 $ */
/* quatechdefines.h - xPC Target, board specific defines used by
 *                    multiple blocks for the Quatech boards
 */
/* Copyright 1996-2003 The MathWorks, Inc.
*/


// First, with DLAB bit in LCR set to 0
// These are all offsets in IO space from the base address of
// the chosen UART.
#define DATA      0  // receive buffer on read, tx on write
#define IER       1  // Interrupt enable (read/write)
#define IIR       2  // Interrupt Ident (read only)
#define FCR       2  // FIFO control register (write only)
#define LCR       3  // Line control register (read/write)
#define MCR       4  // Moden control register (read/write)
#define LSR       5  // Line status register (read/write)
#define MSR       6  // Modem status register (read/write)
#define GISTAT    7  // Global interrupt status, all UARTS (read only)(Quatech)

// Now, with DLAB bit in LCR set to 1
#define DLSB      0  // LSB of baud rate divisor (read/write)
#define DMSB      1  // MSB of the board rate divisor (read/write)
#define OPTIONS   7  // Options register (Quatech)

// Bit definitions for the registers
// IER register
#define IERRCV     0x01  // Receive data available interrupt
#define IERXMT     0x02  // Transmitter holding register empty
#define IERLS      0x04  // Receiver line status interrupt
#define IERMS      0x08  // Modem status interrupt
#define IERSLEEP   0x10  // Sleep mode enable
#define IERPOWER   0x20  // Low power mode enable

// IIR register
#define IIRREASON  0x0f  // Mask for the 4 reason bits
#define IIR64      0x20  // Is the board in 64 byte FIFO mode?
#define IIRFEBL    0xc0  // FIFO mode enabled

// FCR register
#define FCREBL     0x01  // Enable the FIFOs
#define FCRRCLR    0x02  // Clear the receive FIFO
#define FCRTCLR    0x04  // Clear the transmit FIFO
#define FCRDMA     0x08  // Enable DMA mode if FCREBL is set
#define FCR64      0x20  // Set for 64 byte FIFO, clear for 16 byte FIFO
#define FCRONE     0x00  // Interrupt with one byte in FIFO
#define FCRQUARTER 0x40  // Interrupt when quarter full
#define FCRHALF    0x80  // interrupt when the FIFO is half full
#define FCRFULL    0xc0  // Interrupt when almost full FIFO

// LCR register
#define LCR5BIT    0x00  // 5 bit chars
#define LCR6BIT    0x01
#define LCR7BIT    0x02
#define LCR8BIT    0x03  // 8 bit chars
#define LCRSTOP    0x04  // Set for long (doubled) stop bit
#define LCRPARITY  0x08  // Set to enable parity checking
#define LCREVEN    0x10  // Set for even parity, clear for odd if STICK is clear
#define LCRSTICK   0x20  // with STICK set, if LCREVEN is set -> space parity
                         //                             clear -> mark parity
#define LCRBREAK   0x40  // Set to send break
#define LCRDLAB    0x80  // Divisor Latch Access Bit, DLAB

// MCR register
#define MCRDTR     0x01  // Set to force DTR HIGH
#define MCRRTS     0x02  // Set to force RTS HIGH
#define MCROUT1    0x04  // Set to force OUT1 HIGH (not wired)
#define MCROUT2    0x08  // Set to force OUT2 HIGH (not wired)
#define MCRLOOP    0x10  // Loopback (diagnostic) mode
#define MCRAFE     0x20  // Automatic RTS/CTS

// LSR register
#define LSRDR      0x01  // Data ready
#define LSROE      0x02  // Overrun error
#define LSRPE      0x04  // Parity error
#define LSRFE      0x08  // Framing error
#define LSRBI      0x10  // Break indicator
#define LSRTHRE    0x20  // Transmitter Holding Register empty
#define LSRTEMT    0x40  // Transmitter empty
#define LSRERR     0x80  // a byte with an error is in the fifo

// MSR register
#define MSRDCTS    0x01  // CTS changed since last read
#define MSRDDSR    0x02  // DSR changed since last read
#define MSRTERI    0x04  // Trailing edge Ring Indicator
#define MSRDDCD    0x08  // DCD changed since last read
#define MSRCTS     0x10  // set when external CTS is low
#define MSRDSR     0x20  // set when external DSR is low
#define MSRRI      0x40  // set when external RI is low
#define MSRDCD     0x80  // set when external DCD is low

// GISTAT register
// port1 pending = 0x01, port2 = 0x02, etc.

// OPTIONS register, Quatech boards only
#define OPTX8      0x03  // Use x8 clock multiplier
#define OPTX4      0x02
#define OPTX2      0x01
#define OPTX1      0x00

// DLSB and DMSB registers get the divisor

// Divisors with the 8x clock source
// Use as is for the 750 UART, but divide by 4 and use OPTX2 for the 550.
static divisors[14] =
{
        1,   // 921600
        2,   // 460800
        4,   // 230400
        8,   // 115200
       16,   // 57600
       24,   // 38400
       48,   // 19200
       96,   // 9600
      192,   // 4800
      384,   // 2400
      768,   // 1200
     1536,   // 600
     3072,   // 300
     8378,   // 110
};

// Baseboard UART drivers have 115200 max baud rate
static basedivisors[14] =
{
        1,   // 115200
        2,   // 57600
        3,   // 38400
        6,   // 19200
       12,   // 9600
       24,   // 4800
       48,   // 2400
       96,   // 1200
      192,   // 600
      384,   // 300
     1047,   // 110
};

#define UART750        3
#define UART550        2
#define UART450        1
