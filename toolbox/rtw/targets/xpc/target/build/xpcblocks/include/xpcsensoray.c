/* xpcsensoray.c - utility functions for the Sensoray 526 */
/* Copyright 2004 The MathWorks, Inc.                     */

// Register addresses, offset from base address
#define TCR   0x00
#define WDC   0x02
#define DAC   0x04
#define ADC   0x06
#define ADD   0x08
#define DIO   0x0A
#define IER   0x0C
#define ISR   0x0E
#define MSC   0x10
#define C0L   0x12
#define C0H   0x14
#define C0M   0x16
#define C0C   0x18
#define C1L   0x1A
#define C1H   0x1C
#define C1M   0x1E
#define C1C   0x20
#define C2L   0x22
#define C2H   0x24
#define C2M   0x26
#define C2C   0x28
#define C3L   0x2A
#define C3H   0x2C
#define C3M   0x2E
#define C3C   0x30
#define EED   0x32
#define EEC   0x34

// As offsets from base + 8*(channel-1),
#define CNTL  C0L
#define CNTH  C0H
#define CMR   C0M
#define CCSR  C0C

// EEPROM address tokens.  Specified as a comma separated list of 4 offsets
// [8:3] address, [2:1] 0x2, [0] 0x1
#define DAC0A  0x01D, 0x015, 0x00D, 0x005
#define DAC0B  0x03D, 0x035, 0x02D, 0x025
#define DAC1A  0x05D, 0x055, 0x04D, 0x045
#define DAC1B  0x07D, 0x075, 0x06D, 0x065
#define DAC2A  0x09D, 0x095, 0x08D, 0x085
#define DAC2B  0x0BD, 0x0B5, 0x0AD, 0x0A5
#define DAC3A  0x0DD, 0x0D5, 0x0CD, 0x0C5
#define DAC3B  0x0FD, 0x0F5, 0x0ED, 0x0E5
#define ADCREF 0x11D, 0x115, 0x10D, 0x105

// Define ISR bits
#define EEPROMDONE  0x80
#define ADCDONE     0x04
#define DACDONE     0x02

// Define A/D control register bits
#define ADMUXDELAY    0x8000
#define ADREF0        0x4000
#define ADREF10       0x2000
#define AD7           0x1000
#define AD6           0x0800
#define AD5           0x0400
#define AD4           0x0200
#define AD3           0x0100
#define AD2           0x0080
#define AD1           0x0040
#define AD0           0x0020
#define ADCVT(n)      (0x20 << (n))
#define ADREAD(n)     ((n) << 1)
#define ADREADREF10   0x0010
#define ADREADREF0    0x0012
#define ADSTART       0x0001

// Define D/A control register bits
#define DASTART       0x0001
#define DASELECT(n)   ((n) << 1)
#define DARESET       0x0008

// Count mode registers
// Give names even when a bit isn't set for self documentation of the code.
// Assert PRELOAD1 to load PR1, else PR0 if not asserted
#define PRELOAD0      0x0000
#define PRELOAD1      0x4000
// latch on read if not set, else latch on event
#define LATCHONREAD   0x0000
#define LATCHONEVENT  0x2000
// quadrature counting if not set, else software controlled counting
#define QUADRATURE    0x0000
#define NONQUADRATURE 0x1000
// count direction if nonquadrature, don't set for up, set for down
#define UPCOUNT       0x0000
#define DOWNCOUNT     0x0800
// counting modes (clock source), quadrature first
#define QUADX1        0x0000
#define QUADX2        0x0200
#define QUADX4        0x0400
//   then the non-quadrature modes
#define RISEA         0x0000
#define FALLA         0x0200
#define INTERNAL      0x0400
#define INTHALF       0x0600
// Count enables
#define DISABLE       0x0000
#define ENABLE        0x0080
#define HWEBL         0x0100
#define HWEBLINV      0x0180
// Hardware enable sources
#define HWCEN         0x0000
#define HWINDEX       0x0020
#define HWINDEXRF     0x0040
#define HWNRCAP       0x0060
// Auto load and reset RCAP
#define INDEXRISE     0x0010
#define INDEXFALL     0x0008
#define ROLLOVER      0x0004
// output polarity
#define OUTNORMAL     0x0000
#define OUTINVRT      0x0002
// Output source
#define RCAPOUT       0x0000
#define RTGLOUT       0x0001

// Define bits for the counter control and status registers
#define CNTRESET      0x8000
#define CNTLOAD       0x4000
#define CNTARM        0x2000
#define INTLATCH      0x1000
#define RISELATCH     0x0800
#define FALLLATCH     0x0400
#define ROINT         0x0200
#define INDEXRISEINT  0x0100
#define INDEXFALLINT  0x0080
#define ERRORINT      0x0040
// the above bits are write only control, below are read only status bits
#define INDEXSTAT     0x0020
#define COUTSTAT      0x0010
#define RCAPTRUE      0x0008
#define ICAPRISE      0x0004
#define ICAPFALL      0x0002
#define ECAP          0x0001

static bool waitISRbit( int base, int bitpattern )
{
    double t1;
    // Wait for all bits in bitpattern to become set.
    volatile int isr = rl32eInpW( base+ISR );
    // Remember: != has higher precedence than &, keep the ()
    t1 = rl32eGetTicksDouble();
    while( (isr & bitpattern) != bitpattern )
    {
        if( rl32eGetTicksDouble() - t1 > 1.0e6 )
        {
            printf("ERROR: 1 second timeout waiting for hardware completion, bit = 0x%x\n", bitpattern );
            return true;  // timeout, hardware failure.
        }
        isr = rl32eInpW( base+ISR );
    }
    rl32eOutpW( base+ISR, bitpattern );  // clear all done bits
    return false;  // no timeout
}

// Read the EEPROM with: var = readEEPROM( ADCREF, baseaddress );
static double readEEPROM( int h, int mh, int ml, int l, int base )
{
    union {
        struct {
            short l;
            short ml;
            short mh;
            short h;
        } s;
        double d;
    } cvt;

    rl32eOutpW( base+ISR, EEPROMDONE );  // clear done bit

    rl32eOutpW( base+EEC, h );
    waitISRbit( base, EEPROMDONE );
    cvt.s.h  = rl32eInpW( base+EED );

    rl32eOutpW( base+EEC, mh );
    waitISRbit( base, EEPROMDONE );
    cvt.s.mh = rl32eInpW( base+EED );

    rl32eOutpW( base+EEC, ml );
    waitISRbit( base, EEPROMDONE );
    cvt.s.ml = rl32eInpW( base+EED );

    rl32eOutpW( base+EEC, l );
    waitISRbit( base, EEPROMDONE );
    cvt.s.l  = rl32eInpW( base+EED );

    //printf("%x %x %x %x = %lg\n",
    //       cvt.s.h & 0xffff,
    //       cvt.s.mh & 0xffff,
    //       cvt.s.ml & 0xffff,
    //       cvt.s.l & 0xffff,
    //       cvt.d );

    return cvt.d;
}
