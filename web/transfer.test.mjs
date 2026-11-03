import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { makeProfile } from './progression.mjs';
import { MAX_PROFILE_BYTES, serializeTransfer, parseTransfer } from './transfer.mjs';
const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));

test('transfer file can move validated cowrie album, essence and equipment between devices', () => {
  const profile = makeProfile();
  profile.collectedCowries = [plan.rooms[0].cowries[0].id, plan.rooms[10].cowries[2].id];
  profile.essence = 85;
  profile.items = ['oak-haft'];
  profile.equipped.haft = 'oak-haft';
  profile.upgrades.mobility = 2;
  const exported = serializeTransfer(profile, plan);
  assert.ok(exported.length < MAX_PROFILE_BYTES);
  assert.deepEqual(parseTransfer(exported, plan), profile);
  assert.equal(exported.includes('password'), false);
});

test('invalid transfer files and dishonest skin/equipment entries are not trusted', () => {
  for(const bad of ['', '{', ' '.repeat(MAX_PROFILE_BYTES+1), '{"format":"other"}']) {
    assert.throws(()=>parseTransfer(bad, plan));
  }
  const source = makeProfile();
  source.collectedCowries = [plan.rooms[0].cowries[0].id, 'forged'];
  source.skins = ['axe-thunder'];
  source.items = ['hacked'];
  source.equipped.blade = 'hacked';
  const clean = parseTransfer(serializeTransfer(source, plan), plan);
  assert.equal(clean.collectedCowries.length, 1);
  assert.deepEqual(clean.skins, []);
  assert.deepEqual(clean.items, []);
  assert.equal(clean.equipped.blade, null);
});
