;;
;; defs.inc
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
IFNDEF __DEFS_INC__
__DEFS_INC__ equ <1>

.const 

_COUNTER_CONTEXT@New 			PROTO
_COUNTER_CONTEXT@Dispose		PROTO :PCOUNTER_CONTEXT
_COUNTER_CONTEXT@Init			PROTO :PCOUNTER_CONTEXT, :LPCSTR
_COUNTER_CONTEXT@ThreadProc	PROTO :PCOUNTER_CONTEXT
_COUNTER_CONTEXT@Run				PROTO :PCOUNTER_CONTEXT
_COUNTER_CONTEXT@Update			PROTO :PCOUNTER_CONTEXT, :DWORD
_COUNTER_CONTEXT@Report			PROTO :PCOUNTER_CONTEXT
_COUNTER_CONTEXT@Done			PROTO :PCOUNTER_CONTEXT
		
_FILE_CONTEXT@Init				PROTO :PFILE_CONTEXT, :LPCTSTR
_FILE_CONTEXT@GetBuffer			PROTO :PFILE_CONTEXT, :LPVOID, :LPDWORD 
_FILE_CONTEXT@Done				PROTO :PFILE_CONTEXT

GetLineCountInBuffer 			PROTO :LPVOID, :DWORD
Write									PROTO :LPCSTR
WriteLn								PROTO :LPCSTR
GetMemory							PROTO :DWORD 
FreeMemory							PROTO :LPVOID
GetModuleName 						PROTO :LPSTR, :DWORD, :BOOL
WStrToAStr							PROTO :LPCTSTR, :LPSTR, :DWORD 
StrNew 								PROTO :LPCTSTR, :PDWORD

ENDIF
