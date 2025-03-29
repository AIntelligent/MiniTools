;;
;; getlcex.asm
;;
;; Author:
;;       Hakan E. Kartal <hek@nula.com.tr>
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
			.386

			.model		flat, stdcall
			
			option casemap:none
			
			include 		<prolog.inc>
			
.data 

g_strAbout							CHAR 					"GET LINE COUNT EXTREME (%s), Version 1.0",LF,CR,LF,CR
										CHAR 					"The example program was written by Kartal, Hakan Emre in 2024 using Intel x86 Assembly",LF,CR
										CHAR 					"https://github.com/AIntelligent, hek@nula.com.tr",LF,CR
g_strEOL								CHAR 					LF,CR,NULL

g_strHelp							CHAR 					"How does it work?",LF,CR,LF,CR
										CHAR 					TAB,"This example program quickly performs line counting on large text files using",LF,CR
										CHAR 					TAB,"multiple threads. The program automatically determinites the number of threads,",LF,CR
										CHAR 					TAB,"allowing the target file to be processed in blocks.",LF,CR,LF,CR
										CHAR 					"How to use:",LF,CR,LF,CR
										CHAR 					TAB,"%s -F[--file]:[file name] -H[--help]",LF,CR,LF,CR
										CHAR 					"Parameters:",LF,CR,LF,CR
										CHAR 					TAB,"-F[--file]: Target file full path name.",LF,CR,LF,CR 
										CHAR 					TAB,"-H[--help]: Show this content.",LF,CR,LF,CR,NULL

g_strTargetFileName				CHAR 					MAX_PATH dup (NULL)

g_strErrorFileNotFound			CHAR 					"ERROR: Target file '%s' not found!",LF,CR,NULL

g_strFileArgStringShort			CHAR 					"-F:",NULL
g_strFileArgString 				CHAR 					"--FILE:",NULL

g_strHelpArgStringShort			CHAR 					"-H",NULL 
g_strHelpArgString				CHAR 					"--HELP",NULL

.data?

g_hConsole							HANDLE 				?
g_strModuleName					LPSTR 				?

g_ptrArgList						LPVOID 				?
g_iArgCount 						BYTE 					?

.code 

;;
;; void About()
;;
About proc
	
	LOCAL l_strModuleFileName[ MAX_PATH + 1 ] : CHAR
	LOCAL l_ptrOutputString : LPSTR
	
			invoke GetMemory, DEFAULT_OUTPUT_STRING_LENGTH
			mov 			l_ptrOutputString, eax 
			
			invoke wsprintfA, l_ptrOutputString, offset g_strAbout, g_strModuleName

			invoke WriteLn, l_ptrOutputString

			invoke FreeMemory, l_ptrOutputString

			ret
About endp

;;
;; void Help( void )
;;
Help proc 
			
	LOCAL l_strOutputString 										: LPSTR 
	LOCAL l_strModuleName[ MAXIMUM_MODULE_NAME_LENGTH ]	: CHAR 
			
			invoke GetMemory, DEFAULT_OUTPUT_STRING_LENGTH
			mov 			l_strOutputString, eax 
			
			invoke GetModuleName, addr l_strModuleName, MAXIMUM_MODULE_NAME_LENGTH, TRUE 
			
			invoke wsprintfA, l_strOutputString, offset g_strHelp, addr l_strModuleName
			
			invoke Write, l_strOutputString
			
			invoke FreeMemory, l_strOutputString
			
			ret 
			
Help endp

;;
;; int GetLineCountInBuffer( LPVOID inBuffer, DWORD inBufferLength )
;;
GetLineCountInBuffer proc uses edi 					\
	@inBuffer 			: LPVOID, 						\
	@inBufferLength 	: DWORD 
				
			mov 			ecx, @inBuffer
			jecxz @ExitRoutine 
			
			mov 			ebx, ecx 
			
			mov 			ecx, @inBufferLength
			jecxz @ExitRoutine
			
			mov 			edx, ecx 
			
			and 			ecx, 0
			
@Search:

			mov 			ax, CRLF
			
			cmp [ ebx ], al 
			jz @EndOfFound
			
			mov 			ax, LFCR
			
			cmp [ ebx ], al 
			jz @EndOfFound 
			
@Next:

			inc 			ebx 
			
			dec 			edx 
			jz @ExitRoutine 
			
			jmp @Search 
			
@EndOfFound:

			inc 			ecx
			
			dec 			edx 
			jz @ExitRoutine
			
			inc 			ebx 
			
			cmp [ ebx ], ah
			jz @Next
			
			jmp @Search
			
@ExitRoutine:
			
			mov 			eax, ecx 
			
			ret
			
GetLineCountInBuffer endp

;;
;; void Write( LPCSTR inMessage )
;;
Write proc @inMessage : LPCSTR
	LOCAL l_dwReturnLength : DWORD
	
			invoke lstrlenA, @inMessage
			mov 			l_dwReturnLength, eax 

			invoke WriteConsole, g_hConsole, @inMessage, l_dwReturnLength, \
							addr l_dwReturnLength, NULL

			ret
			
Write endp 

;;
;; void WriteLn( LPCSTR inMessage )
;;
WriteLn proc @inMessage : LPCSTR 
			
			invoke Write, @inMessage
			invoke Write, addr g_strEOL
			
			ret
			
WriteLn endp

;;
;; LPVOID GetMemory( DWORD inRequiredLength )
;;
GetMemory proc @inRequiredLength : DWORD
			
			invoke LocalAlloc, LPTR, @inRequiredLength
			invoke LocalLock, eax 
			
			ret
			
GetMemory endp 

;;
;; void FreeMemory( LPVOID inMemoryAddress )
;;
FreeMemory proc @inMemoryAddress : LPVOID 
			
			invoke LocalUnlock, @inMemoryAddress
			invoke LocalFree, @inMemoryAddress
			
			ret
			
FreeMemory endp

;;
;; void GetModuleName( LPSTR outModuleName, int inMaximumLength, bool inIsExtensionRequired )
;;
GetModuleName proc 										\
	@outModuleName 			: LPSTR,					\
	@inMaximumLength			: DWORD,					\
	@inIsExtensionRequired 	: BOOL
	LOCAL l_arrModuleFileFullPathName[ MAX_PATH + 1 ] : CHAR 
			invoke GetModuleFileNameA, NULL, addr l_arrModuleFileFullPathName, MAX_PATH
			mov 			edx, eax 
			std 
			lea 			edi, l_arrModuleFileFullPathName
			lea 			edi, [ edi + eax ]
			mov 			ecx, eax 
			mov 			al, '\'
			repne scasb
			cld 
			jnz @ExitRoutine 
			inc 			ecx 
			inc 			edi
			neg 			ecx 
			add 			ecx, edx 
			mov 			eax, @inMaximumLength
			cmp ecx, eax 
			jbe @CopyString
			mov 			ecx, eax 
@CopyString:
			lea 			esi, [ edi + 1 ]
			mov 			edi, @outModuleName
			mov 			eax, @inIsExtensionRequired
			test al, al 
			jz @CopyStringWithoutExtension
			rep movsb 
			jmp @ExitRoutine 
@CopyStringWithoutExtension:
			lodsb 
			cmp al, '.'
			jnz @F
			xor 			al, al
@@:
			stosb
			test al, al 
			jnz @CopyStringWithoutExtension
@ExitRoutine:
			ret 
GetModuleName endp

;;
;; LPSTR WStrToAStr( LPCTSTR inWStr, LPSTR outAStr, DWORD inAStrLength )
;;
WStrToAStr proc uses edi esi 							\
	@inWStr 			: LPCTSTR,							\
	@outAStr 		: LPSTR,								\
	@inAStrLength 	: DWORD 
			mov 			esi, @inWStr
			mov 			edi, @outAStr 
			mov 			ecx, @inAStrLength
@ConvertAndCopy:
			lodsw 
			stosb
			test ax, ax 
			jz @ExitRoutine
			loop @ConvertAndCopy
@ExitRoutine:
			mov 			eax, @outAStr
			ret 
WStrToAStr endp 

;;
;; LPSTR StrNew( LPCTSTR inWStr, LPDWORD outLength )
;;
StrNew proc uses edi esi 								\
	@inWStr 		: LPCTSTR,								\
	@outLength 	: LPDWORD
	
	LOCAL l_ptrAStr : LPSTR 
	LOCAL l_iLength : DWORD 
	
			xor 			eax, eax 
			mov 			l_ptrAStr, eax 
			
			invoke lstrlenW, @inWStr
			mov 			l_iLength, eax
			
			mov 			ecx, @outLength
			jecxz @F			
			mov 			[ ecx ], eax
@@:	
			test eax, eax 
			jz @ExitRoutine
			
			inc 			eax
			
			invoke GetMemory, eax 
			mov 			l_ptrAStr, eax
			
			invoke WStrToAStr, @inWStr, l_ptrAStr, l_iLength
			invoke CharUpperA, eax
			
@ExitRoutine:

			mov 			eax, l_ptrAStr
			
			ret 
			
StrNew endp

;;
;; bool StrCmp( LPCSTR inLeft, LPCSTR inRight, DWORD inLength )
;;
StrCmp proc uses edi esi 								\
	@inLeft		: LPCSTR,								\
	@inRight		: LPCSTR,								\
	@inLength	: DWORD 
			mov 			esi, @inLeft 
			mov 			edi, @inRight
			mov 			ecx, @inLength 
			repz cmpsb
			ret
StrCmp endp 

ArgIsHelp proc @inArg : LPSTR
			invoke lstrlenA, offset g_strHelpArgString
			invoke StrCmp, @inArg, offset g_strHelpArgString, eax 
			jz @F
			invoke lstrlenA, offset g_strHelpArgStringShort
			invoke StrCmp, @inArg, offset g_strHelpArgStringShort, eax 
@@:
			setz 			al 
			movzx 		eax, al 
			ret 
ArgIsHelp endp 

ArgIsFile proc @inArg : LPSTR, @outCommandLength : PDWORD 
			invoke lstrlenA, offset g_strFileArgString
			mov 			ecx, @outCommandLength 
			jecxz @F 
			mov 			[ ecx ], eax 
@@:
			invoke StrCmp, @inArg, offset g_strFileArgString, eax 
			jz @ExitRoutine
			invoke lstrlenA, offset g_strFileArgStringShort
			mov 			ecx, @outCommandLength
			jecxz @F 
			mov 			[ ecx ], eax 
@@:
			invoke StrCmp, @inArg, offset g_strFileArgStringShort, eax 
@ExitRoutine:
			setz 			al 
			movzx 		eax, al 
			ret 
ArgIsFile endp 

ProcessArgs proc uses esi 								\

	LOCAL l_ptrArgW 						: LPTSTR
	LOCAL l_strArgA[ MAX_PATH + 1 ] 	: CHAR
	LOCAL l_iCommandLength				: DWORD 
	LOCAL l_iArgLength 					: DWORD 
	
			movzx 		eax, g_iArgCount
			dec 			eax 
			jz @DoArgIsHelp
	
			mov 			esi, g_ptrArgList
			
			lodsd ;; Skip argument 0.
			
@Do:
			lodsd
			
			test eax, eax 
			jz @DoArgIsHelp
			
			mov 			l_ptrArgW, eax 
			invoke lstrlenW, eax 
			mov 			l_iArgLength, eax 
			invoke WStrToAStr, l_ptrArgW, addr l_strArgA, MAX_PATH
			
			invoke CharUpperA, addr l_strArgA

			invoke ArgIsHelp, eax 
			test al, al
			jnz @DoArgIsHelp
			
			invoke ArgIsFile, addr l_strArgA, addr l_iCommandLength
			test al, al 
			jnz @DoArgIsFile 
			
			jmp @Do
			
@DoArgIsHelp:

			mov 			eax, ARG_IS_HELP
			ret 
			
@DoArgIsFile:

			invoke WStrToAStr, l_ptrArgW, addr l_strArgA, MAX_PATH
			
			lea 			eax, l_strArgA
			add 			eax, l_iCommandLength
			invoke lstrcpyA, offset g_strTargetFileName, eax

			mov 			eax, ARG_IS_FILE
			ret 
			
ProcessArgs endp 

;;
;; void Init( void )
;;
Init proc 

	LOCAL l_strModuleName[ MAXIMUM_MODULE_NAME_LENGTH ] : CHAR
	LOCAL l_iArgCount : DWORD 
	
			xor 			eax, eax 
			mov 			l_iArgCount, eax 
			lea 			eax, l_iArgCount
			push 			eax 
			call GetCommandLineW
			push 			eax 
			call CommandLineToArgvW
			mov 			g_ptrArgList, eax 
			mov 			eax, l_iArgCount
			mov 			g_iArgCount, al
	
			invoke GetStdHandle, STD_OUTPUT_HANDLE
			mov 			g_hConsole, eax
	
			invoke GetModuleName, addr l_strModuleName, MAXIMUM_MODULE_NAME_LENGTH, FALSE 
			invoke GetMemory, MAXIMUM_MODULE_NAME_LENGTH
			mov 			g_strModuleName, eax 
			invoke lstrcpyA, g_strModuleName, addr l_strModuleName
				
			ret
	
Init endp 

;;
;; void Run( void )
;;
Run proc 

	LOCAL	l_ptrCounterContext 	: PCOUNTER_CONTEXT
	
			invoke _COUNTER_CONTEXT@New
			mov 			l_ptrCounterContext, eax 
			
			invoke _COUNTER_CONTEXT@Init, l_ptrCounterContext, offset g_strTargetFileName
			
			invoke _COUNTER_CONTEXT@Run, l_ptrCounterContext

			invoke _COUNTER_CONTEXT@Done, l_ptrCounterContext

Run endp 

;;
;; void Done( void )
;;
Done proc 
			invoke LocalFree, g_ptrArgList
			invoke FreeMemory, g_strModuleName
			invoke ExitProcess, ERROR_SUCCESS			
Done endp

;;
;; void ErrorFileNotFound( void )
;;
ErrorFileNotFound proc 
	LOCAL l_strOutputString : LPSTR 
			invoke GetMemory, DEFAULT_OUTPUT_STRING_LENGTH
			mov			l_strOutputString, eax 
			
			invoke wsprintfA, l_strOutputString, offset g_strErrorFileNotFound, \
							offset g_strTargetFileName
			
			invoke Write, l_strOutputString
			
			invoke FreeMemory, l_strOutputString
			
			ret 
ErrorFileNotFound endp 

__Startup proc

			call Init

			call About
			
			call ProcessArgs
			cmp			eax, ARG_IS_HELP
			jz @ShowHelp
			cmp 			eax, ARG_IS_FILE
			jz @Run 
@@:			
			call Done
@ShowHelp:
			call Help
			jmp @B
@Run:
			invoke PathFileExistsA, offset g_strTargetFileName
			test al, al 
			jz @ShowErrorFileNotFound
			
			call Run 
			jmp @B
			
@ShowErrorFileNotFound:
			call ErrorFileNotFound
			jmp @B
			
__Startup endp

end __Startup
