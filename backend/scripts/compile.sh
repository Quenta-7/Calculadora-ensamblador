#!/bin/bash
# ============================================
# Script de Compilación - Calculadora Modular
# Backend (Ensamblador x86-64)
# ============================================

BACKEND_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "🔨 Compilando calculadora modular (backend)..."
echo ""

# Crear directorio de compilación
mkdir -p "$BACKEND_DIR/build"

# Compilar cada módulo por separado
echo "📝 Compilando módulos..."

echo "  ├─ main.asm"
nasm -f elf64 "$BACKEND_DIR/src/main.asm" -o "$BACKEND_DIR/build/main.o"
if [ $? -ne 0 ]; then
    echo "❌ Error compilando main.asm"
    exit 1
fi

echo "  ├─ utils.asm"
nasm -f elf64 "$BACKEND_DIR/src/utils.asm" -o "$BACKEND_DIR/build/utils.o"
if [ $? -ne 0 ]; then
    echo "❌ Error compilando utils.asm"
    exit 1
fi

echo "  ├─ arithmetic.asm (José)"
nasm -f elf64 "$BACKEND_DIR/src/arithmetic.asm" -o "$BACKEND_DIR/build/arithmetic.o"
if [ $? -ne 0 ]; then
    echo "❌ Error compilando arithmetic.asm"
    exit 1
fi

echo "  ├─ logical.asm (Efraín)"
nasm -f elf64 "$BACKEND_DIR/src/logical.asm" -o "$BACKEND_DIR/build/logical.o"
if [ $? -ne 0 ]; then
    echo "❌ Error compilando logical.asm"
    exit 1
fi

echo "  └─ conversion.asm (Emmi)"
nasm -f elf64 "$BACKEND_DIR/src/conversion.asm" -o "$BACKEND_DIR/build/conversion.o"
if [ $? -ne 0 ]; then
    echo "❌ Error compilando conversion.asm"
    exit 1
fi

echo ""
echo "🔗 Enlazando módulos (terminal interactiva)..."

# Enlazar todos los objetos - versión terminal interactiva
ld "$BACKEND_DIR/build/main.o" "$BACKEND_DIR/build/utils.o" "$BACKEND_DIR/build/arithmetic.o" "$BACKEND_DIR/build/logical.o" "$BACKEND_DIR/build/conversion.o" -o "$BACKEND_DIR/calculadora"

if [ $? -ne 0 ]; then
    echo "❌ Error en el enlazado de calculadora"
    exit 1
fi

echo "✅ calculadora (terminal) compilada"

# ============================================
# Compilar API (punto de entrada para frontend)
# ============================================
echo ""
echo "📝 Compilando API para frontend..."

echo "  └─ api.asm"
nasm -f elf64 "$BACKEND_DIR/src/api.asm" -o "$BACKEND_DIR/build/api.o"
if [ $? -ne 0 ]; then
    echo "❌ Error compilando api.asm"
    exit 1
fi

echo ""
echo "🔗 Enlazando API (api + utils)..."

# La API usa utils.asm para print_string, print_number, ascii_to_num, strlen
ld "$BACKEND_DIR/build/api.o" "$BACKEND_DIR/build/utils.o" -o "$BACKEND_DIR/calculadora_api"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Compilación exitosa!"
    echo ""
    echo "📊 Archivos generados:"
    ls -lh "$BACKEND_DIR/calculadora" "$BACKEND_DIR/calculadora_api"
    echo ""
    echo "▶️  Terminal:  ./backend/calculadora"
    echo "▶️  Frontend:  node backend/server.js"
else
    echo ""
    echo "❌ Error en el enlazado de calculadora_api"
    exit 1
fi