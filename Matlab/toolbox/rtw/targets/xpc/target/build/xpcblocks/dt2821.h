/* $Revision: 1.3 $ */
/* 

   xPC Target drivers for Data Translation DT2821 series 

   Device                  D/A    A/D   A/D  A/D   A/D      A/D         A/D    
     ID     Board         ports   kHz    SE   DI  bits     gains       ranges  
   ------  -------------  -----  -----  ---  ---  ----  ------------  ---------
     1     DT2821           2      50    16   8    12      1,2,4,8     -10,10  
     2     DT2821-F-16SE    2     150    16   x    12      1,2,4,8     -10,10  
     3     DT2821-F-8DI     2     150     x   8    12      1,2,4,8     -10,10  
     4     DT2821-G-16SE    2     250    16   x    12      1,2,4,8    -5,-10,10
     5     DT2821-G-8DI     2     250     x   8    12      1,2,4,8    -5,-10,10
     6     DT2823           2     100     x   4    12         1          -10   
     7     DT2824-PGH       x      50    16   8    16      1,2,4,8     -10,10  
     8     DT2824-PGL       x      50    16   8    12   1,10,100,500   -10,10  
     9     DT2825           2      45    16   8    12   1,10,100,500   -10,10  
    10     DT2827           2     100     x   4    16         1          -10   
    11     DT2828           2     100     4   x    12         1        -10,10  

   Devices 7 and 8 do not support D/A. Each of the others has two DAC ports,
   which can be independently configured for one of these output ranges:
   -/+10, -/+5, -/+2.5, 0-10, and 0-5 Volts.

   This driver supports only one channel on device 11.

   Copyright 1996-2002 The MathWorks, Inc.
*/

#define	DT2821			1
#define	DT2821_F_16SE	2
#define	DT2821_F_8DI	3
#define	DT2821_G_16SE	4
#define	DT2821_G_8DI	5
#define	DT2823			6
#define	DT2824_PGH		7
#define	DT2824_PGL		8
#define	DT2825			9
#define	DT2827			10
#define	DT2828			11


#define	ADCSR(base)		((base) + 0x0) /* A/D Control & Status */
#define	CHANCSR(base)	((base) + 0x2) /* Channel-Gain List Control & Status */
#define	ADDAT(base)		((base) + 0x4) /* A/D Data */
#define	DACSR(base)		((base) + 0x6) /* D/A Control & Status */
#define	DADAT(base)		((base) + 0x8) /* D/A Data */
#define	DIODAT(base)	((base) + 0xA) /* DIO Data */
#define	SUPCSR(base)	((base) + 0xC) /* Supervisory Control & Status */
#define	TMRCTR(base)	((base) + 0xE) /* Pacer Clock */

#define		LBOE		1	/* DACSR bit */
#define		HBOE		2	/* DACSR bit */

