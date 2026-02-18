#!/bin/bash
echo "🔨 Compilando calculadora..."
mkdir -p build
nasm -f elf64 src/main.asm -o build/main.o && \
ld build/main.o -o calculadora && \
echo "✅ Compilación exitosa" || \
echo "❌ Error en compilación"
