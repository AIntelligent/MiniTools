@echo off 

cls

for %%f in (*.exe *.obj) do del /F /Q %%f

set Masm64Bin=..\Bin64

%Masm64Bin%\ml64 /c /nologo GetDevInfo.asm 
%Masm64Bin%\link /SUBSYSTEM:CONSOLE /ENTRY:__Startup /nologo /LARGEADDRESSAWARE GetDevInfo.obj

set Masm64Bin=

for %%f in (*.obj) do del /F /Q %%f

for %%f in (*.exe) do echo Done: %%f

pause 