@echo off
title Calculadora en Ensamblador
echo.
echo  ========================================
echo   Calculadora en Ensamblador x86-64
echo   Compilando y ejecutando en WSL...
echo  ========================================
echo.

:: Corregir finales de linea y compilar
wsl sh -c "cd /mnt/host/d/github/Calculadora-ensamblador && sed -i 's/\r$//' scripts/compile.sh && chmod +x scripts/compile.sh && sh scripts/compile.sh"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo  ERROR: La compilacion fallo.
    pause
    exit /b 1
)

echo.
echo  Iniciando calculadora...
echo  ----------------------------------------
echo.

:: Ejecutar la calculadora
wsl sh -c "cd /mnt/host/d/github/Calculadora-ensamblador && ./calculadora"

echo.
pause
