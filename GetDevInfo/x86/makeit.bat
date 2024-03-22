@echo off

if exist *.exe del *.exe
if exist *.obj del *.obj

\masm32\bin\ml /c /coff /W0 GetDevInfo.asm
\masm32\bin\link /MACHINE:X86 /NOLOGO /RELEASE /SUBSYSTEM:CONSOLE GetDevInfo.obj /OUT:GetDevInfo.exe

if exist *.obj del *.obj
