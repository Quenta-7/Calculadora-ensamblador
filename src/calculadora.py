import tkinter as tk
from tkinter import ttk, messagebox
import ctypes
import os

# --- CARGA DE LA LIBRERÍA DE ENSAMBLADOR ---
# La librería .so contiene las etiquetas globales de tus módulos
lib_path = os.path.abspath("./build/libcalc.so")
try:
    calc = ctypes.CDLL(lib_path)
    
    def bind_func(name):
        try:
            func = getattr(calc, name)
            # Definimos que recibe un puntero (char*) para strings
            func.argtypes = [ctypes.c_char_p]
            # Forzamos que el retorno sea de 64 bits para capturar RAX completo
            func.restype = ctypes.c_int64
            return func
        except AttributeError:
            return None

    # Vinculamos con los nombres exportados en tu libcalc.so
    f_bin_to_num = bind_func('asmBinToNum8') 
    f_hex_to_num = bind_func('asmHexToNum')


except OSError:
    print(f"Error: No se encontró la librería en {lib_path}")
    exit()

class CalculadoraEnsamblador:
    def __init__(self, root):
        self.root = root
        self.root.title("Calculadora - Backend Ensamblador")
        self.root.geometry("380x720")
        self.root.configure(bg="#f5f5f5")

        self.expresion = ""
        self.operando1 = None
        self.operacion_actual = None

        # --- DISPLAY (Diseño según imagen) ---
        self.display_frame = tk.Frame(root, bg="#d4e6d5", height=110, bd=0)
        self.display_frame.pack(fill="x", padx=15, pady=15)
        self.display_frame.pack_propagate(False)

        self.lbl_op_secundaria = tk.Label(self.display_frame, text="", font=("Arial", 11), bg="#d4e6d5", fg="#555", anchor="e")
        self.lbl_op_secundaria.pack(fill="x", padx=15, pady=(15, 0))

        self.lbl_main = tk.Label(self.display_frame, text="0", font=("Arial", 28, "bold"), bg="#d4e6d5", fg="#1a1a1a", anchor="e")
        self.lbl_main.pack(fill="x", padx=15)

        # --- PESTAÑAS (Notebook) ---
        self.tabs = ttk.Notebook(root)
        self.tabs.pack(fill="both", expand=True, padx=10)

        self.tab_arit = tk.Frame(self.tabs, bg="white")
        self.tab_log = tk.Frame(self.tabs, bg="white")
        self.tab_conv = tk.Frame(self.tabs, bg="white")

        self.tabs.add(self.tab_arit, text="Aritmética")
        self.tabs.add(self.tab_log, text="Lógica")
        self.tabs.add(self.tab_conv, text="Conversión")

        self.setup_aritmetica()
        self.setup_logica()
        self.setup_conversion()

    # --- MÓDULO CONVERSIÓN (Backend: conversion.asm) ---
    def setup_conversion(self):
        f = tk.Frame(self.tab_conv, bg="white")
        f.pack(pady=10)
        btns_hex = [
            ('7', 0, 0), ('8', 0, 1), ('9', 0, 2), ('A', 0, 3, "#34495e"),
            ('4', 1, 0), ('5', 1, 1), ('6', 1, 2), ('B', 1, 3, "#34495e"),
            ('1', 2, 0), ('2', 2, 1), ('3', 2, 2), ('C', 2, 3, "#34495e"),
            ('C', 3, 0, "#eb4d4b"), ('0', 3, 1), ('E', 3, 2, "#34495e"), ('D', 3, 3, "#34495e"),
            ('F', 4, 1, "#34495e")
        ]
        for b in btns_hex:
            self.crear_btn(f, b, self.click_conv)

        tk.Button(self.tab_conv, text="BIN ➔ HEX", bg="#f39c12", fg="white", font=("Arial", 10, "bold"), 
                  width=20, command=self.asm_bin_to_hex).pack(pady=5)
        tk.Button(self.tab_conv, text="HEX ➔ BIN", bg="#e67e22", fg="white", font=("Arial", 10, "bold"), 
                  width=20, command=self.asm_hex_to_bin).pack(pady=5)

    def click_conv(self, char):
        if char == 'C': self.limpiar()
        else:
            if len(self.expresion) < 8:
                self.expresion += char
                self.lbl_main.config(text=self.expresion)

    def asm_bin_to_hex(self):
        if not f_bin_to_num: return
        val_input = self.lbl_main.cget("text")
        # El backend espera exactamente 8 bits y salto de línea para terminar el loop
        val_str = (val_input + "\n").encode('utf-8')
        num = f_bin_to_num(val_str)
        if num != -1:
            res = hex(num & 0xFF)[2:].upper().zfill(2)
            self.lbl_op_secundaria.config(text=f"BIN: {val_input}")
            self.lbl_main.config(text=res)
            self.expresion = res
        else:
            messagebox.showerror("Error", "Entrada inválida (Requiere 8 bits)")

    def asm_hex_to_bin(self):
        if not f_hex_to_num: return
        val_input = self.lbl_main.cget("text")
        
        # AJUSTE PARA AA/A9: El backend espera exactamente 2 caracteres hex para validar RBX=2
        if len(val_input) == 1: val_input = "0" + val_input
        elif len(val_input) > 2: val_input = val_input[-2:]

        # Se envía con salto de línea (\n = ASCII 10) para que el loop en ASM termine
        val_str = (val_input + "\n").encode('utf-8')
        num = f_hex_to_num(val_str)
        
        if num != -1:
            # Recuperamos el valor de RAX y formateamos el binario a 8 bits
            res = bin(num & 0xFF)[2:].zfill(8)
            self.lbl_op_secundaria.config(text=f"HEX: {val_input.upper()}")
            self.lbl_main.config(text=res)
            self.expresion = res
        else:
            messagebox.showerror("Error", "Entrada inválida (Máx 2 Hex)")

    # --- MÓDULOS ARITMÉTICO Y LÓGICO ---
    def setup_aritmetica(self):
        f = tk.Frame(self.tab_arit, bg="white")
        f.pack(pady=10)
        btns = [
            ('7', 0, 0), ('8', 0, 1), ('9', 0, 2), ('÷', 0, 3, "#ff9500"),
            ('4', 1, 0), ('5', 1, 1), ('6', 1, 2), ('×', 1, 3, "#ff9500"),
            ('1', 2, 0), ('2', 2, 1), ('3', 2, 2), ('-', 2, 3, "#ff9500"),
            ('C', 3, 0, "#eb4d4b"), ('0', 3, 1), ('=', 3, 2, "#4caf50"), ('+', 3, 3, "#ff9500")
        ]
        for b in btns: self.crear_btn(f, b, self.click_arit)

    def click_arit(self, char):
        if char == 'C': self.limpiar()
        elif char in ['+', '-', '×', '÷']:
            if self.expresion:
                self.operando1 = int(self.expresion)
                self.operacion_actual = char
                self.lbl_op_secundaria.config(text=f"{self.operando1} {char}")
                self.expresion = ""
        elif char == '=':
            if self.operando1 is not None and self.expresion:
                n2 = int(self.expresion)
                # Llamadas a funciones de arithmetic.asm
                if self.operacion_actual == '+': res = calc.asmSuma(self.operando1, n2)
                elif self.operacion_actual == '-': res = calc.asmResta(self.operando1, n2)
                elif self.operacion_actual == '×': res = calc.asmMultiplicacion(self.operando1, n2)
                elif self.operacion_actual == '÷': 
                    if n2 == 0: messagebox.showerror("Error", "División por cero"); return
                    res = calc.asmDivision(self.operando1, n2)
                self.lbl_main.config(text=str(res))
                self.expresion = str(res)
        else:
            self.expresion += char
            self.lbl_main.config(text=self.expresion)

    def setup_logica(self):
        f = tk.Frame(self.tab_log, bg="white")
        f.pack(pady=10)
        btns = [
            ('1', 0, 0), ('0', 0, 1), ('C', 0, 2, "#eb4d4b"),
            ('AND', 1, 0, "#3498db"), ('OR', 1, 1, "#3498db"), ('XOR', 1, 2, "#3498db"),
            ('NOT', 2, 0, "#9b59b6"), ('=', 2, 1, "#4caf50", 2)
        ]
        for b in btns: self.crear_btn(f, b, self.click_log, b[4] if len(b) > 4 else 1)

    def click_log(self, char):
        if char == 'C': self.limpiar()
        elif char in ['AND', 'OR', 'XOR']:
            if self.expresion:
                self.operando1 = int(self.expresion, 2)
                self.operacion_actual = char
                self.lbl_op_secundaria.config(text=f"{self.expresion} {char}")
                self.expresion = ""
        elif char == 'NOT':
            if self.expresion:
                # El resultado se lee de RAX con máscara de 4 bits
                res = calc.asmNot(int(self.expresion, 2)) & 0xF
                self.lbl_main.config(text=bin(res)[2:].zfill(4))
        elif char == '=':
            if self.operando1 is not None and self.expresion:
                n2 = int(self.expresion, 2)
                if self.operacion_actual == 'AND': res = calc.asmAnd(self.operando1, n2)
                elif self.operacion_actual == 'OR': res = calc.asmOr(self.operando1, n2)
                elif self.operacion_actual == 'XOR': res = calc.asmXor(self.operando1, n2)
                self.lbl_main.config(text=bin(res & 0xF)[2:].zfill(4))
        else:
            if char in '01' and len(self.expresion) < 4:
                self.expresion += char
                self.lbl_main.config(text=self.expresion)

    def crear_btn(self, parent, info, cmd, span=1):
        c = info[3] if len(info) > 3 else "white"
        f = "white" if len(info) > 3 else "black"
        b = tk.Button(parent, text=info[0], width=6 if span==1 else 14, height=2, 
                      font=("Arial", 12, "bold"), bg=c, fg=f, relief="flat", command=lambda: cmd(info[0]))
        b.grid(row=info[1], column=info[2], columnspan=span, padx=4, pady=4)

    def limpiar(self):
        self.expresion = ""; self.operando1 = None; self.operacion_actual = None
        self.lbl_main.config(text="0"); self.lbl_op_secundaria.config(text="")

if __name__ == "__main__":
    root = tk.Tk()
    CalculadoraEnsamblador(root)
    root.mainloop()