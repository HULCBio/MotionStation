/*****************************************************************************
******************************************************************************
*
*               Declarations to be used in both generated code and the rest of
*               Real-Time Windows Target.
*
*               $Revision: 1.12 $
*               $Date: 2002/04/14 18:54:28 $
*               $Author: batserve $
*
*               Copyright 1994-2002 The MathWorks, Inc.
*
******************************************************************************
*****************************************************************************/


#ifndef __RTWINTYP_H_
#define __RTWINTYP_H_


/*****************************************************************************
;*
;*		Datatypes
;*
;****************************************************************************/


/* driver I/O device type */

enum IODEVICE {
                 ANALOGINPUT = 0,
                 ANALOGOUTPUT,
                 DIGITALINPUT,
                 DIGITALOUTPUT,
                 COUNTERINPUT,
                 TIMEROUTPUT,
                 ENCODERINPUT,
                 OTHERINPUT,
                 OTHEROUTPUT,
                 MAXDRVIODEVICE
               };
typedef enum IODEVICE IODEVICE;


/* driver I/O action code */

enum DRVIOACTION {
                  IORESET = 0,
                  IOREAD,
                  IOWRITE,
                  IOREADWITHRESET,
                  MAXIOACTION
                 };
typedef enum DRVIOACTION DRVIOACTION;


/* mode of Simulink <--> RTWin data conversion */

enum RANGEMODE {
                 VOLTS = 0,
                 NORMALIZED_BIPOLAR,
                 NORMALIZED_UNIPOLAR,
                 RAW,
                 MAXRANGEMODE
               };
typedef enum RANGEMODE RANGEMODE;


/* access mode for digital I/O */

enum DIOMODE {
               DIOBIT = 0,
               DIOBYTE,
               MAXDIOMODE
             };
typedef enum DIOMODE DIOMODE;


/* reset type for counter input */

enum RESETMODE {
                 RESETNEVER = 0,
                 RESETALWAYS,
                 RESETLEVEL,
                 RESETRISING,
                 RESETFALLING,
                 RESETEITHER,
                 MAXRESETMODE
               };
typedef enum RESETMODE RESETMODE;


/* counter edge type for counter input */

enum COUNTEREDGE {
                   COUNTEREDGERISING = 0,
                   COUNTEREDGEFALLING,
                   MAXCOUNTEREDGE
                 };
typedef enum COUNTEREDGE COUNTEREDGE;


/* counter gate type for counter input */

enum COUNTERGATE {
                   GATENONE = 0,
                   GATEENABLEHIGH,
                   GATEENABLELOW,
                   GATESTARTRISING,
                   GATESTARTFALLING,
                   GATERESETRISING,
                   GATERESETFALLING,
                   GATELATCHRISING,
                   GATELATCHFALLING,
                   GATELATCHRESETRISING,
                   GATELATCHRESETFALLING,
                   MAXCOUNTERGATE
                 };
typedef enum COUNTERGATE COUNTERGATE;


/* quadrature mode for encoder input */

enum QUADMODE {
                QUADSINGLE = 0,
                QUADDOUBLE,
                QUADQUADRUPLE,
                MAXQUADMODE
              };
typedef enum QUADMODE QUADMODE;


/* index input mode for encoder input */

enum INDEXPULSE {
                  INDEXGATE = 0,
                  INDEXRESET,
                  INDEXRISING,
                  INDEXFALLING,
                  MAXINDEXPULSE
                };
typedef enum INDEXPULSE INDEXPULSE;


/* analog I/O parameters structure */

struct ANALOGIOPARM {
                     RANGEMODE mode;
                     int rangeidx;
                    };
typedef struct ANALOGIOPARM ANALOGIOPARM;


/* digital I/O parameters structure */

typedef DIOMODE DIGITALIOPARM;


/* counter input parameters structure */

struct COUNTERINPARM {
                       COUNTEREDGE edge;
                       COUNTERGATE gate;
                     };
typedef struct COUNTERINPARM COUNTERINPARM;


/* analog I/O parameters structure */

struct ENCODERINPARM {
                      QUADMODE quad;
                      INDEXPULSE index;
                      double infilter;
                     };
typedef struct ENCODERINPARM ENCODERINPARM;


/* other I/O parameters structure */

struct OTHERIOPARM {
                    int n;
                    double *parm;
                   };
typedef struct OTHERIOPARM OTHERIOPARM;


/* RTWINBOARD structure used in compiled model */

typedef struct {
                const char *Name;
                unsigned Address;
                int OptionsSize;
                double *Options;
               }
RTWINBOARD;


#endif // __RTWINTYP_H_
