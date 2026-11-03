import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { makeProfile, sanitizeProfile, loadProfile, saveProfile, recordCowrie,
  awardEssence, upgradeCost, purchaseUpgrade, awardEquipment, equipItem, SKIN_REWARDS } from './progression.mjs';
const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));
const ids = plan.rooms.flatMap(room => room.cowries.map(cowrie => cowrie.id));

test('recording 105 unique cowrie IDs unlocks both cosmetic rewards only at 100%', () => {
  const p = makeProfile();
  assert.equal(recordCowrie(p, 'fake-shell', plan), false);
  for (const id of ids.slice(0, 104)) assert.equal(recordCowrie(p, id, plan), true);
  assert.deepEqual(p.skins, []);
  assert.equal(recordCowrie(p, ids[104], plan), true);
  assert.deepEqual(p.skins, SKIN_REWARDS);
  assert.equal(recordCowrie(p, ids[104], plan), false);
  assert.equal(p.collectedCowries.length, 105);
});

test('invalid, forged, old or duplicated saved data cannot mint skins', () => {
  const p = sanitizeProfile({ version: 1, collectedCowries: [ids[0], ids[0], 'forged'],
    essence: -20, skins: ['axe-thunder'], upgrades: { vitality: 80, strength: 2, mobility: -1 } }, plan);
  assert.equal(p.collectedCowries.length, 1);
  assert.deepEqual(p.skins, []);
  assert.equal(p.essence, 0);
  assert.deepEqual(p.upgrades, { vitality: 0, strength: 2, mobility: 0, spirit: 0 });
  assert.deepEqual(sanitizeProfile({ version: 999, collectedCowries: ids }, plan), makeProfile());
});

test('essence purchase costs grow and upgrade has a hard cap', () => {
  const p = makeProfile();
  assert.equal(awardEssence(p, -2), false);
  assert.equal(awardEssence(p, 500), true);
  for (let level = 0; level < 5; level++) {
    assert.equal(upgradeCost(p, 'vitality'), 15 + level * 15);
    assert.equal(purchaseUpgrade(p, 'vitality'), true);
  }
  assert.equal(upgradeCost(p, 'vitality'), null);
  assert.equal(purchaseUpgrade(p, 'vitality'), false);
  assert.equal(p.upgrades.vitality, 5);
  assert.equal(purchaseUpgrade(p, '__proto__'), false);
});

test('localStorage failures are nonfatal and valid data round-trips', () => {
  const data = new Map();
  const storage = { getItem: k => data.get(k) ?? null, setItem: (k,v) => data.set(k,v) };
  const p = makeProfile(); recordCowrie(p, ids[0], plan); awardEssence(p, 25);
  assert.equal(saveProfile(storage, p), true);
  assert.deepEqual(loadProfile(storage, plan), p);
  assert.equal(saveProfile({ setItem() { throw new Error('denied'); } }, p), false);
  assert.deepEqual(loadProfile({ getItem() { throw new Error('denied'); } }, plan), makeProfile());
});


test('equipment is awarded once and only owned equipment can be selected', () => {
  const p = makeProfile();
  assert.equal(awardEquipment(p, 'fake-rare'), false);
  assert.equal(equipItem(p,'castle-02'),false);
  assert.equal(awardEquipment(p,'castle-02'),true);
  assert.equal(awardEquipment(p,'castle-02'),false);
  assert.equal(p.equipment.equipped.boots,'castle-02');
  assert.equal(awardEquipment(p,'forest-05'),true);
  assert.equal(equipItem(p,'forest-05'),true);
  assert.equal(p.equipment.equipped.boots,'forest-05');
  assert.deepEqual(sanitizeProfile(p,plan),p);
  const forged = sanitizeProfile({...p,equipment:{owned:['forest-05','bogus'],equipped:{boots:'bogus',blade:'castle-02'}}},plan);
  assert.deepEqual(forged.equipment.owned,['forest-05']);
  assert.equal(forged.equipment.equipped.boots,null);
  assert.equal(forged.equipment.equipped.blade,null);
});
