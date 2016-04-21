/*
 * Copyright 1990-2004 The MathWorks, Inc.
 * The MathWorks grants you the right to copy this file to other 
 * computer systems and embed this file within your products. You 
 * can make modifications for your application.
 *
 * File: sigregdef.h     $Revision $
 *
 * Abstract:
 *  Data structures and access methods for sigregions.
 *
 *  Allows access to simulink signals.  See <matlabroot>/simulink/src/barplot.c
 *  for example code and 
 *  <matlabroot>\toolbox\simulink\simdemos\sfcndemo_barplot.mdl for an example
 *  model.  Also see the 'PUBLIC DESCRIPTION' section at the bottom of 
 *  of the file for further explanation and the list of macro assessors that
 *  should be used to access the sigmap and siglist info.  Note that direct
 *  access to these structures is not recomended as the structures may
 *  change in future releases.
 */

#ifndef sigregdef_h
#define sigregdef_h

#define SLREG_NO_FLAGS (0)

#define SLREG_AVAIL           (1U << 0) 
#define SLREG_REUSED          (1U << 1)
#define SLREG_FCNCALL         (1U << 2)
#define SLREG_MERGE           (1U << 3)
#define SLREG_GROUND          (1U << 4) 
#define SLREG_FRAME           (1U << 5)  /* opt exclude flag-see below          */
#define SLREG_WIDE_FRAME      (1U << 6)  /* opt exclude flag-see below          */
#define SLREG_MATRIX          (1U << 7)  /* opt exclude flag-see below          */
#define SLREG_COMPLEX         (1U << 8)  /* opt exclude flag-see below          */
#define SLREG_ALLOW_REUSED    (1U << 9)  /* opt un-exclude flag - see below     */
#define SLREG_ACTION          (1U << 10) 
#define SLREG_CONDEXEC        (1U << 11) /* signal is only conditional executed */
#define SLREG_EXTMODE_UNAVAIL (1U << 12) /* signal is not available in extmode  */
#define SLREG_ELIMINATED      (1U << 13) /* dead brance elimination             */
#define SLREG_INCLUDE_GRND    (1U << 14) /* opt include ground regions          */

#define IS_BIT_SET(uword32,bit) ((uword32 & bit) != 0)

/* region node */
typedef struct SL_SigRegion_tag {
#if !defined(S_FUNCTION_NAME)
    slPort *portObj;        /* output port associated with reg */
#else
    void *portObj;
#endif
    const void   *data;     /* pointer to the data              */
    int          startIdx;  /* starting element of the region (i.e., 'data'
                             * points to the 'startIdx' element of the port)
                             */
    int          nEls;      /* number of elements in region     */
    bool         entireSig; /* is this region the whole sig?    */
    unsigned int status;    /* bit field: see SLREG_xxx status
                             * vals above */

    int index; /* The i'th region in the original map.  So, if a mux
                * has three sigs coming in, a,b,c, a is index 0, b 1,
                * and c 3.  If the regions were an array instead of
                * a linked list this would be the array index. 
                * BE CAREFUL: If regions are removed due to being
                * duplicate or unavailable, the index field is not
                * touched up, so the index field always remains what
                * the original signal map for the composite signal
                * represented.  I'm not sure if this is good behavior
                * or not, but this is how it currently works:
                * 1/16/04 HJT
                */

    int workInt;  /* A work integer.  Temp mem location for use when
                   * shuffling regions.
                   */

    /*
     * The following can be derived from the port, but since s-functions
     * do not currently have direct access to the internal slPort *,
     * we must put a copy of the required info directly into this struct.
     */
    int dType;
    int dTypeSize;
    int complexity;
    int frameSize;

    /*
     *
     */
    bool discrete;   /*true if discrete in time or value (draw as stair)*/

    /*
     * M and N
     *
     * o Notes:
     *    If not a frame (frameSize == 0)
     *       m = number of rows (-1 if not matrix)
     *       n = number of cols (sigWidth if not matrix)
     *    If frame 
     *       m = frameSize
     *       n = number of columns
     *    basically, the frame is treated as a matrix.
     */
    int m;
    int n;

    struct SL_SigRegion_tag *next;
    struct SL_SigRegion_tag *prev;
} SL_SigRegion;


/*******************************************************************************
 *                  SIGREGION: PUBLIC ACCESSORS                                *
 ******************************************************************************/

/*
 * The number of elements in the region.
 */
#define gsr_nEls(reg) ((reg)->nEls)

/*
 * A pointer to the next region in the linked list. NULL if at the end of
 * the list.
 */
#define gsr_NextReg(reg) ((reg)->next)

/*
 * A const char * pointer into the data.
 */
#define gsr_data(reg) ((const char *)((reg)->data))

/*
 * Starting element of the region (i.e., 'data' points to the 'startIdx'
 * element of the port)
 */
#define gsr_startIdx(reg) ((reg)->startIdx)

/*
 * Output port associated with region.
 */
#define gsr_portObj(reg) ((reg)->portObj)

/* 
 * The simulink data type identifier for the region.
 */
#define gsr_DataType(reg) ((reg)->dType)

/*
 * The number of bytes in one, non-complex data value.
 */
#define gsr_DataTypeSize(reg) ((reg)->dTypeSize)

/*
 * True if the data region contains complex elements.
 */
#define gsr_Complex(reg) ((reg)->complexity)

/*
 * The number of rows.  If not matrix, -1.
 */
#define gsr_M(reg) ((reg)->m)

/*
 * The number of cols.  If not matrix, the sig width of the corresponding
 * region.
 */
#define gsr_N(reg) ((reg)->n)

/*
 * The availability status of the region (SLREG_AVAIL if avail, else one
 * of the status described above in the "Public Description" section.
 */
#define gsr_status(reg) ((reg)->status)

#define gsr_index(reg) ((reg)->index)

#endif /* sigregdef_h */
