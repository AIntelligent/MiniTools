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
;; 		MS Windows XP or better
;; 		MASM32
;; 
;; Make It:
;; 
;; 		ml.exe /c /coff /W0 GetDevInfo.asm 
;; 		link /MACHINE:X86 /NOLOGO /RELEASE /SUBSYSTEM:CONSOLE GetDevInfo.obj /OUT:GetDevInfo.exe
;; 		
;; Output:
;; 
;; 		GET DEVICE DRIVER HARDWARE INFO (GetDevInfo), Version 1.0
;; 
;; 		The example program was written by Hakan Emre Kartal in 2024 using x86 Assembly
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

			.386

			.model			flat, stdcall

			option			casemap : none

			include		..\include\windows.inc
			include 		..\include\kernel32.inc 
			include 		..\include\user32.inc

			includelib 	..\lib\kernel32.lib 
			includelib	..\lib\user32.lib
			
IFNULL MACRO inString
	LOCAL label
	lea 			eax, inString 
	push 			eax 
	cmp byte ptr [ eax ], NULL
	jnz label 
	mov 			[ esp ], offset g_strNull
label:
ENDM

BOOLTOSTR MACRO inCondition
	LOCAL label
	push 			offset g_strFalse
	lea 			eax, inCondition
	cmp byte ptr [ eax ], FALSE
	jz label 
	mov 			[ esp ], offset g_strTrue
label:
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

_DEVICE_INFO						struct 
	VendorId 						CHAR  	DEVICE_INFO_STRING_LENGTH dup (?)
	ProductId						CHAR		DEVICE_INFO_STRING_LENGTH dup (?)
	ProductRevision				CHAR 		DEVICE_INFO_STRING_LENGTH dup (?)
	SerialNumber 					CHAR 		DEVICE_INFO_STRING_LENGTH dup (?)
	IsRemovableMedia				BOOLEAN 	?
_DEVICE_INFO						ends 
	
DEVICE_INFO							typedef 	_DEVICE_INFO
PDEVICE_INFO						typedef 	ptr _DEVICE_INFO
		
.data

g_strDevicePath					CHAR	 		"\\.\"
g_cbDriveLetter					CHAR			'?'
										CHAR 			':',NULL
									
g_strTrue							CHAR 			"TRUE",NULL
g_strFalse							CHAR 			"FALSE",NULL
g_strNull							CHAR 			"NULL",NULL
g_strAbout							CHAR 			"GET DEVICE DRIVER HARDWARE INFO (%s), Version 1.0",LF,CR,LF,CR
										CHAR 			"The example program was written by Hakan Emre Kartal in 2024 using Intel x86 Assembly",LF,CR
										CHAR 			"https://github.com/AIntelligent, hek@nula.com.tr",LF,CR,LF,CR,NULL
g_strReport							CHAR 			TAB,"Drive:              '%s'",LF,CR
										CHAR 			TAB,"Vendor Id:          '%s'",LF,CR
										CHAR 			TAB,"Product Id:         '%s'",LF,CR
										CHAR 			TAB,"Product Revision:   '%s'",LF,CR
										CHAR 			TAB,"Serial Number:      '%s'",LF,CR
										CHAR 			TAB,"Is Removable Media: '%s'"
g_strEndOfLine						CHAR 			LF,CR,NULL

.data?

g_ptrDeviceInfo				PDEVICE_INFO	?
g_hConsole						HANDLE 			?

.code			

GetPhyDriveInfo	PROTO :LPSTR 

__Startup		proc

	LOCAL l_arrLogicalDriveStrings[ MAXBYTE ] : CHAR
	LOCAL @ecx 											: DWORD 
	LOCAL @eax 											: DWORD

			invoke GetStdHandle, STD_OUTPUT_HANDLE
			mov 			g_hConsole, eax
			
			call @@About
			
			invoke GetLogicalDriveStrings, MAXBYTE, addr l_arrLogicalDriveStrings
			shr 			eax, 2
			jz @ExitProc

			mov 			@ecx, eax
			
			call @@NewDeviceInfo
			
			lea 			eax, l_arrLogicalDriveStrings

@Repeat:

			mov 			cl, [ eax ]
			mov 			g_cbDriveLetter, cl
			
			lea 			ecx, [ eax + sizeof(DWORD) ]
			mov 			@eax, ecx 
			
			invoke GetDriveType, eax 
			cmp eax, DRIVE_FIXED
			je @F
			cmp eax, DRIVE_REMOVABLE
			je @F
			jne @Next
			
@@:		call @@EmptyDeviceInfo
			
			invoke GetPhyDriveInfo, offset g_strDevicePath
			test al, al 
			jz @Next 
			
			call @@DumpDeviceInfo
			
@Next:

			mov 			eax, @eax
	
			dec 			@ecx 
			jnz @Repeat

			call @@DisposeDeviceInfo
			
@ExitProc:

			invoke	ExitProcess, ERROR_SUCCESS
			
__Startup 			endp

GetPhyDriveInfo	proc	uses esi edi				\
								inDevicePath 	: LPSTR
								
	LOCAL l_bResult 			: BOOLEAN
	LOCAL	l_hDevice 			: HANDLE
	LOCAL l_dwReturnLength 	: DWORD 
	LOCAL l_ptrQuery 			: PSTORAGE_PROPERTY_QUERY
	LOCAL l_ptrDescriptor	: PSTORAGE_DEVICE_DESCRIPTOR
	
			xor 			eax, eax 
			mov 			l_bResult, al
			mov 			l_ptrQuery, eax 
			mov 			l_ptrDescriptor, eax 
			mov 			l_dwReturnLength, eax
			
			invoke CreateFileA, inDevicePath, GENERIC_READ or GENERIC_WRITE, 			\
							FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, OPEN_EXISTING, 	\
								0, 0
			cmp			eax, INVALID_HANDLE_VALUE
			mov 			l_hDevice, eax
			jz	@ExitRoutine		

			mov 			eax, sizeof(STORAGE_DEVICE_DESCRIPTOR)
			call @@GetMem
			jz @CleanupExitRoutine
			
			mov			l_ptrQuery, eax
			
			mov 			eax, STORAGE_DEVICE_DESCRIPTOR_LENGTH
			call @@GetMem
			jz @CleanupExitRoutine

			mov 			l_ptrDescriptor, eax
			
			mov 			[ eax ].STORAGE_DEVICE_DESCRIPTOR.@Size, STORAGE_DEVICE_DESCRIPTOR_LENGTH			
			
			invoke DeviceIoControl, l_hDevice, IOCTL_STORAGE_QUERY_PROPERTY, l_ptrQuery,	\
								sizeof(STORAGE_PROPERTY_QUERY), l_ptrDescriptor,					\
									STORAGE_DEVICE_DESCRIPTOR_LENGTH, addr l_dwReturnLength,		\
										NULL
			test 			ax, ax 
			jz @CleanupExitRoutine
			
			mov 			edx, l_ptrDescriptor
			
			mov 			cl, [ edx ].STORAGE_DEVICE_DESCRIPTOR.RemovableMedia
			mov 			eax, g_ptrDeviceInfo
			mov 			[ eax ].DEVICE_INFO.IsRemovableMedia, cl
			
			mov 			ecx, [ edx ].STORAGE_DEVICE_DESCRIPTOR.VendorIdOffset
			jecxz @F
			mov 			edi, g_ptrDeviceInfo
			lea 			edi, [ edi ].DEVICE_INFO.VendorId
			call @@TrimStrCpy
			
@@:		mov 			ecx, [ edx ].STORAGE_DEVICE_DESCRIPTOR.ProductIdOffset
			jecxz @F
			mov 			edi, g_ptrDeviceInfo
			lea 			edi, [ edi ].DEVICE_INFO.ProductId
			call @@TrimStrCpy

@@:		mov 			ecx, [ edx ].STORAGE_DEVICE_DESCRIPTOR.ProductRevisionOffset
			jecxz @F
			mov 			edi, g_ptrDeviceInfo
			lea 			edi, [ edi ].DEVICE_INFO.ProductRevision
			call @@TrimStrCpy
			
@@:		mov 			ecx, [ edx ].STORAGE_DEVICE_DESCRIPTOR.SerialNumberOffset
			jecxz @CleanupExitRoutine
			mov 			edi, g_ptrDeviceInfo
			lea 			edi, [ edi ].DEVICE_INFO.SerialNumber
			call @@TrimStrCpy
			
			mov 			l_bResult, TRUE 
			
@CleanupExitRoutine:

			mov 			eax, l_ptrDescriptor
			call @@FreeMem
			
			mov 			eax, l_ptrQuery
			call @@FreeMem

			invoke CloseHandle, l_hDevice
			
@ExitRoutine:

			movzx 		eax, l_bResult
			ret
			
GetPhyDriveInfo	endp					  

@@Write				proc	inMessage : LPSTR 
	
	LOCAL l_dwReturnLength : DWORD
	
			mov 			edi, inMessage
			call @@StrLen
			jz @F
			
			invoke WriteConsole, 					\
							g_hConsole, 				\ 	
							inMessage, 					\ 	
							ecx, 							\ 	
							addr l_dwReturnLength, 	\ 	
							NULL								
@@:
			ret
			
@@Write 				endp

@@WriteLn			proc inMessage : LPSTR 
			invoke @@Write, inMessage
			invoke @@Write, offset g_strEndOfLine
			ret
@@WriteLn 			endp

@@NewDeviceInfo:
			mov 			eax, sizeof(DEVICE_INFO)
			call @@GetMem
			mov 			g_ptrDeviceInfo, eax 
			ret
			
@@EmptyDeviceInfo:
			mov 			edi, g_ptrDeviceInfo
			xor 			al, al 
			mov 			ecx, sizeof(DEVICE_INFO)
			rep stosb
			ret
			
@@DisposeDeviceInfo: 
			mov 			eax, g_ptrDeviceInfo
			call @@FreeMem
			ret

@@DumpDeviceInfo		proc 
			
	LOCAL l_ptrOutput : LPVOID
	
			mov 			eax, 200h
			call @@GetMem
			mov 			l_ptrOutput, eax 
	
			mov 			edx, g_ptrDeviceInfo
			
			BOOLTOSTR([ edx ].DEVICE_INFO.IsRemovableMedia)	
			IFNULL([ edx ].DEVICE_INFO.SerialNumber)			
			IFNULL([ edx ].DEVICE_INFO.ProductRevision)		
			IFNULL([ edx ].DEVICE_INFO.ProductId)				
			IFNULL([ edx ].DEVICE_INFO.VendorId)
			PUSH 			offset g_cbDriveLetter
			push 			offset g_strReport
			push 			l_ptrOutput						
			call wsprintfA												
			add 			esp, 7 * sizeof(DWORD)					
														
			invoke @@WriteLn, l_ptrOutput
			
			mov 			eax, l_ptrOutput
			call @@FreeMem
							
			ret 
		
@@DumpDeviceInfo		endp

@@StrLen:
			xor 			al, al
			mov 			ecx, 0FFFFh
			repnz scasb
			not 			cx 
			dec 			cx 
			ret

@@TrimStrCpy:
			lea 			esi, [ edx + ecx ]
			mov 			ebx, edi
			mov 			ah, 20h
@@:		mov 			al, [ esi ]
			test al, al
			jz @F
			cmp 			al, ah
			jnz @F
			inc 			esi
			jmp @B 
@@:		mov 			al, [ esi ]
			test al, al
			movsb
			jnz @B 
			dec 			edi
@@:		cmp edi, ebx 
			jbe @F
			dec 			edi
			cmp [ edi ], ah
			jne @F
			mov 			[ edi ], al
			jmp @B 
@@:		ret
			
@@GetMem:
			invoke LocalAlloc, LPTR, eax
			test 			eax, eax
			ret 
		
@@FreeMem:
			invoke LocalFree, eax 
			ret
			
@@About					proc
	
	LOCAL l_strModuleFileName[ MAX_PATH + 1 ] : CHAR
	LOCAL l_ptrOutput : LPVOID
	
			mov 			eax, 200h
			call @@GetMem
			mov 			l_ptrOutput, eax 
			
			invoke GetModuleFileNameA, NULL, addr l_strModuleFileName, MAX_PATH

			lea 			edi, l_strModuleFileName
@@:		cmp byte ptr [ edi + eax ], '.'
			je @F
			dec 			eax 
			jnz @B
@@:		mov 			byte ptr [ edi + eax ], NULL
@@:		cmp byte ptr [ edi + eax ], '\'
			je @F
			dec 			eax 
			jnz @B
@@:		lea 			eax, [ edi + eax + 1 ]

			push 			eax 
			push 			offset g_strAbout
			push 			l_ptrOutput
			call wsprintfA
			add 			esp, 3 * sizeof(DWORD) 

			invoke @@WriteLn, l_ptrOutput

			mov 			eax, l_ptrOutput
			call @@FreeMem

			ret
@@About 					endp

	end __Startup
