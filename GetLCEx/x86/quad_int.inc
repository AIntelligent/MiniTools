;;
;; quad_int.inc
;;
;; Author:
;;       Kartal, Hakan Emre <hek@nula.com.tr>
;;
;; Copyright (c) 2024 Kartal, Hakan Emre
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.
;; 
IFNDEF __QUAD_INT_INC__
__QUAD_INT_INC__ equ <1>

.code 

;;
;; void Init( PQUAD_INT ioQuadInt )
;,
_QUAD_INT@Init proc uses edi 							\
	@ioQuadInt	: PQUAD_INT
			mov 			edi, @ioQuadInt
			assume 		edi : PQUAD_INT
			xor 			eax, eax 
			mov 			[ edi ].LowPart, eax 
			mov 			[ edi ].HighPart, eax 
			assume 		edi : nothing
			ret 
_QUAD_INT@Init endp 

;;
;; __int64 Add( PQUAD_INT ioLeft, const PQUAD_INT inRight )
;;
_QUAD_INT@Add proc uses edi esi						\
	@ioLeft 	: PQUAD_INT,								\
	@inRight : PQUAD_INT
			mov 			edi, @ioLeft
			mov 			esi, @inRight
			assume		edi : PQUAD_INT
			assume 		esi : PQUAD_INT
			mov 			eax, [ edi ].LowPart
			mov 			edx, [ edi ].HighPart
			add 			eax, [ esi ].LowPart
			adc 			edx, [ esi ].HighPart
			mov 			[ edi ].LowPart, eax 
			mov 			[ edi ].HighPart, edx 
			assume 		esi : nothing
			assume 		edi : nothing 
			ret 
_QUAD_INT@Add endp 

;;
;; long long Add( PQUAD_INT ioLeft, const DWORD inIntValue )
;;
_QUAD_INT@AddInt proc uses edi 						\
	@ioQuadInt 	: PQUAD_INT,							\
	@inIntValue	: DWORD 
			mov 			edi, @ioQuadInt
			assume 		edi :PQUAD_INT
			mov 			eax, [ edi ].LowPart
			mov 			edx, [ edi ].HighPart
			add 			eax, @inIntValue
			adc 			edx, 0
			mov 			[ edi ].LowPart, eax 
			mov 			[ edi ].HighPart, edx 
			assume 		edi : nothing
			ret
_QUAD_INT@AddInt endp 

;;			
;; __int64 Sub( PQUAD_INT ioLeft, const PQUAD_INT inRight )
;;
_QUAD_INT@Sub proc uses edi esi 						\
	@ioLeft 	: PQUAD_INT,								\
	@ioRight	: PQUAD_INT									
			mov 			edi, @ioLeft
			mov 			esi, @ioRight
			assume 		edi : PQUAD_INT
			assume 		esi : PQUAD_INT
			mov 			eax, [ edi ].LowPart
			mov 			edx, [ edi ].HighPart
			sub			eax, [ esi ].LowPart
			sbb			edx, [ esi ].HighPart
			mov 			[ edi ].LowPart, eax 
			mov 			[ esi ].HighPart, edx 
			assume 		esi : nothing
			assume 		edi : nothing
			ret 
_QUAD_INT@Sub endp 

;;
;; int SubInt( PQUAD_INT ioLeft, const DWORD inIntValue )
;;
_QUAD_INT@SubInt proc uses edi						\
	@ioLeft		: PQUAD_INT,							\
	@inIntValue	: DWORD 
			mov 			edi, @ioLeft
			assume 		edi : PQUAD_INT
			mov 			eax, [ edi ].LowPart
			mov 			edx, [ edi ].HighPart
			sub 			eax, @inIntValue
			sbb			edx, 0
			assume 		edi : nothing
			ret 
_QUAD_INT@SubInt endp

;;
;; __int64 Clone( PQUAD_INT ioLeft, const PQUAD_INT inReference )
;;
_QUAD_INT@Clone proc uses edi esi 					\
	@ioLeft 			: PQUAD_INT,						\
	@inReference	: PQUAD_INT
			mov 			edi, @ioLeft
			mov 			esi, @inReference
			assume 		edi : PQUAD_INT
			assume 		esi : PQUAD_INT
			mov 			eax, [ esi ].LowPart
			mov 			edx, [ esi ].HighPart
			mov 			[ edi ].LowPart, eax 
			mov 			[ edi ].HighPart, edx 
			assume 		esi : nothing
			assume 		edi : nothing
			ret
_QUAD_INT@Clone endp

;;
;; __int64 Abs( PQUAD_INT ioQuadInt, PBOOL outIsNegative )
;;
_QUAD_INT@Abs proc uses edi 							\
	@ioQuadInt : PQUAD_INT,								\
	@outIsNegative : PBOOL
			mov 			edi, @ioQuadInt
			assume 		edi : PQUAD_INT
			mov 			ebx, @outIsNegative
			mov 			BOOL ptr [ ebx ], FALSE
			mov 			eax, [ edi ].LowPart
			mov 			edx, [ edi ].HighPart
			test edx, edx 
			jnl @F
			mov 			BOOL ptr [ ebx ], TRUE
			neg 			eax
			adc 			edx, 0
			neg 			edx
			mov 			[ edi ].LowPart, eax 
			mov 			[ edi ].HighPart, edx 
@@:
			assume 		edi : PQUAD_INT
			ret
_QUAD_INT@Abs endp

ENDIF
