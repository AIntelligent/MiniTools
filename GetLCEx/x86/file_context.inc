;;
;; file_context.inc
;;
;; Author:
;;       Hakan E. Kartal <hek@nula.com.tr>
;;
;; Copyright (c) 2024 Hakan E. Kartal
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
IFNDEF __FILE_CONTEXT_INC__
__FILE_CONTEXT_INC__ equ <1>

.code 
	
;; ================================================
;;		FILE_CONTEXT
;; ================================================		

;;
;; void Init( PFILE_CONTEXT ioFileContext, LPCSTR inFileFullPathName )
;;
_FILE_CONTEXT@Init proc uses edi 					\
	@ioFileContext 		: PFILE_CONTEXT,			\
	@inFileFullPathName 	: LPCSTR
			mov 			edi, @ioFileContext
			assume 		edi : PFILE_CONTEXT
			invoke CreateFileA, @inFileFullPathName, GENERIC_READ, FILE_SHARE_READ, \
							NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL
			
			test 			eax, eax 
			jbe @ExitRoutine
			
			mov 			[ edi ].FileHandle, eax
			
			invoke GetFileSize, [ edi ].FileHandle, addr [ edi ].FileSize.HighPart
			mov 			DWORD ptr [ edi ].FileSize.LowPart, eax
			
			invoke InitializeCriticalSection, addr [ edi ].CriticalSection
			
			invoke _QUAD_INT@Init, addr [ edi ].FileOffset 
			
@ExitRoutine:
			
			assume 		edi : nothing
			ret 
			
_FILE_CONTEXT@Init endp

;;
;; BOOL GetBuffer( PFILE_CONTEXT inFileContext, LPVOID outBuffer, LPDWORD ioBufferLength )
;;
_FILE_CONTEXT@GetBuffer proc uses edi 				\
	@inFileContext  			: PFILE_CONTEXT, 		\
	@outBuffer		 			: LPVOID, 				\
	@ioBufferLength 			: LPDWORD
	
	LOCAL l_iReadLength 		: DWORD 
	LOCAL l_iReturnLength	: DWORD 
	LOCAL l_varFileSize		: QUAD_INT
	LOCAL l_bResult			: BOOL
	LOCAL l_varOffset			: QUAD_INT
	
			mov 			l_bResult, FALSE
			
			mov 			edi, @inFileContext
			assume 		edi : PFILE_CONTEXT
			
			invoke EnterCriticalSection, addr [ edi ].CriticalSection
			
			mov 			eax, @ioBufferLength
			mov 			eax, [ eax ]
			mov 			l_iReadLength, eax
			invoke _QUAD_INT@Clone, addr l_varFileSize, addr [ edi ].FileSize
			invoke _QUAD_INT@Sub, addr l_varFileSize, addr [ edi ].FileOffset
			or eax, edx
			jz @ExitRoutine
			
			cmp 			eax, l_iReadLength
			ja @F
			
			mov 			l_iReadLength, eax 
			
@@:
			mov 			l_iReturnLength, 0
			invoke ReadFile, [ edi ].FileHandle, @outBuffer, l_iReadLength, \
							addr l_iReturnLength, NULL
			test eax, eax 
			jz @ExitRoutine
	
;; ==================
;; 	Skip LF,CR
;; ==================
			mov 			ebx, @outBuffer 
			mov 			ecx, l_iReturnLength 
@@:
			mov 			al, [ ebx + ecx - 1 ]
			cmp al, LF 
			jz @F
			cmp al, CR 
			jnz @EndOf
@@:
			loop @B
			jmp @F
@EndOf:
			mov 			eax, l_iReturnLength
			sub 			eax, ecx 
			test eax, eax 
			jz @F
			mov 			l_iReturnLength, ecx 
			invoke _QUAD_INT@Clone, addr l_varOffset, addr [ edi ].FileOffset 
			invoke _QUAD_INT@AddInt, addr l_varOffset, l_iReturnLength
			lea 			ecx, l_varOffset
			invoke SetFilePointer, [ edi ].FileHandle, 	\
							[ ecx ].QUAD_INT.LowPart, 			\
							addr [ ecx ].QUAD_INT.HighPart, 	\
							FILE_BEGIN
@@:
;; ==================
			mov 			edx, @ioBufferLength
			mov 			eax, l_iReturnLength
			mov 			[ edx ], eax
			invoke _QUAD_INT@AddInt, addr [ edi ].FileOffset, eax
			
			mov 			l_bResult, TRUE
			
@ExitRoutine:
			
			invoke LeaveCriticalSection, addr [ edi ].CriticalSection	
			
			assume 		edi : nothing 
			
			mov 			eax, l_bResult
			ret
			
_FILE_CONTEXT@GetBuffer endp 

;;
;; void Done( PFILE_CONTEXT ioFileContext )
;;			
_FILE_CONTEXT@Done proc uses edi 					\
	@ioFileContext : PFILE_CONTEXT
			
			mov 			edi, @ioFileContext
			assume 		edi : PFILE_CONTEXT
			
			invoke CloseHandle, [ edi ].FileHandle
			
			assume 		edi : nothing
			ret 
			
_FILE_CONTEXT@Done endp

ENDIF
