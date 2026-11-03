import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, statSync } from 'node:fs';
const bundled = readFileSync(new URL('./dist/rasta-quest-offline.html', import.meta.url), 'utf8');
test('offline preview has no external runtime dependencies and includes all three biomes', () => {
  assert.match(bundled, /<canvas id="game"/);
  assert.match(bundled, /forest-01/);
  assert.match(bundled, /castle-07/);
  assert.match(bundled, /caves-07/);
  assert.match(bundled, /Raízes do Trovão/);
  assert.match(bundled, /defesa_5/);
  assert.equal(bundled.includes("fetch('./data/skills.json"), false);
  assert.match(bundled, /data:image\/png;base64,/);
  assert.doesNotMatch(bundled, /<script[^>]+src=/);
  assert.doesNotMatch(bundled, /<link[^>]+stylesheet/);
  assert.doesNotMatch(bundled, /fetch\(['"]\.\/data\/rooms\.json/);
  assert.doesNotMatch(bundled, /serviceWorker\.register\(/);
});
test('single file includes all essential UI and encoded sprites', () => {
  assert.match(bundled, /id="pauseDialog"/);
  assert.match(bundled, /id="game"/);
  assert.match(bundled, /id="mana"/);
  assert.match(bundled, /data-control="special"/);
  assert.ok(statSync(new URL('./dist/rasta-quest-offline.html', import.meta.url)).size > 100_000);
});
