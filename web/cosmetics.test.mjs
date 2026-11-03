import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { makeProfile, recordCowrie, equipSkin, sanitizeProfile } from './progression.mjs';
import { serializeTransfer, parseTransfer } from './transfer.mjs';

const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));
const allIds = plan.rooms.flatMap(room => room.cowries.map(shell => shell.id));

test('skins cannot be equipped until 105 unique physical cowrie discoveries', () => {
  const profile = makeProfile();
  assert.equal(equipSkin(profile, 'character', 'akane-ancestral'), false);
  assert.equal(equipSkin(profile, 'axe', 'axe-thunder'), false);
  assert.equal(equipSkin(profile, 'character', '__proto__'), false);
  for (const id of allIds.slice(0, 104)) recordCowrie(profile, id, plan);
  assert.equal(equipSkin(profile, 'axe', 'axe-thunder'), false);
  recordCowrie(profile, allIds[104], plan);
  assert.equal(equipSkin(profile, 'character', 'akane-ancestral'), true);
  assert.equal(equipSkin(profile, 'axe', 'axe-thunder'), true);
  assert.deepEqual(profile.cosmetics, { character: 'akane-ancestral', axe: 'axe-thunder' });
  assert.equal(equipSkin(profile, 'axe', 'axe-thunder'), false);
  assert.equal(equipSkin(profile, 'character', 'base'), true);
});

test('sanitization refuses forged cosmetics and accepts valid unlocked choices', () => {
  const fake = sanitizeProfile({ ...makeProfile(),
    cosmetics: { character: 'akane-ancestral', axe: 'axe-thunder' },
    skins: ['akane-ancestral', 'axe-thunder']
  }, plan);
  assert.deepEqual(fake.cosmetics, { character: 'base', axe: 'base' });

  const profile = makeProfile();
  for (const id of allIds) recordCowrie(profile, id, plan);
  equipSkin(profile, 'character', 'akane-ancestral');
  equipSkin(profile, 'axe', 'axe-thunder');
  const safe = sanitizeProfile(profile, plan);
  assert.deepEqual(safe.cosmetics, profile.cosmetics);
  assert.deepEqual(parseTransfer(serializeTransfer(profile, plan), plan).cosmetics, safe.cosmetics);
});

test('old profile data without cosmetics stays compatible', () => {
  const old = makeProfile();
  delete old.cosmetics;
  assert.deepEqual(sanitizeProfile(old, plan).cosmetics,
    { character: 'base', axe: 'base' });
});
