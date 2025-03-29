;;
;; counter_context.inc
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
IFNDEF __COUNTER_CONTEXT_INC__
__COUNTER_CONTEXT_INC__ equ <1>

.code

;; ================================================
;;		COUNTER_CONTEXT
;; ================================================

;;
;; PCOUNTER_CONTEXT New( void )
;;
_COUNTER_CONTEXT@New proc
			invoke GetMemory, sizeof(COUNTER_CONTEXT)
			ret 
_COUNTER_CONTEXT@New endp 

;;
;; void Dispose( PCOUNTER_CONTEXT inCounterContext )
;;
_COUNTER_CONTEXT@Dispose proc @inCounterContext : PCOUNTER_CONTEXT
			invoke FreeMemory, @inCounterContext
			ret
_COUNTER_CONTEXT@Dispose endp 

;;
;; void @@AdjustMaximumThreadCount( PCOUNTER_CONTEXT ioCounterContext )
;;
@@__InternalUseOnly@@AdjustMaximumThreadCount proc uses edi	\
	@ioCounterContext : PCOUNTER_CONTEXT

			mov 			edi, @ioCounterContext
			assume 		edi : PCOUNTER_CONTEXT
			
			mov 			cl, MAXIMUM_THREAD_COUNT

			mov 			edx, [ edi ].File.FileSize.HighPart
			test edx, edx 
			jnz @ExitRoutine

			mov 			eax, [ edi ].File.FileSize.LowPart 

			and 			cl, 0
			
@@:

			inc 			cl 
			
			cmp cl, MAXIMUM_THREAD_COUNT
			jz @ExitRoutine
			
			cmp eax, MAXIMUM_THREAD_BLOCK_LENGTH 
			jb @ExitRoutine 
			
			sub 			eax, MAXIMUM_THREAD_BLOCK_LENGTH
			jnz @B
			
@ExitRoutine:
			
			mov 			[ edi ].ThreadCount, cl
			
			assume 		edi : nothing
			
			ret 
@@__InternalUseOnly@@AdjustMaximumThreadCount endp 
			
;;
;; void Init( PCOUNTER_CONTEXT ioCounterContext, LPCSTR inFileFullPathName )
;;
_COUNTER_CONTEXT@Init proc uses edi esi		\
	@ioCounterContext 	: PCOUNTER_CONTEXT,	\
	@inFileFullPathName 	: LPCSTR
	
	LOCAL l_dwThreadId 	: DWORD 
	LOCAL @ecx	 			: DWORD 
	
			mov 			edi, @ioCounterContext
			assume		edi : PCOUNTER_CONTEXT
	
			invoke InitializeCriticalSection, addr [ edi ].CriticalSection
			
			invoke _QUAD_INT@Init, addr [ edi ].Counter
			
			invoke lstrlenA, @inFileFullPathName
			inc 			eax 
			invoke GetMemory, eax 
			mov 			[ edi ].FileFullPathName, eax
			invoke lstrcpyA, eax, @inFileFullPathName
			
			invoke _FILE_CONTEXT@Init, addr [ edi ].File, eax
			
			mov 			[ edi ].MaximumBufferLength, MAXIMUM_BUFFER_LENGTH
			
			invoke @@__InternalUseOnly@@AdjustMaximumThreadCount, @ioCounterContext
			
			movzx 		ecx, [ edi ].ThreadCount
			lea 			edi, [ edi ].Threads
@@:
			mov 			@ecx, ecx 
			
			invoke CreateThread, NULL, 0, offset _COUNTER_CONTEXT@ThreadProc, \
							@ioCounterContext, CREATE_SUSPENDED, addr l_dwThreadId
			
			stosd
			
			mov 			ecx, @ecx 
			
			loop @B
			
			assume 		edi : nothing
			
			ret
			
_COUNTER_CONTEXT@Init endp	

;;
;; LRESULT ThreadProc( PCOUNTER_CONTEXT inCounterContext )
;;
_COUNTER_CONTEXT@ThreadProc proc uses edi 			\
	@inCounterContext 		: PCOUNTER_CONTEXT
	
	LOCAL l_iTotalLineCount : DWORD 
	LOCAL l_ptrBuffer 		: LPVOID
	LOCAL l_iBufferLength 	: DWORD
	
			mov 			edi, @inCounterContext
			assume 		edi : PCOUNTER_CONTEXT

			mov 			l_iTotalLineCount, 0
			
			invoke GetMemory, [ edi ].MaximumBufferLength
			mov 			l_ptrBuffer, eax
			
@@:
			mov 			eax, [ edi ].MaximumBufferLength
			mov 			l_iBufferLength, eax
			
			invoke _FILE_CONTEXT@GetBuffer, addr [ edi ].File, l_ptrBuffer, addr l_iBufferLength
			test eax, eax
			jz @ExitRoutine
			
			invoke GetLineCountInBuffer, l_ptrBuffer, l_iBufferLength
			
			add 			l_iTotalLineCount, eax
			
			jmp @B
			
@ExitRoutine:
			
			invoke _COUNTER_CONTEXT@Update, @inCounterContext, l_iTotalLineCount
			
			invoke FreeMemory, l_ptrBuffer
			
			xor 			eax, eax 
			ret
			
_COUNTER_CONTEXT@ThreadProc endp

;;
;; void Run( PCOUNTER_CONTEXT inCounter )
;;
_COUNTER_CONTEXT@Run proc uses edi				\
	@inCounterContext	: PCOUNTER_CONTEXT
	
	LOCAL @ecx : DWORD
	
			mov 			edi, @inCounterContext
			assume 		edi : PCOUNTER_CONTEXT
	
			call GetTickCount
			mov 			[ edi ].BeginTickCount, eax
			
			lea 			esi, [ edi ].Threads
			movzx			ecx, [ edi ].ThreadCount
			
@@:
			mov 			@ecx, ecx 
			
			lodsd
			
			invoke ResumeThread, eax 
			
			mov 			ecx, @ecx
			
			loop @B
			
			movzx 		ecx, [ edi ].ThreadCount
			invoke WaitForMultipleObjects, ecx, addr [ edi ].Threads, TRUE, INFINITE
							
			call GetTickCount
			mov 			[ edi ].EndTickCount, eax 
			
			assume		edi : nothing
			
			ret 
			
_COUNTER_CONTEXT@Run endp 

;;
;; __int64 Update( PCOUNTER_CONTEXT ioCounterContext, DWORD inStep )
;;
_COUNTER_CONTEXT@Update proc uses edi 			\
	@ioCounterContext : PCOUNTER_CONTEXT, 		\
	@inStep : DWORD
	
			mov 			edi, @ioCounterContext
			assume		edi : PCOUNTER_CONTEXT
			
			invoke EnterCriticalSection, addr [ edi ].CriticalSection
			
			mov 			eax, DWORD ptr [ edi ].Counter.LowPart
			mov 			edx, DWORD ptr [ edi ].Counter.HighPart
			add			eax, @inStep 
			adc 			edx, 0
			mov 			DWORD ptr [ edi ].Counter.LowPart, eax 
			mov 			DWORD ptr [ edi ].Counter.HighPart, edx
			
			invoke LeaveCriticalSection, addr [ edi ].CriticalSection
			
			assume 		edi : nothing 
			
			ret
			
_COUNTER_CONTEXT@Update endp

;;
;; void Report( PCOUNTER_CONTEXT inCounter, LPSTR outOutputString )
;;
_COUNTER_CONTEXT@Report proc uses edi 				\
	@inCounterContext 		: PCOUNTER_CONTEXT
	
	LOCAL l_iElapsedTime 	: DWORD
	LOCAL l_strReportString	: LPSTR 
	
.data 

g_strOutputStringFormat		CHAR 		"Report:",LF,CR,LF,CR
									CHAR 		TAB,"File full path name: '%s'",LF,CR
									CHAR 		TAB,"File size:           '%I64i bytes'",LF,CR
									CHAR 		LF,CR
									CHAR 		TAB,"Lines count:         '%I64i lines'",LF,CR
									CHAR 		TAB,"Elapsed time:        '%d ms'",LF,CR
									CHAR 		LF,CR
									CHAR 		TAB,"Thread count:        '%d threads'",LF,CR
									CHAR 		TAB,"Cache buffer length: '%d bytes'",LF,CR
									CHAR 		NULL

.code

			invoke GetMemory, 200h
			mov 			l_strReportString, eax 
			
			mov 			edi, @inCounterContext
			assume 		edi : PCOUNTER_CONTEXT
	
			mov 			eax, [ edi ].EndTickCount
			sub			eax, [ edi ].BeginTickCount
			mov 			l_iElapsedTime, eax
			
			movzx 		eax, [ edi ].ThreadCount
			
			invoke wsprintfA, l_strReportString, 					\
							offset g_strOutputStringFormat, 			\
							[ edi ].FileFullPathName, 					\
							[ edi ].File.FileSize.LowPart,			\
							[ edi ].File.FileSize.HighPart,			\
							[ edi ].Counter.LowPart,					\
							[ edi ].Counter.HighPart,					\
							l_iElapsedTime,								\
							eax,												\
							MAXIMUM_BUFFER_LENGTH
							
			invoke WriteLn, l_strReportString
			
			invoke FreeMemory, l_strReportString
							
			assume 		edi : nothing
			
			ret
			
_COUNTER_CONTEXT@Report endp
			
;;
;; void Done( PCOUNTER_CONTEXT inCounterContext )
;;
_COUNTER_CONTEXT@Done proc uses edi 				\
	@inCounterContext : PCOUNTER_CONTEXT
	
			mov 			edi, @inCounterContext
			assume		edi : PCOUNTER_CONTEXT
	
			invoke _COUNTER_CONTEXT@Report, @inCounterContext
			
			invoke _FILE_CONTEXT@Done, addr [ edi ].File
			
			invoke FreeMemory, [ edi ].FileFullPathName
			
			invoke DeleteCriticalSection, addr [ edi ].CriticalSection
			
			invoke _COUNTER_CONTEXT@Dispose, @inCounterContext
			
			assume		edi : nothing 
			
			ret
			
_COUNTER_CONTEXT@Done endp 

ENDIF
