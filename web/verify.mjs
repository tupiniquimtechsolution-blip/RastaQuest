import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { join, dirname } from 'node:path';
import { validatePlan } from './engine.mjs';

const here = dirname(fileURLToPath(import.meta.url));
const preview = JSON.parse(readFileSync(join(here, 'data', 'rooms.json'), 'utf8'));
const repoCanonical = join(here, '..', 'docs', 'production', 'room_blockouts', 'ROOM_BLOCKOUTS_V1.json');
const localCanonical = join(here, '..', 'canonical', 'ROOM_BLOCKOUTS_V1.json');
const canonicalPath = existsSync(repoCanonical) ? repoCanonical : localCanonical;
const canonical = JSON.parse(readFileSync(canonicalPath, 'utf8'));
assert.deepEqual(preview, canonical, 'A cópia web das salas deve espelhar o plano canônico do PR #87.');
validatePlan(preview);

const requiredAssets = [
  'player-idle.png', 'player-run.png', 'player-jump.png', 'player-attack.png',
  'enemy-idle.png', 'enemy-attack.png', 'portal.png', 'boss-forest.png',
  'boss-castle.png', 'boss-caves.png', 'terrain-forest.png',
  'terrain-castle.png', 'terrain-caves.png',
];
for (const asset of requiredAssets) {
  assert.ok(existsSync(join(here, 'assets', asset)), `Sprite ausente: ${asset}`);
}
console.log('OK: 21 salas, 105 búzios, plano sincronizado e 13 sprites presentes.');
