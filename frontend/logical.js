/* logical.js — Módulo de operaciones lógicas (4 bits) */

const Logical = (() => {
    let binA = '';
    let binB = '';
    let op = null;        // '5'=AND, '6'=OR, '7'=NOT, '8'=XOR
    let editingB = false;
    let lastResult = null;

    const OP_NAMES = { '5': 'AND', '6': 'OR', '7': 'NOT', '8': 'XOR' };

    function getDisplay() {
        if (lastResult !== null) {
            const a = binA || '0000';
            const b = binB || '0000';
            const name = OP_NAMES[op] || '';
            const expr = op === '7'
                ? `NOT ${a}`
                : `${a} ${name} ${b}`;
            return { expr, result: lastResult };
        }
        if (op && editingB) {
            return {
                expr: `${binA || '0000'} ${OP_NAMES[op]}`,
                result: binB || '0000'
            };
        }
        return { expr: '', result: editingB ? binB || '0000' : binA || '0000' };
    }

    function pressBit(b) {
        lastResult = null;
        if (editingB) {
            if (binB.length < 4) binB += b;
        } else {
            if (binA.length < 4) binA += b;
        }
    }

    function pressOp(opcode) {
        lastResult = null;
        if (binA === '') binA = '0000';
        op = opcode;
        if (opcode === '7') {
            // NOT es unario — ejecutar inmediatamente
            executeNot();
            return;
        }
        editingB = true;
        binB = '';
    }

    async function executeNot() {
        const padded = binA.padStart(4, '0');
        try {
            lastResult = await calcular('7', padded);
        } catch (e) {
            lastResult = 'Error';
            setStatus(e.message, true);
        }
    }

    async function pressEquals() {
        if (!op || op === '7') return;
        if (binA === '') binA = '0000';
        if (binB === '') binB = '0000';
        const a = binA.padStart(4, '0');
        const b = binB.padStart(4, '0');

        try {
            lastResult = await calcular(op, a, b);
        } catch (e) {
            lastResult = 'Error';
            setStatus(e.message, true);
        }
    }

    function clear() {
        binA = '';
        binB = '';
        op = null;
        editingB = false;
        lastResult = null;
    }

    function render(container) {
        container.innerHTML = `
            <p class="limits">Operandos: 4 bits (0000 – 1111)</p>
            <div class="btn-grid btn-grid-2" style="margin-bottom: 8px;">
                <button class="btn btn-num" data-bit="0">0</button>
                <button class="btn btn-num" data-bit="1">1</button>
            </div>
            <p class="section-label">Operaciones</p>
            <div class="btn-grid btn-grid-4">
                <button class="btn btn-op" data-op="5">AND</button>
                <button class="btn btn-op" data-op="6">OR</button>
                <button class="btn btn-op" data-op="7">NOT</button>
                <button class="btn btn-op" data-op="8">XOR</button>
            </div>
            <div class="btn-grid btn-grid-2" style="margin-top: 8px;">
                <button class="btn btn-clear" data-action="clear">C</button>
                <button class="btn btn-eq" data-action="equals">=</button>
            </div>
        `;

        container.addEventListener('click', async (e) => {
            const btn = e.target.closest('.btn');
            if (!btn) return;

            clearStatus();

            if (btn.dataset.bit !== undefined) {
                pressBit(btn.dataset.bit);
            } else if (btn.dataset.op) {
                await pressOp(btn.dataset.op);
            } else if (btn.dataset.action === 'equals') {
                await pressEquals();
            } else if (btn.dataset.action === 'clear') {
                clear();
            }

            updateDisplay();
            updateOpHighlight(container);
        });
    }

    function updateOpHighlight(container) {
        container.querySelectorAll('.btn-op').forEach(b => b.classList.remove('selected'));
        if (op && editingB && lastResult === null) {
            const active = container.querySelector(`.btn-op[data-op="${op}"]`);
            if (active) active.classList.add('selected');
        }
    }

    return { render, getDisplay, clear };
})();
