#!/bin/bash
# ============================================
# Script de Compilación - Calculadora Modular
# ============================================

echo "🔨 Compilando calculadora modular..."
echo ""

# Crear directorio de compilación
mkdir -p build

# Compilar cada módulo por separado
echo "📝 Compilando módulos..."

echo "  ├─ main.asm"
nasm -f elf64 src/main.asm -o build/main.o
if [ $? -ne 0 ]; then
    echo "❌ Error compilando main.asm"
    exit 1
fi

echo "  ├─ utils.asm"
nasm -f elf64 src/utils.asm -o build/utils.o
if [ $? -ne 0 ]; then
    echo "❌ Error compilando utils.asm"
    exit 1
fi

echo "  ├─ arithmetic.asm (José)"
nasm -f elf64 src/arithmetic.asm -o build/arithmetic.o
if [ $? -ne 0 ]; then
    echo "❌ Error compilando arithmetic.asm"
    exit 1
fi

echo "  ├─ logical.asm (Efraín)"
nasm -f elf64 src/logical.asm -o build/logical.o
if [ $? -ne 0 ]; then
    echo "❌ Error compilando logical.asm"
    exit 1
fi

echo "  └─ conversion.asm (Emmi)"
nasm -f elf64 src/conversion.asm -o build/conversion.o
if [ $? -ne 0 ]; then
    echo "❌ Error compilando conversion.asm"
    exit 1
fi

echo ""
echo "🔗 Enlazando módulos..."

# Enlazar todos los objetos
ld build/main.o build/utils.o build/arithmetic.o build/logical.o build/conversion.o -o calculadora

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Compilación exitosa!"
    echo ""
    echo "📊 Archivos generados:"
    ls -lh calculadora
    echo ""
    echo "▶️  Ejecutar con: ./calculadora"
else
    echo ""
    echo "❌ Error en el enlazado"
    exit 1
fi