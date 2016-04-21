/* $Revision: 1.2 $ */
#pragma pack(push,1)

typedef union _pW {
	char high;
	char low;
} _packedWord;

typedef struct _pDW {
	_packedWord high;
	_packedWord low;
} _packedDWord;

typedef struct _pQW {
	_packedDWord high;
	_packedDWord low;
} _packedQWord;

typedef union __Union {
	_packedQWord packed;
	int dwords[2];
	short words[4];
	char bytes[8];
} _mmxdata;
	
void _stdcall _emms(void);
/* pack with signed saturation */
void _stdcall _packsswb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _packsswbi(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _packssdw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _packssdwi(_mmxdata *array,_mmxdata *imm,int n);
/* pack with unsigned saturation */
void _stdcall _packuswb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _packuswbi(_mmxdata *array,_mmxdata *imm,int n);
/* packed add */
void _stdcall _paddb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _paddbi(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _paddw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _paddwi(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _paddd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _padddi(_mmxdata *array,_mmxdata *imm,int n);
/* packed add with saturation */
void _stdcall _paddsb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _paddusb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _paddusbi(_mmxdata *array1,_mmxdata *_imm,int n);
void _stdcall _paddsbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _paddsw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _paddusw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _padduswi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _paddswi(_mmxdata *array,_mmxdata *imm,int n);
/* pand */
void _stdcall _pand(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pandi(void *array1,_mmxdata *imm,int n);
/* pandn */
void _stdcall _pandn(void *array1,void *array2,int n);
void _stdcall _pandni(void *array1,_mmxdata *imm,int n);
/* pcmpeq */
void _stdcall _pcmpeqb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpeqbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _pcmpeqw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpeqwi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _pcmpeqd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpeqdi(_mmxdata *array1,_mmxdata *imm,int n);
/* pcmpgt */
void _stdcall _pcmpgtb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpgtbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _pcmpgtw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpgtwi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _pcmpgtd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpgtdi(_mmxdata *array1,_mmxdata *imm,int n);
/* pmaddwd */
void _stdcall _pmaddwd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pmaddwdi(_mmxdata *array1,_mmxdata *imm,int n);
/* pmulhw */
void _stdcall _pmulhw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pmulhwi(_mmxdata *array1,_mmxdata *array2,int n);
/* pmullw */
void _stdcall _pmullw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pmullwi(_mmxdata *array1,_mmxdata *imm,int n);
/* por */
void _stdcall _por(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pori(_mmxdata *array1,_mmxdata *array2,int n);
/* psl */
void _stdcall _psllw(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psllwi(_mmxdata *array,unsigned char int8,int n);
void _stdcall _pslld(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _pslldi(_mmxdata *array,unsigned char int8,int n);
void _stdcall _psllq(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _psllqi(_mmxdata *array,unsigned char int8,int n);
/* psra */
void _stdcall _psraw(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _psrawi(_mmxdata *array,unsigned char int8,int n);
void _stdcall _psrad(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _psradi(_mmxdata *array,unsigned char int8,int n);
/* psrl */
void _stdcall _psrlw(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _psrlwi(_mmxdata *array,unsigned char int8,int n);
void _stdcall _psrld(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _psrldi(_mmxdata *array,unsigned char int8,int n);
void _stdcall _psrlq(_mmxdata *array,_mmxdata *imm,int n);
void _stdcall _psrlqi(_mmxdata *array,unsigned char int8,int n);
/* packed sub routines */
void _stdcall _psubb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubwi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubdi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubsb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubsbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubsw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubswi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubsb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubsbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubsw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubswi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubusb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubusbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _psubusw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _psubuswi(_mmxdata *array1,_mmxdata *imm,int n);
/* punpckhwd */
void _stdcall _punpckhbw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _punpckhbwi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _punpckhwd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _punpckhwdi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _punpckhdq(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _punpckhdqi(_mmxdata *array1,_mmxdata *imm,int n);
/* punpckl */
void _stdcall _punpcklbw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _punpcklbwi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _punpcklwd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _punpcklwdi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _punpckldq(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _punpckldqi(_mmxdata *array1,_mmxdata *imm,int n);
/* pxor */
void _stdcall _pxor(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pxori(_mmxdata *array1,_mmxdata *imm,int n);
/* moves */
void _stdcall _pmemmove(_mmxdata *dst,_mmxdata *src,int n);
void _stdcall _pmemset(_mmxdata *dst,_mmxdata *imm,int n);

/* replicate instructions */
void _stdcall _replicatebyte(_mmxdata *dst,unsigned char c);
void _stdcall _replicateword(_mmxdata *dst,unsigned short w);
void _stdcall _replicatedword(_mmxdata *dst,unsigned int i);

/* missing comparison instruction */
/* pcmpeq */
void _stdcall _pcmpneqb(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpneqbi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _pcmpneqw(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpneqwi(_mmxdata *array1,_mmxdata *imm,int n);
void _stdcall _pcmpneqd(_mmxdata *array1,_mmxdata *array2,int n);
void _stdcall _pcmpneqdi(_mmxdata *array1,_mmxdata *imm,int n);

/* reduce */
int _stdcall _reduceBooleanb(_mmxdata *map,int n);
int _stdcall _reduceCmpeqb(_mmxdata *map,_mmxdata *imm,int n);
int _stdcall _reduceGtb(_mmxdata *map,_mmxdata *imm,int n);
int _stdcall _reduceLtb(_mmxdata *map,_mmxdata *imm,int n);
int _stdcall _mmxDotProduct(_mmxdata *v1,_mmxdata *v2,int n);

#pragma pack(pop)
