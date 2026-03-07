/* app.js — Controlador principal de la calculadora */

const modules = {
    arithmetic: Arithmetic,
    logical: Logical,
    conversion: Conversion
};

let activeModule = 'arithmetic';

const $display = {
    expr: document.getElementById('display-expr'),
    result: document.getElementById('display-result'),
};
const $panels = {
    arithmetic: document.getElementById('panel-arithmetic'),
    logical: document.getElementById('panel-logical'),
    conversion: document.getElementById('panel-conversion'),
};
const $tabs = document.querySelectorAll('.tab');
const $status = document.getElementById('status');

/* --- Funciones globales usadas por los módulos --- */

function updateDisplay() {
    const info = modules[activeModule].getDisplay();
    $display.expr.textContent = info.expr;
    $display.result.textContent = info.result;
}

function setStatus(msg, isError) {
    $status.textContent = msg;
    $status.className = isError ? 'status error' : 'status';
}

function clearStatus() {
    $status.textContent = '';
    $status.className = 'status';
}

/* --- Navegación entre pestañas --- */

function switchTab(name) {
    if (activeModule === name) return;

    // Limpiar estado anterior
    modules[activeModule].clear();

    activeModule = name;

    // Tabs
    $tabs.forEach(t => {
        t.classList.toggle('active', t.dataset.tab === name);
    });

    // Paneles
    Object.keys($panels).forEach(k => {
        $panels[k].classList.toggle('active', k === name);
    });

    clearStatus();
    updateDisplay();
}

/* --- Inicialización --- */

$tabs.forEach(tab => {
    tab.addEventListener('click', () => switchTab(tab.dataset.tab));
});

// Renderizar cada módulo en su panel
Arithmetic.render($panels.arithmetic);
Logical.render($panels.logical);
Conversion.render($panels.conversion);

// Display inicial
updateDisplay();
