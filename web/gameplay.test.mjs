import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, step, GROUND_Y } from './engine.mjs';
import { makeProfile, awardEquipment } from './progression.mjs';
import { EQUIPMENT, buildChests, buildRings } from './content.mjs';

const plan=JSON.parse(readFileSync(new URL('./data/rooms.json',import.meta.url),'utf8'));
function advance(game) {
  game.enemies.forEach(e => e.alive=false);
  game.player.x=game.exit.x-10;game.player.y=GROUND_Y-game.player.h;
  step(game,{interact:true},1/60);
  step(game,{interact:false},1/60);
}

test('21 original room concepts map to 21 rare equipment items, reachable chests and rings', () => {
  assert.equal(Object.keys(EQUIPMENT).length,21);
  for(const room of plan.rooms) {
    const chests=buildChests(room),rings=buildRings(room);
    assert.equal(chests.length,2);
    assert.equal(rings.length,2);
    assert.equal(chests[1].equipmentId,room.id);
    assert.ok(chests[0].x>100 && chests[0].x < room.planned_camera_widths*960);
    const x=room.cowries[3].approx_screen*960;
    assert.ok(Math.abs(chests[1].x-x)<138,'rare chest is on fourth cowrie high route');
    assert.ok(chests[1].x<room.planned_camera_widths*960);
    assert.ok(EQUIPMENT[room.id]?.name.length>3);
  }
});

test('common chest restores health, secret chest grants permanent gear exactly once', () => {
  const profile=makeProfile(),g=createGame(plan,profile);
  const common=g.chests.find(x=>x.kind==='common');
  g.player.hp=1;g.player.x=common.x;g.player.y=common.y;
  step(g,{interact:true},1/60);
  assert.equal(common.opened,true);
  assert.equal(g.player.hp,3);
  step(g,{interact:false},1/60);
  const rare=g.chests.find(x=>x.kind==='rare');
  g.player.x=rare.x;g.player.y=rare.y;
  step(g,{interact:true},1/60);
  assert.equal(rare.opened,true);
  assert.ok(profile.equipment.owned.includes('forest-01'));
  assert.equal(profile.equipment.equipped.haft,'forest-01');
  assert.equal(g.profileRevision,1);
});

test('special axe consumes mana and drops essence after enemy defeat', () => {
  const profile=makeProfile(),g=createGame(plan,profile),e=g.enemies[0];
  g.player.x=e.x-g.player.w-8;g.player.y=e.y;
  e.cooldown=99;e.speed=0;
  const before=g.player.mana;
  step(g,{special:true},1/60);
  assert.equal(g.player.mana,before-1);
  assert.equal(e.alive,false);
  assert.equal(profile.essence,5);
  g.player.attackCooldown=0;g.player.mana=0;
  step(g,{special:true},1/60);
  assert.equal(g.player.mana,0);
  assert.equal(profile.essence,5);
});

test('boss telegraphs first hit, enters phase two and is not a regular patrol attack', () => {
  const g=createGame(plan);
  for(let i=0;i<6;i++) advance(g);
  assert.equal(g.room.boss_room,true);
  const boss=g.enemies.find(e=>e.boss);
  g.player.x=boss.x-100;
  g.player.y=GROUND_Y-g.player.h;
  g.player.invuln=0;boss.speed=0;boss.cooldown=0;
  const hp=g.player.hp;
  step(g,{},1/60);
  assert.equal(g.player.hp,hp,'telegraphed attack does not strike instantly');
  assert.ok(boss.windup>0);
  for(let i=0;i<49;i++) step(g,{},1/60);
  assert.ok(g.player.hp<hp,'boss hit after windup');
  boss.hp=4;boss.cooldown=0;boss.windup=0;
  step(g,{},1/60);
  assert.equal(boss.phase,2);
  assert.ok(boss.windup>0&&boss.windup<.5,'phase two is faster');
});

test('new portal grants run-only blessing; equipment stays equipped between runs', () => {
  const profile=makeProfile();awardEquipment(profile,'forest-05');
  const game=createGame(plan,profile);
  assert.ok(game.player.vx===0);
  advance(game);
  assert.equal(game.roomIndex,1);
  assert.ok(game.runBuffs.mana>0);
  assert.ok(game.player.mana>3);
  const newRun=createGame(plan,profile);
  assert.deepEqual(newRun.runBuffs,{damage:0,mana:0,mobility:0});
  assert.equal(newRun.profile.equipment.equipped.boots,'forest-05');
});
