;;
;; types.inc 
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
IFNDEF __TYPES_INC__
__TYPES_INC__ equ <1>

;; ================================================
;;		QUAD_INT 
;; ================================================
_QUAD_INT 							union
	QuadPart							QWORD 				?
	struct
		LowPart						DWORD					?
		HighPart						DWORD 				?
	ends
_QUAD_INT							ends

QUAD_INT								typedef 				_QUAD_INT
PQUAD_INT							typedef ptr 		_QUAD_INT

;; ================================================
;;		FILE_CONTEXT
;; ================================================		
_FILE_CONTEXT						struct
	FileHandle 						HANDLE 				?
	CriticalSection				CRITICAL_SECTION	<>
	FileSize							QUAD_INT				<>
	FileOffset						QUAD_INT				<>
_FILE_CONTEXT						ends 

FILE_CONTEXT						typedef 				_FILE_CONTEXT
PFILE_CONTEXT						typedef ptr 		_FILE_CONTEXT
	
;; ================================================
;;		COUNTER_CONTEXT 
;; ================================================
_COUNTER_CONTEXT 					struct
	CriticalSection				CRITICAL_SECTION	<>
	Counter 							QUAD_INT				<>
	FileFullPathName				LPSTR					?
	File								FILE_CONTEXT		<>
	ThreadCount						BYTE 					?
	Threads							HANDLE 				MAXIMUM_THREAD_COUNT dup (?)
	MaximumBufferLength			DWORD 				?
	BeginTickCount					DWORD 				?
	EndTickCount					DWORD 				?
_COUNTER_CONTEXT					ends 

COUNTER_CONTEXT					typedef				_COUNTER_CONTEXT
PCOUNTER_CONTEXT 					typedef ptr 		_COUNTER_CONTEXT

ENDIF