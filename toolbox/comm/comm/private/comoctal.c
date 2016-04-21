/*
 * $Revision: 1.3 $
 *
 * Copyright 1996-2002 The MathWorks, Inc.
 */
#include <math.h>
#include "tmwtypes.h"

/* Function: IsValidOctalNumber ===============================================
 * Abstract: Return 1 if the input is a valid octal number, otherwise return 0.
 */
boolean_T IsValidOctalNumber(real_T test)
{
    /*
     *  Check that a decimal input represents a valid octal number
     *
     *     - First check that the number is non-negative and integer-valued
     *     - Next, check that each decimal digit is in the range [0,7]
     */
    int32_T work1, work2, index, digit;
    
    int32_T numDigits = (int32_T)ceil(log10(1+test));
    /* Check to see that the number is non-negative  */
    if(test < 0) return(0);

    /* Check to see that the number is an integer */
    if((int32_T) test != test) return(0);
    
    /* Finally, check to see that each digit is in the range 0 to 7 */
    work1 = (int32_T) test;
    work2 = 10*(int32_T)floor(work1/10);
    for (index = 0; index < numDigits; index++) { 
        digit = work1-work2; 
        if (digit>7){ 
            return(0);
        } 
        work1 = (int32_T)floor(work1/10);
        work2 = 10*(int32_T)floor(work1/10);
    }
    return(1);
}

/* Function: ConvertOctaltoDecimal ============================================
 * Abstract: Convert an octal number to its equivalent decimal value
 *
 *    - First compute the number of digits in the octal number
 *    - Then perform the conversion, one digit at a time, starting
 *      with the least significant digit
 *
 *          work1: The remaining digits in the octal value
 *          work2: Equal to work1 with the least significant digit set to zero
 *          work3: Accumulator to compute decimal value
 *          work4: Octal place value - 1, 8, 64, ...
 */
int32_T ConvertOctaltoDecimal(int32_T OctalValue)
{
    int32_T numDigits = (int32_T)ceil(log10(1+OctalValue));
    int32_T work1 = OctalValue;
    int32_T work3 = 0;
    int32_T work4 = 1;
    int32_T indx1;

    int32_T work2 = work1/10;
	work2 *= 10;

    for (indx1 = 0; indx1++ < numDigits; ) { 
        work3 += (work1-work2)*work4;
        work4 <<= 3;  /* next power of 8 */
 
        work1 /= 10;  /* Remove least-significant decimal digit */
        work2 = work1/10;
		work2 *= 10;
   }
   return(work3);
}

/* Function: ConvertDecimaltoOctal ============================================
 * Abstract: Convert a decimal number to its equivalent octal value
 *
 *  - Divide the decimal number by 8 recursively, and find the octal number.
 *  - Example 1: decimal number = 10  ==> octal number = 12.
 *             (10%8) + (10/8)*10
 *  - Example 2: decimal number = 100  ==> octal number = 144.
 *             (100%8) + (12%8) * 10 + 1 * 100
 *                        100/8=12     12/8=1
 */
int32_T ConvertDecimaltoOctal(int32_T DecimalValue)
{
    int32_T octValue  = 0;
    int32_T tmpDecVal = DecimalValue;
    int     scale     = 1;

    while(tmpDecVal >= 8){
        octValue  += ((tmpDecVal % 8) * scale);
        scale     *= 10;
        tmpDecVal /= 8;
    }
    octValue += (tmpDecVal * scale);
    return(octValue);
}
