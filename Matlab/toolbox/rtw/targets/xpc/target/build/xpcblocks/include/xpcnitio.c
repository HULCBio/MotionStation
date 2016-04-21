/* $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:02:35 $*/

/**
 * Abstract: NI TIO functions
 *
 * Copyright 1996-2003 The MathWorks, Inc.
 */
#define Clock_Config_Reg                0x73C
#define G01_Joint_Reset_Reg             0x090
#define G01_Joint_Status_1_Reg          0x036
#define G0_Command_Reg                  0x00C
#define G0_Counting_Mode_Reg            0x0B0
#define G0_Input_Select_Reg             0x048
#define G0_Load_A_Reg                   0x038
#define G0_Load_B_Reg                   0x03C
#define G0_Mode_Reg                     0x034
#define G0_Second_Gate_Reg              0x0B4
#define G0_DMA_Config_Reg               0x0B8
#define G0_DMA_Status_Reg               0x0B8
#define G0_SW_Save                      0x018

typedef unsigned short ushort_T;
typedef unsigned int   uint_T;

static ushort_T regOff16[4] = {0x0, 0x2, 0x100, 0x102};
static ushort_T regOff32[4] = {0x0, 0x8, 0x100, 0x108};

static ushort_T IOReg[8]    = {0x7A0, 0x79C, 0x798, 0x794,
                               0x790, 0x78C, 0x788, 0x784};

static void TIO_Write16(volatile ushort_T *add,
                        ushort_T chan, ushort_T reg, ushort_T value) {
    add[(reg + regOff16[chan]) / 2] = value;
}

static ushort_T TIO_Read16(volatile ushort_T *add,
                           ushort_T chan, ushort_T reg) {
    return add[(reg + regOff16[chan]) / 2];
}

static void TIO_Write32(volatile uint_T *add, ushort_T reg, uint_T value) {
    add[reg / 4] = value;
}

static uint32_T TIO_Read32(volatile uint32_T *add, ushort_T reg) {
    return add[reg / 4];
}

/* Which Bank (X or Y) is being used (X => 0, Y => 1) */
static int whichBank(volatile ushort_T *TIO, ushort_T chan) {
    ushort_T reg  = G01_Joint_Status_1_Reg;
    /* If ctr 0 or 2, it's bit 0; else it's bit 2 */
    ushort_T mask = 0x1 << (chan % 2);

    /* increment if channel 2 or 3 */
    if (chan / 2) reg += 0x100;
    return !!(TIO[reg / 2] & mask);
}

/* Reset given counter */
static void resetCtr(volatile ushort_T *TIO, int chan) {
    /* increment if channel 2 or 3 */
    ushort_T reg = G01_Joint_Reset_Reg + ((chan / 2) ? 0x100 : 0);

    /* if ctr 0 or 2, bit 2, otherwise bit 3 */
    TIO[reg / 2] = 0x4 << (chan % 2);
}

static void Cont_Pulse_Train_Generation(volatile ushort_T *TIO,
                                        ushort_T  chan,
                                        uint_T   *lowhigh) {

    TIO_Write16(TIO, chan, G0_Command_Reg, 0x0900);
    /* Gi_Load_A <= low - 1 */
    TIO_Write32((volatile uint_T *)TIO,
                (ushort_T)(G0_Load_A_Reg + regOff32[chan]), lowhigh[0]);
    TIO_Write32((volatile uint_T *)TIO,
                (ushort_T)(G0_Load_B_Reg + regOff32[chan]), lowhigh[1]);

    /* Select Bank Y before writing the registers. */
    /**
     * G0_Bank_Switch_Enable <= 1 (use bank y, since we have not armed)
     * G0_Bank_Switch_Mode   <= 1 (software)
     * G0_Synchronized_Gate  <= 1
     * G0_Up_Down            <= 0 (down counting)
     */
    TIO_Write16(TIO, chan, G0_Command_Reg, 0x1900);

    /* Gi_Load_A <= low - 1 */
    TIO_Write32((volatile uint_T *)TIO,
                (ushort_T)(G0_Load_A_Reg + regOff32[chan]), lowhigh[0]);
    TIO_Write32((volatile uint_T *)TIO,
                (ushort_T)(G0_Load_B_Reg + regOff32[chan]), lowhigh[1]);

    TIO_Write16(TIO, chan, G0_Command_Reg, 0x1904);

#if 0
    if (chan == 0)
        printf("%08x,%08x: %08x\n", (unsigned int)
               TIO_Read32((volatile uint_T *)TIO,
                          (ushort_T)G0_SW_Save),
               (unsigned int)lowhigh[0], (unsigned int)lowhigh[1]);
    rl32eWaitDouble(1.0);
    if (chan == 0)
        printf("After Wait: %08x\n", (unsigned int)
               TIO_Read32((volatile uint_T *)TIO,
                          (ushort_T)G0_SW_Save));
#endif

    /* Gi_Alternate_Sync <= 1 (needed for 80 MHz) */
    TIO_Write16(TIO, chan, G0_Counting_Mode_Reg, 0x2000);

    /* Gi_Source_Select           <= 30 (G_In_Time_Base3)
     * Gi_Source_Polarity         <= 0  (rising edges)
     * Gi_Gate_Select             <= 30 (Logic Low)
     * Gi_OR_Gate                 <= 0  (Dont OR with other ctrs gate)
     * Gi_Output_Polarity         <= 0  (initial high)
     * Gi_Gate_Select_Load_Source <= 0  (Dont select LOAD_[AB] based on gate)
     */
    TIO_Write16(TIO, chan, G0_Input_Select_Reg, 0x0F78);

    /**
     * Gi_Reload_Source_Switching    <= 1 (swap load_[ab] on ctr reload)
     * Gi_Loading_On_Gate            <= 0 (ctr doesnt reload on gate)
     * Gi_Gate_Polarity              <= 1 (active low)
     * Gi_Loading_On_TC              <= 1 (reload ctr on TC)
     * Gi_Counting_Once              <= 0 (Dont disarm ctr: keep going)
     * Gi_Output_Mode                <= 2 (toggle on TC)
     * Gi_Load_Source_Select         <= 1 (Load Reg B)
     * Gi_Stop_Mode                  <= 0 (stop on gate condition)
     * Gi_Trigger_Mode_For_Edge_Gate <= 2 (gate starts counting)
     * Gi_Gate_On_Both_Edges         <= 0 (Dont gate on both)
     * Gi_Gating_Mode                <= 0 (Gating disabled)
     */
    TIO_Write16(TIO, chan, G0_Mode_Reg, 0xB290);

    /**
     * G0_Bank_Switch_Enable <= 1 (use bank y, since we have not armed)
     * G0_Bank_Switch_Mode   <= 1 (software)
     * G0_Synchronized_Gate  <= 1
     * G0_Up_Down            <= 0 (down counting)
     * G0_Load               <= 1 (Load the selected reg, i.e. load_reg_b)
     */
    TIO_Write16(TIO, chan, G0_Command_Reg, 0x1904);

    return;
}
