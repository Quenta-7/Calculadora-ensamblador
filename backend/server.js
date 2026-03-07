const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const PORT = 3000;
const ROOT = path.resolve(__dirname, '..');
const FRONTEND = path.join(ROOT, 'frontend');

function toWslPath(winPath) {
    return winPath
        .replace(/\\/g, '/')
        .replace(/^([A-Za-z]):/, (_, d) => `/mnt/host/${d.toLowerCase()}`);
}

const API_BINARY = toWslPath(path.join(ROOT, 'backend', 'calculadora_api'));

const MIME = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.css': 'text/css; charset=utf-8',
    '.ico': 'image/x-icon',
    '.svg': 'image/svg+xml',
    '.png': 'image/png',
};

const VALID_OPCODES = new Set(['1','2','3','4','5','6','7','8','9','a','A']);

function isValidArg(arg) {
    return typeof arg === 'string' && /^[0-9A-Fa-f]{0,12}$/.test(arg);
}

const server = http.createServer((req, res) => {
    if (req.method === 'POST' && req.url === '/api/calculate') {
        let body = '';
        req.on('data', chunk => {
            body += chunk;
            if (body.length > 1024) { res.writeHead(413); res.end(); req.destroy(); }
        });
        req.on('end', () => {
            try {
                const { opcode, arg1, arg2 } = JSON.parse(body);

                if (!VALID_OPCODES.has(opcode)) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    return res.end(JSON.stringify({ error: 'Operación inválida' }));
                }
                if (!isValidArg(arg1 || '')) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    return res.end(JSON.stringify({ error: 'Argumento 1 inválido' }));
                }
                if (arg2 !== undefined && arg2 !== '' && !isValidArg(arg2)) {
                    res.writeHead(400, { 'Content-Type': 'application/json' });
                    return res.end(JSON.stringify({ error: 'Argumento 2 inválido' }));
                }

                let input = opcode + '\n' + (arg1 || '') + '\n';
                if (arg2) input += arg2 + '\n';

                const proc = spawn('wsl', [API_BINARY], { timeout: 5000 });
                let stdout = '';

                proc.stdout.on('data', d => { stdout += d.toString(); });
                proc.on('close', code => {
                    const result = stdout.trim();
                    res.writeHead(200, { 'Content-Type': 'application/json' });
                    if (result === 'ERROR' || code !== 0) {
                        res.end(JSON.stringify({ error: result || 'Error en ASM' }));
                    } else {
                        res.end(JSON.stringify({ result }));
                    }
                });
                proc.on('error', () => {
                    res.writeHead(500, { 'Content-Type': 'application/json' });
                    res.end(JSON.stringify({ error: 'No se pudo ejecutar el binario ASM' }));
                });
                proc.stdin.write(input);
                proc.stdin.end();
            } catch {
                res.writeHead(400, { 'Content-Type': 'application/json' });
                res.end(JSON.stringify({ error: 'JSON inválido' }));
            }
        });
        return;
    }

    // Archivos estáticos
    let urlPath = req.url.split('?')[0];
    if (urlPath === '/') urlPath = '/index.html';

    const safePath = path.normalize(urlPath).replace(/^(\.\.(\/|\\|$))+/, '');
    const fullPath = path.join(FRONTEND, safePath);

    if (!fullPath.startsWith(FRONTEND)) {
        res.writeHead(403);
        return res.end();
    }

    fs.readFile(fullPath, (err, data) => {
        if (err) {
            res.writeHead(404);
            return res.end('No encontrado');
        }
        const ext = path.extname(fullPath);
        res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' });
        res.end(data);
    });
});

server.listen(PORT, () => {
    console.log('');
    console.log('  Calculadora ASM x86-64');
    console.log(`  http://localhost:${PORT}`);
    console.log('');
    console.log('  Frontend: JS + CSS');
    console.log('  Backend:  Ensamblador x86-64 (NASM)');
    console.log('');
});
