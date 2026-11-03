/** Real Chromium/Chrome smoke, without installing npm packages or drivers.
 * Requires Chrome preinstalled on the test runner. Exercises the canonical
 * hosted preview AND the standalone file:// browser distribution.
 */
import { spawn, spawnSync } from 'node:child_process';
import { readFileSync, writeFileSync, unlinkSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const root = dirname(fileURLToPath(import.meta.url));
const candidate = ['google-chrome', 'google-chrome-stable', 'chromium', 'chromium-browser'];
const chrome = candidate.map(name => {
  const found = spawnSync('which', [name], { encoding: 'utf8' });
  return found.status === 0 ? found.stdout.trim() : null;
}).find(Boolean);
if (!chrome) throw Error('Chrome/Chromium não encontrado no executor; teste de navegador não foi executado.');

const probe = `
<script>
window.addEventListener('load', () => {
  const finish = result => {
    document.documentElement.setAttribute('data-rasta-smoke', result);
    const pre = document.createElement('pre');
    pre.id = 'rasta-smoke-result';
    pre.textContent = result;
    document.body.append(pre);
  };
  setTimeout(() => {
    try {
      const start = document.querySelector('#startButton');
      if (!start || start.disabled) throw Error('game never booted');
      start.click();
      window.dispatchEvent(new KeyboardEvent('keydown', { code: 'KeyD', bubbles: true }));
      setTimeout(() => {
        window.dispatchEvent(new KeyboardEvent('keyup', { code: 'KeyD', bubbles: true }));
        document.querySelector('#pauseButton').click();
        const collected = document.querySelector('#shells')?.textContent || '';
        const skills = document.querySelector('#skillTree')?.children.length;
        const pause = document.querySelector('#pauseDialog')?.open;
        const hud = document.querySelector('#mana')?.textContent || '';
        const started = document.querySelector('#startOverlay')?.classList.contains('hidden');
        if (!collected.includes('1/5')) throw Error('first physical cowrie not collected: ' + collected);
        if (!pause) throw Error('pause menu did not open');
        if (skills !== 5) throw Error('skill branches missing: ' + skills);
        if (!hud.includes('MANA')) throw Error('mana HUD missing');
        if (!started) throw Error('start overlay did not close');
        finish('pass: start/move/cowrie/pause/skills/mana');
      }, 2100);
    } catch (e) { finish('fail: ' + e.message); }
  }, 1100);
});
</script>`;
const entry = '<script type="module" src="./main.mjs"></script>';
function inject(html, hosted) {
  if (!html.includes('</body>')) throw Error('HTML missing closing body');
  if (hosted) {
    if (!html.includes(entry)) throw Error('hosted entry unavailable');
    html = html.replace('<head>', '<head><base href="../">');
  }
  return html.replace('</body>', probe + '\n</body>');
}

function runChrome(url, label) {
  const options = [
    '--headless=new', '--no-sandbox', '--disable-gpu',
    '--disable-dev-shm-usage', '--allow-file-access-from-files',
    '--no-first-run', '--no-default-browser-check',
    '--virtual-time-budget=9500', '--dump-dom',
    '--user-data-dir=/tmp/rasta-smoke-' + label + '-' + process.pid,
    url,
  ];
  const outcome = spawnSync(chrome, options, {
    encoding: 'utf8', timeout: 60000, maxBuffer: 30 * 1024 * 1024,
  });
  const stdout = outcome.stdout || '';
  const passed = stdout.includes('data-rasta-smoke="pass: start/move/cowrie/pause/skills/mana"');
  const reported = stdout.match(/data-rasta-smoke="([^"]*)"/)?.[1] || '';
  if (!passed) {
    const details = (outcome.stderr || '').slice(-1100);
    throw Error(label + ': Chrome smoke did not pass; status=' + outcome.status +
      '; marker=' + reported + '; stderr=' + details);
  }
  console.log(label + ': browser smoke PASSED');
}

const offlinePath = join(root, 'dist', 'rasta-quest-offline.html');
if (!existsSync(offlinePath)) throw Error('Build offline bundle before browser smoke');
const standalonePath = join(root, 'dist', 'smoke-file.html');
const hostedPath = join(root, 'dist', 'smoke-hosted.html');
writeFileSync(standalonePath, inject(readFileSync(offlinePath, 'utf8'), false));
writeFileSync(hostedPath, inject(readFileSync(join(root, 'index.html'), 'utf8'), true));
const server = spawn(process.execPath, [join(root, 'serve.mjs')], { stdio: 'ignore' });
try {
  await new Promise(resolve => setTimeout(resolve, 1000));
  runChrome('http://127.0.0.1:4173/dist/smoke-hosted.html', 'hosted');
  runChrome('file://' + resolve(standalonePath), 'offline');
  const report = { status: 'passed', surfaces: ['http://localhost-preview', 'file://standalone'],
    checks: ['boot','movement','cowrie','pause','5 skill branches','mana HUD'] };
  writeFileSync(join(root, 'dist', 'browser-smoke-report.json'), JSON.stringify(report, null, 2));
} finally {
  server.kill('SIGTERM');
  try { unlinkSync(standalonePath); } catch {}
  try { unlinkSync(hostedPath); } catch {}
}
