# Calculadora en Lenguaje Ensamblador x86-64

Calculadora modular en lenguaje ensamblador x86-64 (NASM + Linux syscalls) con frontend web en JavaScript y Tailwind CSS, desarrollada para el curso de **Organización y Arquitectura del Computador** de la Universidad Nacional de San Antonio Abad del Cusco (UNSAAC).

---

## Estructura del Proyecto

```
Calculadora-ensamblador/
├── backend/                    # Backend en ensamblador x86-64
│   ├── src/                    # Código fuente ensamblador
│   │   ├── main.asm            # Terminal interactiva (carátula, menú)
│   │   ├── api.asm             # API para frontend (stdin/stdout)
│   │   ├── utils.asm           # Utilidades compartidas
│   │   ├── arithmetic.asm      # Módulo aritmético: suma, resta, multiplicación, división
│   │   ├── logical.asm         # Módulo lógico: AND, OR, NOT, XOR
│   │   └── conversion.asm      # Módulo de conversión: binario ↔ hexadecimal
│   ├── build/                  # Archivos objeto (.o) generados
│   ├── server.js               # Servidor Node.js (puente frontend ↔ ASM)
│   └── scripts/
│       └── compile.sh          # Script de compilación para Linux/WSL
├── frontend/                   # Frontend web (JavaScript + Tailwind CSS)
│   ├── index.html              # Punto de entrada (Tailwind CDN + app.js)
│   └── app.js                  # Calculadora UI que consume el backend ASM
├── compilar.bat                # Script para compilar backend desde Windows (WSL)
├── .gitignore
└── README.md
```

---

## Arquitectura

```
┌─────────────────────┐     HTTP POST      ┌──────────────────┐     stdin/stdout     ┌─────────────────────┐
│   Frontend (JS)     │ ──────────────────► │  Servidor Node   │ ──────────────────► │  Backend ASM x86-64 │
│   Tailwind CSS      │ ◄────── JSON ────── │  (server.js)     │ ◄──── resultado ─── │  (calculadora_api)  │
│   Calculadora UI    │                     │  Puerto 3000     │                     │  NASM + Linux       │
└─────────────────────┘                     └──────────────────┘                     └─────────────────────┘
```

**Todas las operaciones aritméticas, lógicas y de conversión se ejecutan en ensamblador x86-64.**
El frontend JS solo muestra la interfaz y envía peticiones al servidor, que invoca el binario ASM.

---

## Frontend Web

El frontend es una calculadora que **consume el backend ASM** a través del servidor Node.js:

1. Compilar el backend: `compilar.bat` o `wsl bash backend/scripts/compile.sh`
2. Iniciar servidor: `node backend/server.js`
3. Abrir en navegador: `http://localhost:3000`

**Operaciones disponibles:**
- **Aritméticas:** Suma, Resta, Multiplicación, División (instrucciones ADD, SUB, MUL, DIV)
- **Lógicas:** AND, OR, NOT, XOR (instrucciones AND, OR, NOT, XOR sobre 4 bits)
- **Conversión:** Binario 8 bits ↔ Hexadecimal (instrucciones SHR, SHL, AND, OR)

---

## Requisitos Previos

### En Ubuntu / Linux nativo

```bash
sudo apt update
sudo apt install nasm binutils
```

- **NASM** — Ensamblador (Netwide Assembler) para x86-64.
- **ld** — Enlazador de GNU (incluido en `binutils`).

### En Windows con WSL (Subsistema de Windows para Linux)

#### 1. Instalar WSL

Abrir **PowerShell como Administrador** y ejecutar:

```powershell
wsl --install
```

Esto instala WSL 2 con Ubuntu por defecto. Reiniciar el equipo si lo solicita.

#### 2. Instalar NASM y binutils dentro de WSL

Abrir la terminal de Ubuntu (WSL) y ejecutar:

```bash
sudo apt update
sudo apt install nasm binutils
```

#### 3. Verificar la instalación

```bash
nasm --version
ld --version
```

---

## Compilación y Ejecución

### Opción 1: Desde Windows (doble clic)

Ejecutar el archivo `compilar.bat`. Este script:
1. Llama a WSL automáticamente.
2. Corrige finales de línea (CRLF → LF).
3. Compila todos los módulos con NASM.
4. Enlaza los objetos con `ld`.
5. Ejecuta la calculadora.

```
compilar.bat
```

### Opción 2: Desde terminal WSL / Linux

```bash
# Dar permisos de ejecución al script (solo la primera vez)
chmod +x scripts/compile.sh

# Compilar
./scripts/compile.sh

# Ejecutar
./calculadora
```

### Opción 3: Desde PowerShell (Windows) usando WSL

```powershell
wsl sh -c "cd /mnt/host/d/github/Calculadora-ensamblador && sed -i 's/\r$//' scripts/compile.sh && chmod +x scripts/compile.sh && sh scripts/compile.sh"
wsl sh -c "cd /mnt/host/d/github/Calculadora-ensamblador && ./calculadora"
```

> **Nota:** Ajustar la ruta `/mnt/host/d/github/Calculadora-ensamblador` según la ubicación del proyecto en tu disco.

---

## Herramientas de Desarrollo

### Visual Studio Code (editor recomendado)

Extensiones recomendadas para trabajar con ensamblador en VS Code:

| Extensión | Descripción |
|-----------|-------------|
| **ASM Code Lens** | Navegación y resaltado de sintaxis para NASM/MASM |
| **x86 and x86_64 Assembly** | Resaltado de sintaxis para ensamblador x86/x64 |
| **WSL** (Microsoft) | Permite abrir el proyecto dentro de WSL desde VS Code |
| **LinkerScript** | Soporte para scripts de enlazado |

Para abrir el proyecto en WSL desde VS Code:
1. Instalar la extensión **WSL** de Microsoft.
2. Presionar `Ctrl+Shift+P` → `WSL: Connect to WSL`.
3. Abrir la carpeta del proyecto.

### emu8086 (alternativa para ensamblador de 16 bits)

[emu8086](https://emu8086-microprocessor-emulator.en.softonic.com/) es un emulador de microprocesador 8086 para Windows que incluye:
- Editor con resaltado de sintaxis.
- Ensamblador integrado.
- Emulador paso a paso con vista de registros y memoria.

> **Importante:** emu8086 trabaja con instrucciones de **16 bits (8086/8088)** y no es compatible directamente con este proyecto (x86-64). Es útil para aprender los fundamentos del ensamblador en modo real.

### DOSBox (ejecutar programas .COM/.EXE de 16 bits)

[DOSBox](https://www.dosbox.com/) permite ejecutar programas de 16 bits compilados con emu8086 en Windows moderno:

1. Descargar e instalar [DOSBox](https://www.dosbox.com/download.php?main=1).
2. Montar la carpeta de trabajo:
   ```
   mount C C:\ruta\a\tus\programas
   C:
   ```
3. Ejecutar el programa `.COM` o `.EXE` generado por emu8086.

> **Nota:** DOSBox es para programas DOS de 16 bits. Este proyecto usa Linux x86-64 y se ejecuta en WSL o Linux nativo.

---

## Proceso de Compilación (detalle técnico)

```
   src/main.asm ──► nasm -f elf64 ──► build/main.o ─┐
   src/utils.asm ──► nasm -f elf64 ──► build/utils.o ─┤
   src/arithmetic.asm ──► nasm -f elf64 ──► build/arithmetic.o ─┤──► ld ──► calculadora (ejecutable ELF64)
   src/logical.asm ──► nasm -f elf64 ──► build/logical.o ─┤
   src/conversion.asm ──► nasm -f elf64 ──► build/conversion.o ─┘
```

- **NASM** ensambla cada archivo `.asm` a un archivo objeto `.o` en formato ELF64.
- **ld** enlaza todos los objetos en un ejecutable Linux de 64 bits.
- El programa usa **syscalls de Linux** directamente (sin libc).

---

## Módulos

| Módulo | Archivo | Operaciones |
|--------|---------|-------------|
| Principal | `main.asm` | Carátula, menú principal, flujo del programa |
| Utilidades | `utils.asm` | `print_string`, `strlen`, `leer_opcion`, `pausar`, `print_number`, `ascii_to_num` |
| Aritmético | `arithmetic.asm` | Suma, Resta, Multiplicación, División (con cociente y residuo) |
| Lógico | `logical.asm` | AND, OR, NOT |
| Conversión | `conversion.asm` | Binario (8 bits) → Hexadecimal, Hexadecimal → Binario (8 bits) |

---

## Integrantes

- Huamán Tairo, Emmi Daniela
- Quentasi Juachín, José Francisco
- Vitorino Marín, Efraín

**Docente:** Vanesa Lavilla Alvarez  
**Curso:** Organización y Arquitectura del Computador  
**Universidad:** Universidad Nacional de San Antonio Abad del Cusco


