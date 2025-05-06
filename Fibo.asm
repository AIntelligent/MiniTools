;;
;;	Fibonacci Calculator
;;	
;; Author:
;;			Kartal, Hakan Emre <hek@nula.com.tr>
;;
;;	Creation:
;;			2018.16.09
;;	
;;	Copyright (c) 2018-2025 by Kartal, Hakan Emre 
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
;; Requirements:
;; 
;; 		MS Windows XP or better
;; 		MASM32
;; 
;; Make It:
;; 
;; 		ml.exe /c /coff /W0 Fibo.asm 
;; 		link /MACHINE:X86 /NOLOGO /RELEASE /SUBSYSTEM:CONSOLE Fibo.obj /OUT:Fibo.exe
;; 		
;; Output:
;;
;; .\fibo.exe
;;        0
;;        1
;;        1
;;        2
;;        3
;;        5
;;        8
;;       13
;;       21
;;       34
;;       55
;;       89
;;      144
;;      233
;;      377
;;      610
;;      987
;;     1597
;;     2584
;;     4181
;;     6765
;;    10946
;;    17711
;;    28657
;;    46368
;;    75025
;;   121393
;;   196418
;;   317811
;;   514229
;;   832040
;;  1346269
;;  2178309
;;  3524578
;;  5702887
;;  9227465
;; 14930352
;; 24157817
;; 39088169
;; 63245986
;;
;;Press Enter or Escape to exit...

MAX_FIBOTEST					equ		(40)


				.386
				
				.model			flat, stdcall
				
				option			casemap  : none
				
	include		<\Masm32\Include\Windows.inc>
	include		<\Masm32\Include\Kernel32.inc>
	include		<\Masm32\Include\User32.inc>

	includelib	<\Masm32\Lib\Kernel32.lib>
	includelib	<\Masm32\Lib\User32.lib>

.data?
	
g_hOutput					HANDLE			?
g_hInput						HANDLE			?
g_refEventList				INPUT_RECORD	128 dup (<?>)


.data
	
g_lpcbOutput				CHAR		9 dup (0), 0, 0, 0, 0
g_lpcbFormat				CHAR		"%9d",0
g_lpcbPressMsg				CHAR		0Dh,0Ah,"Press Enter or Escape to exit...",0
	
.code

Fibonacci					proto	:DWORD
FiboTest						proto	:DWORD
_putI							proto	:DWORD
_putS							proto	:PCHAR

WaitTerminator				proto
	
; ==============================================================================
;	long __stdcall Fibonacci( long _inBase )
; ==============================================================================
Fibonacci					proc	_inBase

			mov			eax, _inBase
			
			cmp			eax, 2
			jb		@exit_f
			
			dec			eax
			push		eax

			dec			eax
			push		eax
			
			call	Fibonacci
			mov			_inBase, eax
			
			call	Fibonacci
			add			eax, _inBase

@exit_f:

			ret

Fibonacci					endp

; ==============================================================================
;	void _putI( long _inValue )
; ==============================================================================
_putI						proc	_inValue : DWORD
	
	local	l_dwWritten : DWORD
	
			invoke	wsprintf, addr g_lpcbOutput, addr g_lpcbFormat, _inValue

			lea			edi, g_lpcbOutput
			mov			dword ptr [ edi + eax ], 0D0Ah

			invoke	_putS, addr g_lpcbOutput

			ret
			
_putI						endp

; ==============================================================================
;	void _putS( char *_inString )
; ==============================================================================
_putS						proc	_inString : PCHAR

	local	l_dwWritten : DWORD

			invoke	lstrlen, _inString
			
			mov			ecx, eax
			
			invoke	WriteConsole, g_hOutput, _inString, ecx, addr l_dwWritten, NULL
			
			ret

_putS						endp

; ==============================================================================
;	void FiboTest( long _inCount )
; ==============================================================================
FiboTest					proc	_inCount : DWORD
			
			and			ebx, 0
			
@Run:
			
			invoke	Fibonacci, ebx
			invoke	_putI, eax
			
			inc			ebx
			
			cmp			ebx, _inCount
			jb		@Run
			
@exit_f:
			
			ret
			
FiboTest					endp

; ==============================================================================
;	void WaitTerminator( void )
; ==============================================================================
WaitTerminator				proc

	local	l_dwEventCount : DWORD
	
			invoke	lstrlen, addr g_lpcbPressMsg
			mov			edx, eax
			invoke	WriteConsole, g_hOutput, addr g_lpcbPressMsg, edx, addr l_dwEventCount, NULL
	
@Run:

			and			l_dwEventCount, 0

			invoke	ReadConsoleInput, g_hInput, addr g_refEventList, 128, addr l_dwEventCount
			test		eax, eax
			jz		@Run

			lea			edi, g_refEventList

@Query:

			dec			l_dwEventCount
			js		@Run

			cmp			[ edi ].INPUT_RECORD.EventType, KEY_EVENT
			jne		@NextEvent
			
			cmp			[ edi ].INPUT_RECORD.KeyEvent.wVirtualKeyCode, VK_RETURN
			je		@exit_f
			
			cmp			[ edi ].INPUT_RECORD.KeyEvent.wVirtualKeyCode, VK_ESCAPE
			je		@exit_f
			
@NextEvent:
			
			add			edi, sizeof( INPUT_RECORD )
			jmp		@Query

@exit_f:

			ret
			
WaitTerminator				endp

; ==============================================================================
;	void @startup( void )
; ==============================================================================
@startup					proc

			push $+5
			pop eax

			invoke	AllocConsole

			invoke	GetStdHandle, STD_OUTPUT_HANDLE
			mov			g_hOutput, eax

			invoke	GetStdHandle, STD_INPUT_HANDLE
			mov			g_hInput, eax
			


			invoke	FiboTest, MAX_FIBOTEST



			invoke	WaitTerminator
			
			invoke	FreeConsole
			
			invoke	ExitProcess, ERROR_SUCCESS
			
@startup					endp

	end			@startup