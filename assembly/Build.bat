@echo off
echo ================================
echo Stack Visualization Tool - Build
echo ================================
echo.

echo Building SimplePush.asm...
ml /c /coff /Zi Programs\SimplePush.asm
link /SUBSYSTEM:CONSOLE /DEBUG Programs\SimplePush.obj Irvine32.lib kernel32.lib /OUT:Programs\SimplePush.exe

echo.
echo Building SimpleFactorial.asm...
ml /c /coff /Zi Programs\SimpleFactorial.asm
link /SUBSYSTEM:CONSOLE /DEBUG Programs\SimpleFactorial.obj Irvine32.lib kernel32.lib /OUT:Programs\SimpleFactorial.exe

echo.
echo Building SimpleFibonacci.asm...
ml /c /coff /Zi Programs\SimpleFibonacci.asm
link /SUBSYSTEM:CONSOLE /DEBUG Programs\SimpleFibonacci.obj Irvine32.lib kernel32.lib /OUT:Programs\SimpleFibonacci.exe

echo.
echo Building NestedCalls.asm...
ml /c /coff /Zi Programs\NestedCalls.asm
link /SUBSYSTEM:CONSOLE /DEBUG Programs\NestedCalls.obj Irvine32.lib kernel32.lib /OUT:Programs\NestedCalls.exe

echo.
echo Building main StackSim.asm...
ml /c /coff /Zi StackSim.asm
link /SUBSYSTEM:CONSOLE /DEBUG StackSim.obj Irvine32.lib kernel32.lib /OUT:StackSim.exe

echo.
echo ================================
echo Build Complete!
echo ================================
echo.
echo Run any program to generate stacklog.txt
echo Then open web-viewer/index.html to visualize
echo.
pause

