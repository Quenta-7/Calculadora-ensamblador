/* api.js — Comunicación con el backend ASM */

/**
 * Envía una operación al backend ASM y devuelve el resultado.
 * @param {string} opcode — Código de operación (1-9, a)
 * @param {string} arg1 — Primer argumento
 * @param {string} [arg2] — Segundo argumento (opcional para NOT)
 * @returns {Promise<string>} — Resultado de la operación
 */
async function calcular(opcode, arg1, arg2) {
    const resp = await fetch('/api/calculate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ opcode, arg1, arg2: arg2 || '' }),
    });

    const data = await resp.json();

    if (data.error) throw new Error(data.error);
    return data.result;
}
