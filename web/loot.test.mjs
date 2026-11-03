import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { chestsForRoom, EQUIPMENT, discoverEquipment, equipEquipment, sanitizeEquipment, equipmentStat } from './loot.mjs';
import { makeProfile, sanitizeProfile } from './progression.mjs';
const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));
test('all 21 rooms receive common chests; three deliberate rare chests require elevated approach', () => {
  let rare = 0;
  for (const room of plan.rooms) {
    const chests = chestsForRoom(room, 960, 460);
    assert.ok(chests.some(c=>c.kind==='common'));
    assert.ok(chests.every(c=>c.x > 0 && c.x < room.planned_camera_widths*960));
    for (const chest of chests.filter(c=>c.kind==='rare')) {
      rare++;
      assert.ok(Object.hasOwn(EQUIPMENT, chest.reward));
      assert.ok(chest.y < 460 - 70);
    }
  }
  assert.equal(rare, 3);
});
test('rare equipment is unique, persistent and cannot be equipped before discovery', () => {
  const p = makeProfile();
  assert.equal(equipEquipment(p, 'ogum-metal'), false);
  assert.equal(discoverEquipment(p, 'ogum-metal'), true);
  assert.equal(discoverEquipment(p, 'ogum-metal'), false);
  assert.equal(equipmentStat(p, 'blade'), 'ogum-metal');
  assert.equal(discoverEquipment(p, 'not-an-item'), false);
  assert.equal(sanitizeProfile(p, plan).equipped.blade, 'ogum-metal');
});
test('invalid equipment slots and forged equipment IDs are ignored', () => {
  const p = sanitizeEquipment(['ogum-metal','fake','ogum-metal','oak-haft'], { blade:'oak-haft', haft:'fake', boots:'iansa-boots' });
  assert.deepEqual(p.items, ['oak-haft','ogum-metal']);
  assert.deepEqual(p.equipped,{ haft:null, blade:null, boots:null });
});
