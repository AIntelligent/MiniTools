# Mini Tools

# GET DEVICE DRIVER HARDWARE INFO (GetDevInfo)

Requirements:

	X86:	MS Windows XP or better
		MASM32

  	X64:	MS Windows XP64 or better
		MASM64

Make It:

	MASM32:	ml.exe /c /coff /W0 GetDevInfo.asm 
		link /MACHINE:X86 /NOLOGO /RELEASE /SUBSYSTEM:CONSOLE GetDevInfo.obj /OUT:GetDevInfo.exe

	MASM64:	ml64.exe /c GetDevInfo.asm
  		link /SUBSYSTEM:CONSOLE /ENTRY:__Startup /nologo /LARGEADDRESSAWARE GetDevInfo.obj
		
Output:

	GET DEVICE DRIVER HARDWARE INFO (GetDevInfo), Version 1.0

	The example program was written by Hakan E. Kartal in 2024 using x86 Assembly
	https://github.com/AIntelligent, hek@nula.com.tr

			  Logical Drive:      'C:'
			  Vendor Id:          'NULL'
			  Product Id:         'SanDisk SDSSDP256G'
			  Product Revision:   '2.0.0'
			  Serial Number:      '142630631408'
			  Is Removable Media: 'FALSE'

			  Logical Drive:      'D:'
			  Vendor Id:          'NULL'
			  Product Id:         'SanDisk SSD i100 24GB'
			  Product Revision:   '11.50.02'
			  Serial Number:      '120048112525'
			  Is Removable Media: 'FALSE'

			  Logical Drive:      'E:'
			  Vendor Id:          'Kingston'
			  Product Id:         'DataTraveler 2.0'
			  Product Revision:   '1.00'
			  Serial Number:      '0034D1CC0EC1A6962A9C150C'
			  Is Removable Media: 'TRUE'

			  Logical Drive:      'F:'
			  Vendor Id:          'USB'
			  Product Id:         'Sandisk 3.2Gen1'
			  Product Revision:   '1.00'
			  Serial Number:      '1bfe01028441c112538c'
			  Is Removable Media: 'TRUE'
