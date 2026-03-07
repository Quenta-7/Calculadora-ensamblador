/* conversion.js — Módulo de conversiones Binario ↔ Hexadecimal */

const Conversion = (() => {
    let mode = 'bin2hex';   // 'bin2hex' o 'hex2bin'
    let input = '';
    let lastResult = null;

    function getDisplay() {
        if (lastResult !== null) {
            const label = mode === 'bin2hex' ? 'BIN → HEX' : 'HEX → BIN';
            return { expr: `${label}: ${input}`, result: lastResult };
        }
        if (mode === 'bin2hex') {
            return { expr: 'Binario (8 bits)', result: input || '00000000' };
        }
        return { expr: 'Hexadecimal (2 dígitos)', result: input || '00' };
    }

    function pressKey(k) {
        lastResult = null;
        if (mode === 'bin2hex') {
            if ((k === '0' || k === '1') && input.length < 8) {
                input += k;
            }
        } else {
            if (/^[0-9A-Fa-f]$/.test(k) && input.length < 2) {
                input += k.toUpperCase();
            }
        }
    }

    function setMode(m) {
        mode = m;
        input = '';
        lastResult = null;
    }

    async function convert() {
        if (input === '') return;

        const opcode = mode === 'bin2hex' ? '9' : 'a';
        const padded = mode === 'bin2hex'
            ? input.padStart(8, '0')
            : input.padStart(2, '0');

        try {
            lastResult = await calcular(opcode, padded);
        } catch (e) {
            lastResult = 'Error';
            setStatus(e.message, true);
        }
    }

    function clear() {
        input = '';
        lastResult = null;
    }

    function render(container) {
        container.innerHTML = `
            <div class="btn-grid btn-grid-2" style="margin-bottom: 8px;">
                <button class="btn ${mode === 'bin2hex' ? 'btn-eq' : ''}" data-mode="bin2hex">BIN → HEX</button>
                <button class="btn ${mode === 'hex2bin' ? 'btn-eq' : ''}" data-mode="hex2bin">HEX → BIN</button>
            </div>
            <p class="limits">${mode === 'bin2hex' ? 'Ingrese binario de 8 bits' : 'Ingrese hexadecimal de 2 dígitos'}</p>
            ${mode === 'bin2hex' ? renderBinKeys() : renderHexKeys()}
            <div class="btn-grid btn-grid-2" style="margin-top: 8px;">
                <button class="btn btn-clear" data-action="clear">C</button>
                <button class="btn btn-eq" data-action="convert">Convertir</button>
            </div>
        `;

        container.addEventListener('click', async (e) => {
            const btn = e.target.closest('.btn');
            if (!btn) return;

            clearStatus();

            if (btn.dataset.mode) {
                setMode(btn.dataset.mode);
                render(container);
                updateDisplay();
                return;
            }
            if (btn.dataset.key !== undefined) {
                pressKey(btn.dataset.key);
            } else if (btn.dataset.action === 'convert') {
                await convert();
            } else if (btn.dataset.action === 'clear') {
                clear();
            }

            updateDisplay();
        });
    }

    function renderBinKeys() {
        return `
            <div class="btn-grid btn-grid-2">
                <button class="btn btn-num" data-key="0">0</button>
                <button class="btn btn-num" data-key="1">1</button>
            </div>
        `;
    }

    function renderHexKeys() {
        return `
            <div class="btn-grid btn-grid-4" style="margin-bottom: 4px;">
                <button class="btn btn-num" data-key="7">7</button>
                <button class="btn btn-num" data-key="8">8</button>
                <button class="btn btn-num" data-key="9">9</button>
                <button class="btn btn-num" data-key="A">A</button>
            </div>
            <div class="btn-grid btn-grid-4" style="margin-bottom: 4px;">
                <button class="btn btn-num" data-key="4">4</button>
                <button class="btn btn-num" data-key="5">5</button>
                <button class="btn btn-num" data-key="6">6</button>
                <button class="btn btn-num" data-key="B">B</button>
            </div>
            <div class="btn-grid btn-grid-4" style="margin-bottom: 4px;">
                <button class="btn btn-num" data-key="1">1</button>
                <button class="btn btn-num" data-key="2">2</button>
                <button class="btn btn-num" data-key="3">3</button>
                <button class="btn btn-num" data-key="C">C</button>
            </div>
            <div class="btn-grid btn-grid-4">
                <button class="btn btn-num" data-key="0">0</button>
                <button class="btn btn-num" data-key="D">D</button>
                <button class="btn btn-num" data-key="E">E</button>
                <button class="btn btn-num" data-key="F">F</button>
            </div>
        `;
    }

    return { render, getDisplay, clear };
})();
