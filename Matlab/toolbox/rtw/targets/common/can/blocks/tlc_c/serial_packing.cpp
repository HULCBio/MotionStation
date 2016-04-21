/*
 * $Revision: 1.6 $
 * $Date: 2002/11/15 16:39:06 $
 *
 * Copyright 2002 The MathWorks, Inc.
 */
#include "serial_packing.hpp"
#include <math.h>

typedef union WORD_UNION { 
      WORD value;
      uint8_T  bytes[sizeof(WORD)];
} WORD_UNION;

/* --- Internal Function Declaration --- */

static inline  WORD shift_right( WORD_UNION * V, const int shift, const int bit_length);
static         void shift_left( WORD S, WORD_UNION * V, const int shift, const int bit_length);
static inline  void pre_process( int & w0, int & w1, int & start_bit,
                        int & total_word_count, const int signal_endian,
                        const int message_length);
static inline  void byte_reorder(WORD_UNION * V);

/* --- Internal Function Implementations --- */


/*------------------------------------------------------------
 * Function
 *
 *   pack   
 *
 * Purpose
 *
 *   pack a signal into an arbitrary position in a message
 *   in big endian or little endian byte ordering
 *
 * Arguments
 *
 *   M               -  The output message which the signal will be or'ed into
 *   S               -  The signal to pack into the message
 *   message_length  -  The number of bytes in the message
 *   start_bit       -  The bit position at which to insert the signal
 *   bit_length      -  The number of relevent bits from lsb in the signal
 *   signal_endian   -  BIG_ENDIAN or LITTLE_ENDIAN defines the packing type
 *                      for the signal. Note the for LITTLE_ENDIAN start_bit
 *                      is calculated from the left most byte of the message
 *                      and for BIG_ENDIAN start_bit is calculated from the
 *                      right most byte. That is because BIG_ENDIAN increases
 *                      the byte significance from right to left
 *
 * Returns
 *
 *   M is the message and the result of this operation. Note
 *   that the signal is bitwise ored into the message thus preserving
 *   any previous set bits in M
 *----------------------------------------------------------*/
void pack(WORD * M , WORD S, int message_length, int start_bit, int bit_length, int signal_endian){

   WORD_UNION V[2]; // Working copy of signal
   int w0,w1; // The words in the target array M where the shifted value will end up
   int shift; // The distance to shift S
   int total_word_count;

#ifdef SERIAL_PACK_DEBUG
   mexPrintf("S %d ml %d sb %d bl %d se %d\n", S, message_length, start_bit, bit_length, signal_endian);
#endif

   // Get some constants
   pre_process( w0, w1, start_bit,  total_word_count, signal_endian, message_length);

   // calculate the shift modulo one machine word
   shift = start_bit % ( WORD_SIZE * 8 );
   
   // mask and shift S and place result in V
   shift_left(S, V, shift, bit_length);

#ifdef SERIAL_PACK_DEBUG
   mexPrintf("Total WC : %d\n",total_word_count);
   mexPrintf("w0 : %d\n",w0);
   mexPrintf("w1 : %d\n",w1);
   mexPrintf("shift %d\n",shift);
   mexPrintf("V0 %x\nV1 %x\n",V[0].value,V[1].value);
#endif

   if ( CPU_ENDIAN != signal_endian ){
      byte_reorder(V);
#ifdef SERIAL_PACK_DEBUG
      mexPrintf("RB : V0 %x\nRB : V1 %x\n",V[0].value,V[1].value);
#endif
   }

   /* -- Place the shifted words into the correct position -- */

   if ( w0 >= 0 ){
      M[w0] |= V[0].value;
   }

   if ( w1 >= 0 && w1 < total_word_count ){
      M[w1] |= V[1].value;
   }

#ifdef SERIAL_PACK_DEBUG
   mexPrintf("M0 %x\nM1 %x\n",M[0],M[1]);
   mexPrintf("\n");
#endif
}


/*------------------------------------------------------------
 * Function
 *
 *   unpack   
 *
 * Purpose
 *
 *   pack a signal into an arbitrary position in a message
 *   in big endian or little endian byte ordering
 *
 * Arguments
 *
 *   M               -  The message which the signal will extracted from
 *   message_length  -  The number of bytes in the message
 *   start_bit       -  The bit position at which to extract the signal
 *   bit_length      -  The number of relevent bits from lsb in the signal
 *   signal_endian   -  BIG_ENDIAN or LITTLE_ENDIAN defines the packing type
 *                      for the signal. Note the for LITTLE_ENDIAN start_bit
 *                      is calculated from the left most byte of the message
 *                      and for BIG_ENDIAN start_bit is calculated from the
 *                      right most byte. That is because BIG_ENDIAN increases
 *                      the byte significance from right to left
 *
 * Returns
 *
 *   S the unpacked signal
 *
 *----------------------------------------------------------*/
WORD unpack(WORD * M , int message_length, int start_bit, int bit_length, int signal_endian){

   WORD_UNION V[2]; // Working copy of signal
   int w0,w1; // The words in the target array M where the shifted value will end up
   int shift; // The distance to shift S
   int total_word_count;
   WORD S; // The return signal value;


   // Get some constants
   pre_process( w0, w1, start_bit,  total_word_count, signal_endian, message_length);

   // calculate the shift modulo two machine words
   shift = start_bit % ( WORD_SIZE * 8 );
   
   // Place the extracted words into the correct position 
   if ( w0 >= 0 ){
      V[0].value = M[w0];
   }
   if ( w1 < total_word_count ){
       V[1].value = M[w1];
   }

   if ( CPU_ENDIAN != signal_endian ){
      byte_reorder(V);
   }

   S = shift_right(V, shift, bit_length);

   return S;
}

/*------------------------------------------------------------
 * Function
 *
 *   shift_left  
 *
 * Purpose
 *
 *   shifts WORD S into two element array V. The shift value
 *   should be no larger than 2 * WORD_BIT_SIZE
 *
 * Arguments
 *
 *   S            -  The raw WORD to be shifted. It is assumed all bits
 *                   above bit_length are zero
 *   V            -  A two element array to store the result of the 
 *                   shift
 *   shift        -  The number of bits to shift by
 *   bit_length   -  The number of bits to be preserved in S
 *
 * Returns
 *
 *   V is where the result of the shift is held
 *----------------------------------------------------------*/
static inline void shift_left( WORD S, WORD_UNION * V, const int shift, const int bit_length){

   if ( bit_length < sizeof(WORD)*8 ){
      S &= ~( ~0 << bit_length );
   }

   if( (shift + bit_length) > WORD_BIT_SIZE){
      V[0].value = S << shift;
      V[1].value = S >> ( WORD_BIT_SIZE - shift );
   }else{
      V[0].value = S << shift;
      V[1].value = 0;
   } 
}

/*------------------------------------------------------------
 * Function
 *
 *   shift_right
 *
 * Purpose
 *
 *   extract signal from two word array V. shift
 *   should be no larger than 2 * WORD_BIT_SIZE
 *
 * Arguments
 *
 *   V            -  A two element array to store the result of the 
 *                   shift
 *   shift        -  The number of bits to shift by
 *   bit_length   -  The number of bits to be preserved in the signal
 *
 * Returns
 *
 *   The extracted signal
 *----------------------------------------------------------*/

static inline WORD shift_right( WORD_UNION * V, const int shift, const int bit_length){

   WORD S;

   if( (shift + bit_length) > WORD_BIT_SIZE){
      S =  V[0].value >> shift ;
      S |=  V[1].value << ( WORD_BIT_SIZE - shift ); 
   }else{
      S = V[0].value >> shift;
   } 

   if ( bit_length < sizeof(WORD) * 8 ){
      S &= ~( ~0 << bit_length );
   }

   return S;
}

/*------------------------------------------------------------
 * Function
 *
 *    byte_reorder      
 *
 * Purpose
 *
 *   Change the order of the bytes in the two words 
 *   of the argument.
 *
 * Arguments
 *
 *   V   -   A two element array of WORD_UNION
 *
 *----------------------------------------------------------*/
static inline void byte_reorder(WORD_UNION * V){
      int byte;
      // temp variables for the swap.
      WORD_UNION word0tmp = V[0];
      WORD_UNION word1tmp = V[1];
      for(byte=0;byte<sizeof(WORD);byte++){
        V[0].bytes[byte] = word0tmp.bytes[sizeof(WORD)-1-byte];
        V[1].bytes[byte] = word1tmp.bytes[sizeof(WORD)-1-byte];
      }
}


/*------------------------------------------------------------
 * Function
 *
 *   pre_process  
 *
 * Purpose
 *
 *   Calculate some general values required by packing
 *   and unpacking.
 *
 * Arguments
 *
 *   int & w0           -     index of first word in target array
 *   int & w1           -     index of second word in target array
 *   int & start_bit    -     start_bit of signal
 *
 *   const int signal_endian  -  BIG_ENDIAN or LITTLE_ENDIAN packing
 *   const int message_length -  Length of the message in bytes
 *
 * Returns
 *
 *   All the parameters passed by reference are modifed by this function. w0
 *   and w1 and mask are always modified and start_bit will be modified if the
 *   WORD_SIZE does not divide evenly into the message size
 *   
 *----------------------------------------------------------*/
static inline void pre_process( int & w0, int & w1, int & start_bit,
      int & total_word_count, const int signal_endian, const int message_length){

   total_word_count =
      message_length / WORD_SIZE + ( ( message_length % WORD_SIZE ) > 0 );

   if ( signal_endian == BIG_ENDIAN ) {
      int unused_bytes;

      // Modify the start bit so we can work with an integral number
      // of words
      unused_bytes = total_word_count * WORD_SIZE - message_length;
      start_bit += unused_bytes * 8;

      w0 = total_word_count - start_bit / WORD_BIT_SIZE - 1 ;
      w1 = w0 - 1;

   }else{

      w0 = start_bit / WORD_BIT_SIZE ;
		w1 = w0 + 1;

   }
}
