import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const here = fileURLToPath(new URL('.', import.meta.url));
const read = path => readFileSync(here + path, 'utf8');
test('manifest supports standalone landscape web preview', () => {
  const manifest = JSON.parse(read('manifest.webmanifest'));
  assert.equal(manifest.short_name, 'Rasta Quest');
  assert.equal(manifest.orientation, 'landscape');
  assert.equal(manifest.display, 'standalone');
  assert.ok(manifest.icons.some(icon => icon.src === './app-icon.svg'));
});
test('HTML declares manifest and web UI remains a game canvas', () => {
  assert.match(read('index.html'), /rel="manifest"/);
  assert.match(read('index.html'), /id="game"/);
  assert.match(read('index.html'), /id="pauseDialog"/);
});
test('offline shell includes runtime and room data', () => {
  const worker = read('sw.js');
  for (const path of ['engine.mjs','progression.mjs','renderer.mjs','data/rooms.json','index.html']) {
    assert.ok(worker.includes(path), path);
  }
});

test('first successful service-worker install precaches all thirteen review sprites', () => {
  const worker = read('sw.js');
  const names = [
    'player-idle.png', 'player-run.png', 'player-jump.png',
    'player-attack.png', 'enemy-idle.png', 'enemy-attack.png',
    'portal.png', 'boss-forest.png', 'boss-castle.png',
    'boss-caves.png', 'terrain-forest.png', 'terrain-castle.png',
    'terrain-caves.png'
  ];
  for (const name of names) {
    assert.ok(worker.includes("'./assets/" + name + "'"), 'Missing offline sprite: ' + name);
    assert.ok(readFileSync(here + 'assets/' + name).byteLength > 0, 'Invalid sprite: ' + name);
  }
  assert.match(worker, /cache\.addAll\(SHELL\)/, 'install must cache complete shell');
  assert.match(worker, /rasta-quest-preview-20261121-v6/, 'offline cache needs a new version');
});
