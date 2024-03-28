@echo off

cls

for %%f in (*.exe *.obj) do del /F /Q %%f

set Masm32Bin=..\bin

for %%f in (*.asm) do %Masm32Bin%\ml /c /coff /W0 %%f
for %%f in (*.obj) do %Masm32Bin%\link /MACHINE:X86 /RELEASE /ENTRY:__Startup /NOLOGO /SUBSYSTEM:CONSOLE %%f

set Masm32Bin=

for %%f in (*.obj) do del /F /Q %%f
for %%f in (*.exe) do echo Done: %%f

REM pause
