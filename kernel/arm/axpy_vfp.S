/***************************************************************************
Copyright (c) 2013, The OpenBLAS Project
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:
1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in
the documentation and/or other materials provided with the
distribution.
3. Neither the name of the OpenBLAS project nor the names of
its contributors may be used to endorse or promote products
derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE OPENBLAS PROJECT OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*****************************************************************************/

/**************************************************************************************
* 2013/11/14 Saar
* 	 BLASTEST 		: xOK
* 	 CTEST			: xOK
* 	 TEST			: xOK
*
**************************************************************************************/

#define ASSEMBLER
#include "common.h"

#define STACKSIZE 256

#define	OLD_INC_X	[fp, #0 ]
#define	OLD_Y		[fp, #4 ]
#define	OLD_INC_Y	[fp, #8 ]


#define	N	r0
#define Y	r1
#define	INC_X	r2
#define	X	r3
#define INC_Y	r4

#define I	r12

#define X_PRE	512

/**************************************************************************************
* Macro definitions
**************************************************************************************/

/*****************************************************************************************/

#if !defined(CONJ)

#if defined(DOUBLE)

#define	FMAC_R1	fmacd
#define FMAC_R2 fnmacd
#define	FMAC_I1	fmacd
#define FMAC_I2 fmacd

#else

#define	FMAC_R1	fmacs
#define FMAC_R2 fnmacs
#define	FMAC_I1	fmacs
#define FMAC_I2 fmacs

#endif

#else	// CONJ

#if defined(DOUBLE)

#define	FMAC_R1	fmacd
#define FMAC_R2 fmacd
#define	FMAC_I1	fnmacd
#define FMAC_I2 fmacd

#else

#define	FMAC_R1	fmacs
#define FMAC_R2 fmacs
#define	FMAC_I1	fnmacs
#define FMAC_I2 fmacs

#endif

#endif


#if	!defined(COMPLEX)

#if	defined(DOUBLE)

.macro KERNEL_F4

	pld	[ X, #X_PRE ]
	fldmiad		X!,  { d4 - d7  }
	pld	[ Y, #X_PRE ]
	fldmiad		Y ,  { d8 - d11 }
	fmacd   	d8 , d0, d4
	fstmiad		Y!, { d8 }
	fmacd   	d9 , d0, d5
	fstmiad		Y!, { d9 }
	fmacd   	d10, d0, d6
	fstmiad		Y!, { d10 }
	fmacd   	d11, d0, d7
	fstmiad		Y!, { d11 }


.endm


.macro KERNEL_F1

	fldmiad		X!,  { d4 }
	fldmiad		Y ,  { d8 }
	fmacd   	d8 , d0, d4
	fstmiad		Y!, { d8 }

.endm

.macro KERNEL_S1

	fldmiad		X ,  { d4 }
	fldmiad		Y ,  { d8 }
	fmacd   	d8 , d0, d4
	fstmiad		Y , { d8 }
	add	X, X, INC_X
	add	Y, Y, INC_Y

.endm

#else

.macro KERNEL_F4

	fldmias		X!,  { s4 - s7  }
	fldmias		Y ,  { s8 - s11 }
	fmacs   	s8 , s0, s4
	fstmias		Y!, { s8 }
	fmacs   	s9 , s0, s5
	fstmias		Y!, { s9 }
	fmacs   	s10, s0, s6
	fstmias		Y!, { s10 }
	fmacs   	s11, s0, s7
	fstmias		Y!, { s11 }


.endm


.macro KERNEL_F1

	fldmias		X!,  { s4 }
	fldmias		Y ,  { s8 }
	fmacs   	s8 , s0, s4
	fstmias		Y!, { s8 }

.endm

.macro KERNEL_S1

	fldmias		X ,  { s4 }
	fldmias		Y ,  { s8 }
	fmacs   	s8 , s0, s4
	fstmias		Y , { s8 }
	add	X, X, INC_X
	add	Y, Y, INC_Y

.endm


#endif

#else

#if	defined(DOUBLE)

.macro KERNEL_F4

	pld	[ X, #X_PRE ]
	fldmiad		X!,  { d4 - d7  }
	pld	[ Y, #X_PRE ]
	fldmiad		Y ,  { d8 - d11 }

	FMAC_R1		d8 , d0, d4
	FMAC_R2		d8 , d1, d5
	FMAC_I1		d9 , d0, d5
	FMAC_I2		d9 , d1, d4
	fstmiad		Y!, { d8 }
	fstmiad		Y!, { d9 }

	FMAC_R1		d10, d0, d6
	FMAC_R2		d10, d1, d7
	FMAC_I1		d11, d0, d7
	FMAC_I2		d11, d1, d6
	fstmiad		Y!, { d10 }
	fstmiad		Y!, { d11 }

	pld	[ X, #X_PRE ]
	fldmiad		X!,  { d4 - d7  }
	pld	[ Y, #X_PRE ]
	fldmiad		Y ,  { d8 - d11 }

	FMAC_R1		d8 , d0, d4
	FMAC_R2		d8 , d1, d5
	FMAC_I1		d9 , d0, d5
	FMAC_I2		d9 , d1, d4
	fstmiad		Y!, { d8 }
	fstmiad		Y!, { d9 }

	FMAC_R1		d10, d0, d6
	FMAC_R2		d10, d1, d7
	FMAC_I1		d11, d0, d7
	FMAC_I2		d11, d1, d6
	fstmiad		Y!, { d10 }
	fstmiad		Y!, { d11 }





.endm


.macro KERNEL_F1

	fldmiad		X!,  { d4 - d5  }
	fldmiad		Y ,  { d8 - d9 }

	FMAC_R1		d8 , d0, d4
	FMAC_R2		d8 , d1, d5
	FMAC_I1		d9 , d0, d5
	FMAC_I2		d9 , d1, d4
	fstmiad		Y!, { d8 }
	fstmiad		Y!, { d9 }



.endm

.macro KERNEL_S1

	fldmiad		X ,  { d4 - d5 }
	fldmiad		Y ,  { d8 - d9 }

	FMAC_R1		d8 , d0, d4
	FMAC_R2		d8 , d1, d5
	FMAC_I1		d9 , d0, d5
	FMAC_I2		d9 , d1, d4
	fstmiad		Y  , { d8 - d9 }

	add	X, X, INC_X
	add	Y, Y, INC_Y

.endm



#else

.macro KERNEL_F4

	pld	[ X, #X_PRE ]
	fldmias		X!,  { s4 - s7  }
	pld	[ Y, #X_PRE ]
	fldmias		Y ,  { s8 - s11 }

	FMAC_R1		s8 , s0, s4
	FMAC_R2		s8 , s1, s5
	FMAC_I1		s9 , s0, s5
	FMAC_I2		s9 , s1, s4
	fstmias		Y!, { s8 }
	fstmias		Y!, { s9 }

	FMAC_R1		s10, s0, s6
	FMAC_R2		s10, s1, s7
	FMAC_I1		s11, s0, s7
	FMAC_I2		s11, s1, s6
	fstmias		Y!, { s10 }
	fstmias		Y!, { s11 }

	fldmias		X!,  { s4 - s7  }
	fldmias		Y ,  { s8 - s11 }

	FMAC_R1		s8 , s0, s4
	FMAC_R2		s8 , s1, s5
	FMAC_I1		s9 , s0, s5
	FMAC_I2		s9 , s1, s4
	fstmias		Y!, { s8 }
	fstmias		Y!, { s9 }

	FMAC_R1		s10, s0, s6
	FMAC_R2		s10, s1, s7
	FMAC_I1		s11, s0, s7
	FMAC_I2		s11, s1, s6
	fstmias		Y!, { s10 }
	fstmias		Y!, { s11 }





.endm


.macro KERNEL_F1

	fldmias		X!,  { s4 - s5  }
	fldmias		Y ,  { s8 - s9 }

	FMAC_R1		s8 , s0, s4
	FMAC_R2		s8 , s1, s5
	FMAC_I1		s9 , s0, s5
	FMAC_I2		s9 , s1, s4
	fstmias		Y!, { s8 }
	fstmias		Y!, { s9 }



.endm

.macro KERNEL_S1

	fldmias		X ,  { s4 - s5 }
	fldmias		Y ,  { s8 - s9 }

	FMAC_R1		s8 , s0, s4
	FMAC_R2		s8 , s1, s5
	FMAC_I1		s9 , s0, s5
	FMAC_I2		s9 , s1, s4
	fstmias		Y  , { s8 - s9 }

	add	X, X, INC_X
	add	Y, Y, INC_Y

.endm


#endif

#endif

/**************************************************************************************
* End of macro definitions
**************************************************************************************/

	PROLOGUE

	.align 5
	push    {r4 , fp}
        add     fp, sp, #8
	sub     sp, sp, #STACKSIZE                              // reserve stack

	ldr    INC_X , OLD_INC_X
	ldr         Y, OLD_Y
	ldr    INC_Y , OLD_INC_Y

	sub     r12, fp, #128

#if	defined(DOUBLE)
        vstm    r12, { d8 - d15}                                 // store floating point registers
#else
        vstm    r12, { s8 - s15}                                 // store floating point registers
#endif

	cmp	N, #0
	ble	axpy_kernel_L999

	cmp	INC_X, #0
	beq	axpy_kernel_L999

	cmp	INC_Y, #0
	beq	axpy_kernel_L999

	cmp	INC_X, #1
	bne	axpy_kernel_S_BEGIN

	cmp	INC_Y, #1
	bne	axpy_kernel_S_BEGIN


axpy_kernel_F_BEGIN:


	asrs	I, N, #2					// I = N / 4
	ble	axpy_kernel_F1

	.align 5

axpy_kernel_F4:

#if !defined(COMPLEX) && !defined(DOUBLE)
	pld	[ X, #X_PRE ]
	pld	[ Y, #X_PRE ]
#endif

	KERNEL_F4

	subs	I, I, #1
	ble	axpy_kernel_F1

	KERNEL_F4

	subs	I, I, #1
	bne	axpy_kernel_F4

axpy_kernel_F1:

	ands	I, N, #3
	ble	axpy_kernel_L999

axpy_kernel_F10:

	KERNEL_F1

	subs    I, I, #1
        bne     axpy_kernel_F10

	b	axpy_kernel_L999

axpy_kernel_S_BEGIN:

#if defined(COMPLEX)

#if defined(DOUBLE)
	lsl	INC_X, INC_X, #4				// INC_X * SIZE * 2
	lsl	INC_Y, INC_Y, #4				// INC_Y * SIZE * 2
#else
	lsl	INC_X, INC_X, #3				// INC_X * SIZE * 2
	lsl	INC_Y, INC_Y, #3				// INC_Y * SIZE * 2
#endif

#else

#if defined(DOUBLE)
	lsl	INC_X, INC_X, #3				// INC_X * SIZE
	lsl	INC_Y, INC_Y, #3				// INC_Y * SIZE
#else
	lsl	INC_X, INC_X, #2				// INC_X * SIZE
	lsl	INC_Y, INC_Y, #2				// INC_Y * SIZE
#endif

#endif


	asrs	I, N, #2					// I = N / 4
	ble	axpy_kernel_S1

	.align 5

axpy_kernel_S4:

	KERNEL_S1
	KERNEL_S1
	KERNEL_S1
	KERNEL_S1

	subs	I, I, #1
	bne	axpy_kernel_S4

axpy_kernel_S1:

	ands	I, N, #3
	ble	axpy_kernel_L999

axpy_kernel_S10:

	KERNEL_S1

	subs    I, I, #1
        bne     axpy_kernel_S10


axpy_kernel_L999:

	sub     r3, fp, #128

#if	defined(DOUBLE)
        vldm    r3, { d8 - d15 }                                 // restore floating point registers
#else
        vldm    r3, { s8 - s15 }                                 // restore floating point registers
#endif

	mov	r0, #0		// set return value

	sub     sp, fp, #8
	pop     {r4,fp}
	bx	lr

	EPILOGUE

