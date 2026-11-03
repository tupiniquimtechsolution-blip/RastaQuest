/** E2E Chrome smoke against real hosted and self-contained browser surfaces.
 * Pure Node 22 + Chrome DevTools Protocol (no npm or DOM injection).
 */
import { spawn, spawnSync } from 'node:child_process';
import { mkdtempSync, readFileSync, writeFileSync, rmSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { fileURLToPath } from 'node:url';
import { dirname, join, resolve } from 'node:path';

const root = dirname(fileURLToPath(import.meta.url));
const binary = ['google-chrome', 'google-chrome-stable', 'chromium', 'chromium-browser']
  .map(name => { const r = spawnSync('which', [name], { encoding: 'utf8' }); return r.status === 0 ? r.stdout.trim() : ''; })
  .find(Boolean);
if (!binary) throw Error('Chrome/Chromium is required for real browser QA; CI cannot claim pass without it.');
const sleep = ms => new Promise(resolve => setTimeout(resolve, ms));

async function until(fn, description, timeoutMs = 25000) {
  const start = Date.now();
  let recent = '';
  while (Date.now() - start < timeoutMs) {
    try {
      const value = await fn();
      if (value) return value;
    } catch (error) { recent = String(error); }
    await sleep(150);
  }
  throw Error('Timed out: ' + description + (recent ? ' (' + recent + ')' : ''));
}

async function startBrowser() {
  const dataDir = mkdtempSync(join(tmpdir(), 'rq-browser-'));
  const args = ['--headless=new', '--no-sandbox', '--disable-gpu',
    '--disable-dev-shm-usage', '--allow-file-access-from-files',
    '--remote-allow-origins=*', '--remote-debugging-port=0',
    '--no-first-run', '--no-default-browser-check', '--user-data-dir=' + dataDir,
    'about:blank'];
  const child = spawn(binary, args, { stdio: 'ignore' });
  try {
    const port = await until(() => {
      if (child.exitCode !== null) throw Error('Chrome exited: ' + child.exitCode);
      const path = join(dataDir, 'DevToolsActivePort');
      if (!existsSync(path)) return null;
      return Number(readFileSync(path, 'utf8').split('\n')[0]);
    }, 'Chrome debugger startup');
    const tabs = await (await fetch('http://127.0.0.1:' + port + '/json/list')).json();
    const target = tabs.find(tab => tab.type === 'page');
    if (!target?.webSocketDebuggerUrl) throw Error('Chrome page target missing');
    const socket = new WebSocket(target.webSocketDebuggerUrl);
    await new Promise((ok, fail) => {
      socket.addEventListener('open', ok, { once: true });
      socket.addEventListener('error', fail, { once: true });
    });
    let nextId = 0;
    const outstanding = new Map();
    const exceptions = [];
    socket.addEventListener('message', event => {
      const msg = JSON.parse(event.data);
      if (msg.method === 'Runtime.exceptionThrown') {
        exceptions.push(msg.params?.exceptionDetails?.text ?? 'unhandled JS error');
      }
      if (!msg.id || !outstanding.has(msg.id)) return;
      const { resolve, reject } = outstanding.get(msg.id);
      outstanding.delete(msg.id);
      msg.error ? reject(Error(JSON.stringify(msg.error))) : resolve(msg.result);
    });
    function send(method, params = {}) {
      return new Promise((resolve, reject) => {
        if (socket.readyState !== WebSocket.OPEN) return reject(Error('Chrome disconnected'));
        const id = ++nextId;
        outstanding.set(id, { resolve, reject });
        socket.send(JSON.stringify({ id, method, params }));
      });
    }
    await send('Page.enable');
    await send('Runtime.enable');
    return {
      exceptions, send, async eval(expression) {
        const answer = await send('Runtime.evaluate', { expression, returnByValue: true,
          awaitPromise: true, userGesture: true });
        if (answer.exceptionDetails) {
          throw Error('Page JS: ' + (answer.exceptionDetails.exception?.description || answer.exceptionDetails.text));
        }
        return answer.result?.value;
      },
      async navigate(url) {
        const reply = await send('Page.navigate', { url });
        if (reply.errorText) throw Error('Navigation failed: ' + reply.errorText + ' at ' + url);
        await until(async () => (await this.eval('document.readyState')) === 'complete',
          'page load: ' + url);
      },
      async close() {
        socket.close();
        child.kill('SIGTERM');
        await sleep(400);
        try { rmSync(dataDir, { recursive: true, force: true }); } catch {}
      }
    };
  } catch (error) {
    child.kill('SIGTERM');
    await sleep(300);
    try { rmSync(dataDir, { recursive: true, force: true }); } catch {}
    throw error;
  }
}

async function smoke(page, url, name) {
  await page.navigate(url);
  await until(async () => page.eval('Boolean(document.querySelector("#startButton") && !document.querySelector("#startButton").disabled && document.querySelector("#routeTrack")?.children.length === 21)'),
    name + ': game boot');
  await page.eval('document.querySelector("#startButton").click()');
  const x0 = await page.eval('document.querySelector("#shells")?.textContent');
  await page.send('Input.dispatchKeyEvent', { type: 'keyDown', key: 'd', code: 'KeyD', windowsVirtualKeyCode: 68 });
  try { await until(async () => String(await page.eval('document.querySelector("#shells")?.textContent')).includes('1/5'),
      name + ': physically collect first cowrie', 8500); }
  finally { await page.send('Input.dispatchKeyEvent', { type: 'keyUp', key: 'd', code: 'KeyD', windowsVirtualKeyCode: 68 }); }
  await page.eval('document.querySelector("#pauseButton").click()');
  await until(async () => page.eval('document.querySelector("#skillTree")?.children.length === 5'),
    name + ': canonical skill tree');
  const observed = await page.eval(`({
    running: document.querySelector("#startOverlay")?.classList.contains("hidden"),
    shell: document.querySelector("#shells")?.textContent,
    mana: document.querySelector("#mana")?.textContent,
    pause: document.querySelector("#pauseDialog")?.open,
    skills: document.querySelector("#skillTree")?.children.length,
    room: document.querySelector("#roomName")?.textContent
  })`);
  if (!observed.running || !observed.pause || !String(observed.shell).includes('1/5') ||
      !String(observed.mana).includes('MANA') || observed.skills !== 5) {
    throw Error(name + ': gameplay assertion failed ' + JSON.stringify({ before: x0, observed }));
  }
  console.log(name + ': PASSED ' + JSON.stringify(observed));
  return observed;
}

async function smokeMobile(page) {
  await page.eval('localStorage.clear()');
  await page.send('Emulation.setDeviceMetricsOverride', {
    width: 844, height: 390, deviceScaleFactor: 2, mobile: true, screenWidth: 844, screenHeight: 390
  });
  await page.send('Emulation.setTouchEmulationEnabled', { enabled: true, maxTouchPoints: 5 });
  try {
    await page.navigate('http://127.0.0.1:4173/');
    await until(async () => page.eval('Boolean(document.querySelector("#startButton") && !document.querySelector("#startButton").disabled && document.querySelector("#routeTrack")?.children.length === 21)'),
      'mobile landscape: boot');
    const layout = await page.eval(`({
      inner: window.innerWidth,
      scroll: document.documentElement.scrollWidth,
      controlVisible: getComputedStyle(document.querySelector(".touch-controls")).display !== "none",
      controls: document.querySelectorAll(".touch-controls button[data-control]").length
    })`);
    if (layout.scroll > layout.inner + 2 || !layout.controlVisible || layout.controls < 5) {
      throw Error('Landscape touch layout fails: ' + JSON.stringify(layout));
    }
    await page.eval('document.querySelector("#startButton").click()');
    const target = await page.eval(`(() => {
      const button = document.querySelector('[data-control="right"]');
      button.scrollIntoView({ block: 'center', inline: 'center' });
      const r = button.getBoundingClientRect();
      return { x: Math.round((r.left + r.right) / 2), y: Math.round((r.top + r.bottom) / 2) };
    })()`);
    await page.send('Input.dispatchTouchEvent', { type: 'touchStart',
      touchPoints: [{ x: target.x, y: target.y, id: 1 }] });
    try {
      await until(async () => String(await page.eval('document.querySelector("#shells")?.textContent')).includes('1/5'),
        'mobile touch: collect first physical cowrie', 8500);
    } finally {
      await page.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    }
    const observed = await page.eval(`({
      shell: document.querySelector("#shells")?.textContent,
      controls: getComputedStyle(document.querySelector(".touch-controls")).display,
      screenWidth: innerWidth,
      scrollWidth: document.documentElement.scrollWidth
    })`);
    console.log('mobile-landscape: PASSED ' + JSON.stringify(observed));
    return observed;
  } finally {
    await page.send('Emulation.clearDeviceMetricsOverride');
    await page.send('Emulation.setTouchEmulationEnabled', { enabled: false });
  }
}

const offline = join(root, 'dist', 'rasta-quest-offline.html');
if (!existsSync(offline)) throw Error('Build web/dist/rasta-quest-offline.html before browser smoke.');
const server = spawn(process.execPath, [join(root, 'serve.mjs'), '4173'], { stdio: 'ignore' });
let chrome;
try {
  await until(async () => {
    try { return (await fetch('http://127.0.0.1:4173/')).ok; }
    catch { return false; }
  }, 'local HTTP preview server');
  chrome = await startBrowser();
  const hosted = await smoke(chrome, 'http://127.0.0.1:4173/', 'hosted');
  const mobile = await smokeMobile(chrome);
  const file = await smoke(chrome, 'file://' + resolve(offline), 'offline');
  const report = { status: 'passed', executed_at: new Date().toISOString(), chrome: binary,
    checks: ['boot', 'movement', 'first cowrie', 'pause', 'five canonical skill branches', 'mana HUD'],
    hosted, mobile, offline: file };
  writeFileSync(join(root, 'dist', 'browser-smoke-report.json'), JSON.stringify(report, null, 2));
} catch (error) {
  console.error('E2E browser smoke FAILED:', error.message);
  console.error('Chrome page errors:', JSON.stringify(chrome?.exceptions ?? []));
  throw error;
} finally {
  if (chrome) await chrome.close();
  server.kill('SIGTERM');
}
