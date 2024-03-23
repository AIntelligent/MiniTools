;;
;; GetDevInfo.asm
;;
;; Author:
;;       Hakan Emre Kartal <hek@nula.com.tr>
;;
;; Copyright (c) 2024 Hakan Emre Kartal
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
;; 		MS Windows XP64 or better
;; 		MASM64
;; 
;; Make It:
;; 
;; 		ml64.exe /c GetDevInfo.asm 
;; 		link /SUBSYSTEM:CONSOLE /ENTRY:__Startup /nologo /LARGEADDRESSAWARE GetDevInfo.obj
;; 		
;; Output:
;; 
;; 		GET DEVICE DRIVER HARDWARE INFO (GetDevInfo), Version 1.0
;; 
;; 		The example program was written by Hakan Emre Kartal in 2024 using Intel x64 Assembly
;; 		https://github.com/AIntelligent, hek@nula.com.tr
;; 
;; 				  Logical Drive:      'C:'
;; 				  Vendor Id:          'NULL'
;; 				  Product Id:         'SanDisk SDSSDP256G'
;; 				  Product Revision:   '2.0.0'
;; 				  Serial Number:      '142630631408'
;; 				  Is Removable Media: 'FALSE'
;; 
;; 				  Logical Drive:      'D:'
;; 				  Vendor Id:          'NULL'
;; 				  Product Id:         'SanDisk SSD i100 24GB'
;; 				  Product Revision:   '11.50.02'
;; 				  Serial Number:      '120048112525'
;; 				  Is Removable Media: 'FALSE'
;; 
;; 				  Logical Drive:      'E:'
;; 				  Vendor Id:          'Kingston'
;; 				  Product Id:         'DataTraveler 2.0'
;; 				  Product Revision:   '1.00'
;; 				  Serial Number:      '0034D1CC0EC1A6962A9C150C'
;; 				  Is Removable Media: 'TRUE'
;; 
;; 				  Logical Drive:      'F:'
;; 				  Vendor Id:          'USB'
;; 				  Product Id:         'Sandisk 3.2Gen1'
;; 				  Product Revision:   '1.00'
;; 				  Serial Number:      '1bfe01028441c112538c'
;; 				  Is Removable Media: 'TRUE'
;; 				  

			include 		..\include64\masm64rt.inc			
			
IFNULL MACRO inString
	lea 			rax, inString 
	cmp word ptr [ rax ], NULL
	jnz @F
	lea 			rax, g_strNull
@@:
	EXITM<rax>
ENDM

BOOLTOSTR MACRO inCondition
	lea 			rax, g_strFalse
	cmp inCondition, FALSE
	jz @F
	lea 			rax, g_strTrue
@@:
	EXITM<rax>
ENDM
		
STORAGE_DEVICE_DESCRIPTOR_LENGTH 	equ	(1024)
IOCTL_STORAGE_QUERY_PROPERTY			equ	(0002D1400h)

DEVICE_INFO_STRING_LENGTH				equ	(32)

LF 											equ 	(0Ah)
CR 											equ 	(0Dh)
TAB 											equ 	(09h)

_STORAGE_PROPERTY_QUERY			struct
	PropertyId						DWORD		?
	QueryType						DWORD		?
	AdditionalParameters			CHAR		4 dup (?)
_STORAGE_PROPERTY_QUERY			ends
	
STORAGE_PROPERTY_QUERY			typedef	_STORAGE_PROPERTY_QUERY
PSTORAGE_PROPERTY_QUERY			typedef	ptr _STORAGE_PROPERTY_QUERY
	
_STORAGE_DEVICE_DESCRIPTOR		struct
	Version							ULONG		?
	@Size								ULONG		?
	DeviceType						UCHAR		?
	DeviceTypeModifier			UCHAR 	?
	RemovableMedia					BOOLEAN	?
	CommandQueueing				BOOLEAN	?
	VendorIdOffset					ULONG 	?
	ProductIdOffset				ULONG 	?
	ProductRevisionOffset		ULONG 	?
	SerialNumberOffset			ULONG 	?
	StorageBusType					DWORD 	?
	RawPropertiesLength			ULONG 	?
	RawDeviceProperties			UCHAR 	0 dup (?)
_STORAGE_DEVICE_DESCRIPTOR		ends
	
STORAGE_DEVICE_DESCRIPTOR 		typedef 	_STORAGE_DEVICE_DESCRIPTOR
PSTORAGE_DEVICE_DESCRIPTOR		typedef 	ptr _STORAGE_DEVICE_DESCRIPTOR

_DEVICE_INFO						struct 	sizeof(QWORD)
	VendorId 						CHAR  	DEVICE_INFO_STRING_LENGTH dup (?)
	ProductId						CHAR		DEVICE_INFO_STRING_LENGTH dup (?)
	ProductRevision				CHAR 		DEVICE_INFO_STRING_LENGTH dup (?)
	SerialNumber 					CHAR 		DEVICE_INFO_STRING_LENGTH dup (?)
	IsRemovableMedia				BOOLEAN 	?
_DEVICE_INFO						ends 
	
DEVICE_INFO							typedef 	_DEVICE_INFO
PDEVICE_INFO						typedef 	ptr _DEVICE_INFO

TCHAR 								equ		<WCHAR>
		
.data

g_strDevicePath					TCHAR	 		'\','\','.','\'
g_cbDriveLetter					TCHAR			'?',':',NULL
									
g_strTrue							TCHAR 		'T','R','U','E',0
g_strFalse 							TCHAR 		'F','A','L','S','E',0

g_strNull 							TCHAR 		'N','U','L','L',0

g_strAbout							TCHAR  		'G','E','T',' ','D','E','V','I','C','E',' ','D','R','I','V','E','R',' '
										TCHAR			'H','A','R','D','W','A','R','E',' ','I','N','F','O',' ','(','%','w','s'
										TCHAR			')',',',' ','V','e','r','s','i','o','n',' ','1','.','0',LF,CR,LF,CR
										TCHAR			'T','h','e',' ','e','x','a','m','p','l','e',' ','p','r','o','g','r','a'
										TCHAR 		'm',' ','w','a','s',' ','w','r','i','t','t','e','n',' ','b','y',' ','H'
										TCHAR			'a','k','a','n',' ','E','m','r','e',' ','K','a','r','t','a','l',' ','i',
										TCHAR 		'n',' ','2','0','2','4',' ','u','s','i','n','g',' ','I','n','t','e','l',
										TCHAR 		' ','x','6','4',' ','A','s','s','e','m','b','l','y',LF,CR
										TCHAR 		'h','t','t','p','s',':','/','/','g','i','t','h','u','b','.','c','o','m'
										TCHAR			'/','A','I','n','t','e','l','l','i','g','e','n','t',',',' ','h','e','k'
										TCHAR			'@','n','u','l','a','.','c','o','m','.','t','r',LF,CR,LF,CR,NULL
g_strReport 						TCHAR 		TAB,'D','r','i','v','e',':',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '
										TCHAR			' ',' ',' ',39,'%','w','s',39,LF,CR	
										TCHAR 		TAB,'V','e','n','d','o','r',' ','I','d',':',' ',' ',' ',' ',' ',' ',' '
										TCHAR			' ',' ',' ',39,'%','w','s',39,LF,CR
										TCHAR 		TAB,'P','r','o','d','u','c','t',' ','I','d',':',' ',' ',' ',' ',' ',' '
										TCHAR 		' ',' ',' ',39,'%','w','s',39,LF,CR
										TCHAR 		TAB,'P','r','o','d','u','c','t',' ','R','e','v','i','s','i','o','n',':'
										TCHAR 		' ',' ',' ',39,'%','w','s',39,LF,CR
										TCHAR 		TAB,'S','e','r','i','a','l',' ','N','u','m','b','e','r',':',' ',' ',' '
										TCHAR 		' ',' ',' ',39,'%','w','s',39,LF,CR
										TCHAR 		TAB,'I','s',' ','R','e','m','o','v','a','b','l','e',' ','M','e','d','i'
										TCHAR 		'a',':',' ',39,'%','w','s',39
g_strEndOfLine						TCHAR 		LF,CR,NULL

.data?

g_ptrDeviceInfo				PDEVICE_INFO	?
g_hConsole						HANDLE 			?

.code 

__Startup			proc 

	LOCAL l_arrLogicalDriveStrings[ MAXBYTE + 1 ] 	: TCHAR
	LOCAL @ecx 													: DWORD 
	LOCAL @rax 													: QWORD

			invoke GetStdHandle, STD_OUTPUT_HANDLE
			mov 			g_hConsole, rax
			
			call @@About
			
			invoke GetLogicalDriveStringsW, MAXBYTE, addr l_arrLogicalDriveStrings
			shr 			rax, 2
			jz @ExitProc

			mov 			@ecx, eax
			
			call @@NewDeviceInfo
			
			lea 			rax, l_arrLogicalDriveStrings

@Repeat:

			mov 			cx, [ rax ]
			mov 			g_cbDriveLetter, cx
			
			lea 			rcx, [ rax + 8 ]
			mov 			@rax, rcx 

			invoke GetDriveTypeW, rax 
			cmp eax, DRIVE_FIXED
			je @F
			cmp eax, DRIVE_REMOVABLE
			je @F
			jne @Next
			
@@:		call @@EmptyDeviceInfo
			
			invoke GetPhyDriveInfo, addr g_strDevicePath
			test al, al 
			jz @Next 
			
			call @@DumpDeviceInfo
			
@Next:

			mov 			rax, @rax
	
			dec dword ptr @ecx 
			jnz @Repeat

			call @@DisposeDeviceInfo
			
@ExitProc:

			invoke	ExitProcess, ERROR_SUCCESS

__Startup 			endp

GetPhyDriveInfo	proc	uses rsi rdi				\
								inDevicePath 	: LPCTSTR
								
	LOCAL l_bResult 			: BOOLEAN							
	LOCAL	l_hDevice 			: HANDLE								
	LOCAL l_dwReturnLength 	: DWORD								
	LOCAL l_ptrQuery 			: PSTORAGE_PROPERTY_QUERY		
	LOCAL l_ptrDescriptor	: PSTORAGE_DEVICE_DESCRIPTOR
	
			xor 			rax, rax 
			mov 			l_bResult, al
			mov 			l_ptrQuery, rax 
			mov 			l_ptrDescriptor, rax 
			mov 			l_dwReturnLength, eax
			
			invoke CreateFileW, inDevicePath, GENERIC_READ or GENERIC_WRITE, 			\
							FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 	\
								0, 0
			cmp			rax, INVALID_HANDLE_VALUE
			mov 			l_hDevice, rax
			jz	@ExitRoutine		

			mov 			rcx, sizeof(STORAGE_DEVICE_DESCRIPTOR)
			call @@GetMem
			jz @CleanupExitRoutine
			
			mov			l_ptrQuery, rax
			
			mov 			rcx, STORAGE_DEVICE_DESCRIPTOR_LENGTH
			call @@GetMem
			jz @CleanupExitRoutine

			mov 			l_ptrDescriptor, rax
			
			mov 			[ rax ].STORAGE_DEVICE_DESCRIPTOR.@Size, STORAGE_DEVICE_DESCRIPTOR_LENGTH			
			
			invoke DeviceIoControl, l_hDevice, IOCTL_STORAGE_QUERY_PROPERTY, l_ptrQuery,	\
								sizeof(STORAGE_PROPERTY_QUERY), l_ptrDescriptor,					\
									STORAGE_DEVICE_DESCRIPTOR_LENGTH, addr l_dwReturnLength,		\
										NULL
			test 			ax, ax 
			jz @CleanupExitRoutine
			
			mov 			rdx, l_ptrDescriptor
			
			mov 			cl, [ rdx ].STORAGE_DEVICE_DESCRIPTOR.RemovableMedia
			mov 			rax, g_ptrDeviceInfo
			mov 			[ rax ].DEVICE_INFO.IsRemovableMedia, cl
			
			mov 			ecx, [ rdx ].STORAGE_DEVICE_DESCRIPTOR.VendorIdOffset
			jecxz @F
			mov 			rdi, g_ptrDeviceInfo
			lea 			rdi, [ rdi ].DEVICE_INFO.VendorId
			call @@TrimStrCpyAtoW
			
@@:		mov 			ecx, [ rdx ].STORAGE_DEVICE_DESCRIPTOR.ProductIdOffset
			jecxz @F
			mov 			rdi, g_ptrDeviceInfo
			lea 			rdi, [ rdi ].DEVICE_INFO.ProductId
			call @@TrimStrCpyAtoW

@@:		mov 			ecx, [ rdx ].STORAGE_DEVICE_DESCRIPTOR.ProductRevisionOffset
			jecxz @F
			mov 			rdi, g_ptrDeviceInfo
			lea 			rdi, [ rdi ].DEVICE_INFO.ProductRevision
			call @@TrimStrCpyAtoW
			
@@:		mov 			ecx, [ rdx ].STORAGE_DEVICE_DESCRIPTOR.SerialNumberOffset
			jecxz @CleanupExitRoutine
			mov 			rdi, g_ptrDeviceInfo
			lea 			rdi, [ rdi ].DEVICE_INFO.SerialNumber
			call @@TrimStrCpyAtoW
			
			mov 			l_bResult, TRUE 
			
@CleanupExitRoutine:

			mov 			rcx, l_ptrDescriptor
			call @@FreeMem
			
			mov 			rcx, l_ptrQuery
			call @@FreeMem

			invoke CloseHandle, l_hDevice
			
@ExitRoutine:

			movzx 		rax, l_bResult
			ret
			
GetPhyDriveInfo	endp					  


@@Write				proc	inMessage : LPCTSTR
	
	LOCAL l_dwReturnLength : DWORD
	
			mov 			rdi, inMessage
			call @@StrLen
			jz @F
			
			mov 			rax, rcx
			
			invoke WriteConsoleW, 					\
							g_hConsole, 				\ 	
							inMessage, 					\ 	
							rax, 							\ 	
							addr l_dwReturnLength, 	\ 	
							NULL								
@@:
			ret
			
@@Write 				endp

@@WriteLn			proc inMessage : LPTSTR 
			invoke @@Write, inMessage
			invoke @@Write, addr g_strEndOfLine
			ret
@@WriteLn 			endp

@@NewDeviceInfo	proc 
			mov 			rcx, sizeof(DEVICE_INFO)
			call @@GetMem
			mov 			g_ptrDeviceInfo, rax 
			ret
@@NewDeviceInfo	endp
			
@@EmptyDeviceInfo:
			mov 			rdi, g_ptrDeviceInfo
			xor 			rax, rax 
			mov 			rcx, (sizeof(DEVICE_INFO) / sizeof(QWORD))
			rep stosq qword ptr [ rdi ]
			ret
			
@@DisposeDeviceInfo	proc 
			mov 			rcx, g_ptrDeviceInfo
			call @@FreeMem
			ret
@@DisposeDeviceInfo	endp

@@DumpDeviceInfo		proc 
			
	LOCAL l_strOutput 				: LPTSTR
	LOCAL l_strVendorId 				: LPTSTR
	LOCAL l_strProductId 			: LPTSTR 
	LOCAL l_strProductRevision 	: LPTSTR 
	LOCAL l_strSerialNumber 		: LPTSTR 
	LOCAL l_strIsRemovableMedia	: LPTSTR
	
			mov 			rcx, 200h
			call @@GetMem
			mov 			l_strOutput, rax 
	
			mov 			rdx, g_ptrDeviceInfo
						
						
			mov 			l_strVendorId, IFNULL([ rdx ].DEVICE_INFO.VendorId)
			mov 			l_strProductId, IFNULL([ rdx ].DEVICE_INFO.ProductId)
			mov 			l_strProductRevision, IFNULL([ rdx ].DEVICE_INFO.ProductRevision)
			mov 			l_strSerialNumber, IFNULL([ rdx ].DEVICE_INFO.SerialNumber)
			
			mov 			l_strIsRemovableMedia, BOOLTOSTR([ rdx ].DEVICE_INFO.IsRemovableMedia)
			
			invoke wsprintfW, l_strOutput, addr g_strReport, addr g_cbDriveLetter, l_strVendorId, \
							l_strProductId, l_strProductRevision, l_strSerialNumber, l_strIsRemovableMedia
														
			invoke @@WriteLn, l_strOutput
			
			mov 			rcx, l_strOutput
			call @@FreeMem
							
			ret 
		
@@DumpDeviceInfo		endp

@@StrLen:
			and 			ax, 0
			mov 			rcx, 0FFFFh
			repnz scasw
			not 			cx
			dec 			cx 
			ret

@@TrimStrCpyAtoW:
			lea 			rsi, [ rdx + rcx ]
			mov 			rbx, rdi
			mov 			r8w, 20h
@@:		movzx 		ax, byte ptr [ rsi ]
			test ax, ax
			jz @F
			cmp 			ax, r8w
			jnz @F
			inc 			rsi
			jmp @B
@@:		lodsb
			stosw
			test ax, ax
			jnz @B
			add 			rdi, -sizeof(TCHAR)
@@:		cmp rdi, rbx 
			jbe @F
			add 			rdi, -sizeof(TCHAR)
			cmp [ rdi ], r8w
			jne @F
			mov 			[ rdi ], ax
			jmp @B 
@@:		ret
			
@@GetMem:
			mov			rdx, LPTR 
			xchg 			rcx, rdx 
			jmp LocalAlloc
		
@@FreeMem:
			jmp LocalFree
			
@@About					proc
	
	LOCAL l_strModuleFileName[ MAX_PATH + 1 ] : TCHAR
	LOCAL l_ptrOutput : LPVOID
	
			invoke @@GetMem, 200h
			mov 			l_ptrOutput, rax 
			
			invoke GetModuleFileNameW, NULL, addr l_strModuleFileName, MAX_PATH
			
			lea 			rdi, l_strModuleFileName
@@:		cmp word ptr [ rdi + 2 * rax ], '.'
			je @F
			dec 			rax 
			jnz @B
@@:		mov 			word ptr [ rdi + 2 * rax ], NULL
@@:		cmp word ptr [ rdi + 2 * rax ], '\'
			je @F
			dec 			rax 
			jnz @B
@@:		lea 			r8, [ rdi + 2 * rax + 2 ]

			invoke wsprintfW, l_ptrOutput, addr g_strAbout

			invoke @@WriteLn, l_ptrOutput

			invoke @@FreeMem, l_ptrOutput

			ret
@@About 					endp

	end
