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

	The example program was written by Kartal, Hakan Emre in 2024 using Intel x86 Assembly
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

# GET LINE COUNT EXTREME (getlcex)

Requirements:

	X86:	MS Windows XP or better
		MASM32

Make It:

	MASM32:	ml.exe /c /coff /W0 getlcex.asm 
		link /MACHINE:X86 /NOLOGO /RELEASE /SUBSYSTEM:CONSOLE getlcex.obj /OUT:getlcex.exe

Output:

	GET LINE COUNT EXTREME (getlcex), Version 1.0
	
	The example program was written by Kartal, Hakan Emre in 2024 using Intel x86 Assembly
	https://github.com/AIntelligent, hek@nula.com.tr
		
	Report:
	
	        File full path name: 'C:\Temp\WordHunt.log'
	        File size:           '373713156 bytes'
	
	        Lines count:         '4242654 lines'
	        Elapsed time:        '359 ms'
	
	        Thread count:        '6 threads'
	        Cache buffer length: '1048576 bytes'

# FIBONACCI CALCULATOR (fibo)

Requirements:

	X86:	MS Windows XP or better
		MASM32

Make It:

	MASM32:	ml.exe /c /coff /W0 fibo.asm 
		link /MACHINE:X86 /NOLOGO /RELEASE /SUBSYSTEM:CONSOLE fibo.obj /OUT:fibo.exe

Output:
        0
        1
        1
        2
        3
        5
        8
       13
       21
       34
       55
       89
      144
      233
      377
      610
      987
     1597
     2584
     4181
     6765
    10946
    17711
    28657
    46368
    75025
   121393
   196418
   317811
   514229
   832040
  1346269
  2178309
  3524578
  5702887
  9227465
 14930352
 24157817
 39088169
 63245986

Press Enter or Escape to exit...
