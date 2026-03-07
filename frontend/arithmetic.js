/* arithmetic.js — Módulo de calculadora aritmética (0-99) */

const Arithmetic = (() => {
    let num1 = '';
    let num2 = '';
    let op = null;         // '1'=+, '2'=-, '3'=×, '4'=÷
    let enteringSecond = false;
    let lastResult = null;

    const OP_SYMBOLS = { '1': '+', '2': '−', '3': '×', '4': '÷' };

    function current() {
        return enteringSecond ? num2 : num1;
    }

    function setCurrent(val) {
        if (enteringSecond) num2 = val;
        else num1 = val;
    }

    function getDisplay() {
        if (lastResult !== null) {
            const expr = `${num1} ${OP_SYMBOLS[op] || ''} ${num2}`;
            return { expr: expr.trim(), result: lastResult };
        }
        if (op && enteringSecond) {
            return {
                expr: `${num1} ${OP_SYMBOLS[op]}`,
                result: num2 || '0'
            };
        }
        return { expr: '', result: num1 || '0' };
    }

    function pressDigit(d) {
        lastResult = null;
        const cur = current();
        if (cur.length >= 2) return;
        setCurrent(cur + d);
    }

    function pressOp(opcode) {
        lastResult = null;
        if (num1 === '') num1 = '0';
        op = opcode;
        enteringSecond = true;
        num2 = '';
    }

    async function pressEquals() {
        if (!op || num1 === '') return;
        if (num2 === '') num2 = '0';

        try {
            const rawResult = await calcular(op, num1, num2);
            if (op === '4') {
                const parts = rawResult.split(',');
                lastResult = parts.length === 2
                    ? `${parts[0]} R ${parts[1]}`
                    : rawResult;
            } else {
                lastResult = rawResult;
            }
        } catch (e) {
            lastResult = 'Error';
            setStatus(e.message, true);
        }
    }

    function clear() {
        num1 = '';
        num2 = '';
        op = null;
        enteringSecond = false;
        lastResult = null;
    }

    function render(container) {
        container.innerHTML = `
            <p class="limits">Operandos: 0 – 99</p>
            <div class="btn-grid btn-grid-4">
                <button class="btn btn-num" data-digit="7">7</button>
                <button class="btn btn-num" data-digit="8">8</button>
                <button class="btn btn-num" data-digit="9">9</button>
                <button class="btn btn-op" data-op="4">÷</button>

                <button class="btn btn-num" data-digit="4">4</button>
                <button class="btn btn-num" data-digit="5">5</button>
                <button class="btn btn-num" data-digit="6">6</button>
                <button class="btn btn-op" data-op="3">×</button>

                <button class="btn btn-num" data-digit="1">1</button>
                <button class="btn btn-num" data-digit="2">2</button>
                <button class="btn btn-num" data-digit="3">3</button>
                <button class="btn btn-op" data-op="2">−</button>

                <button class="btn btn-clear" data-action="clear">C</button>
                <button class="btn btn-num" data-digit="0">0</button>
                <button class="btn btn-eq" data-action="equals">=</button>
                <button class="btn btn-op" data-op="1">+</button>
            </div>
        `;

        container.addEventListener('click', async (e) => {
            const btn = e.target.closest('.btn');
            if (!btn) return;

            clearStatus();

            if (btn.dataset.digit !== undefined) {
                pressDigit(btn.dataset.digit);
            } else if (btn.dataset.op) {
                pressOp(btn.dataset.op);
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
        if (op && enteringSecond && lastResult === null) {
            const active = container.querySelector(`.btn-op[data-op="${op}"]`);
            if (active) active.classList.add('selected');
        }
    }

    return { render, getDisplay, clear };
})();
