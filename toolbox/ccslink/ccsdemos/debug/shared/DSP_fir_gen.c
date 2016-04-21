/**********************************************************************
 *  FIR Filter routine from C64 DSP Library  
 *  C simulation code adapted for C28xx
 **********************************************************************/
void DSP_fir_gen
(
    const short *restrict x,  /* Input array [nr+nh-1 elements] */
    const short *restrict h,  /* Coeff array [nh elements]      */
    short       *restrict r,  /* Output array [nr elements]     */
    int nh,                   /* Number of coefficients.        */
    int nr                    /* Number of output samples.      */
)
{
    int i, j;
    long prod, sum;

    for (j = 0; j < nr; j++)
    {
        sum = 0;
        for (i = 0; i < nh; i++) {    
            prod = (long)x[j-i+65] * (long)h[i];
            sum += prod;
        }
        r[j] = (short)(sum >> 15);
     }  
}

