/* $Revision: 1.2 $ */
/*****************************************
 * For C2xx, disable the watchdog timer  *
 * Define Disable_WD():                  *
 * - disables the f24xx watch dog timer; *
******************************************/

#if defined(_TMS320C28X)

void Disable_WD(void)
{
  int *WatchdogWDCR = (void *) 0x7029;

  // Disable the watchdog: only works on boards
  asm(" EALLOW ");
  *WatchdogWDCR = 0x0068;
  asm(" EDIS ");
}

#elif defined(_TMS320C2XX)

#define WDCR        *((volatile int *)0x7029) /* WD Control reg */
#define DISABLE_WatchDog  0x0068

void Disable_WD(void)
{
    WDCR |= DISABLE_WatchDog;
}

#endif