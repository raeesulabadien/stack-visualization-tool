@echo off
REM Build.bat - Build script for Stack Simulator
REM Usage: Build.bat filename.asm

if "%1"=="" (
    echo Usage: Build.bat filename.asm
    echo Example: Build.bat StackSim.asm
    exit /b 1
)

echo ======================================
echo Building %1...
echo ======================================

REM Assemble
ml /c /coff /Fl %1
if errorlevel 1 goto BuildError

REM Extract base filename without extension
set BASENAME=%~n1

REM Link
link /SUBSYSTEM:CONSOLE %BASENAME%.obj Irvine32.lib kernel32.lib user32.lib /OUT:%BASENAME%.exe
if errorlevel 1 goto BuildError

echo ======================================
echo Build successful: %BASENAME%.exe
echo ======================================

REM Clean up intermediate files
del %BASENAME%.obj 2>nul

exit /b 0

:BuildError
echo ======================================
echo Build FAILED!
echo ======================================
exit /b 1
