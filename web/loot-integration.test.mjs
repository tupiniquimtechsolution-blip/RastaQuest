import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, resumeGame, snapshotRun, step } from './engine.mjs';
import { makeProfile, sanitizeProfile } from './progression.mjs';
import { equipmentStat } from './loot.mjs';
const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));

test('common chest heals only once, and stays opened after checkpoint restoration', () => {
  const state = createGame(plan, makeProfile());
  const chest = state.chests.find(c => c.kind === 'common');
  assert.equal(chest.reward, 'health');
  state.player.hp = 1;
  state.player.x = chest.x - state.player.w / 2;
  state.player.y = 460 - state.player.h;
  step(state, { interact: true }, 1 / 60);
  assert.equal(chest.opened, true);
  assert.equal(state.player.hp, 3);
  const loaded = resumeGame(plan, state.profile, snapshotRun(state));
  assert.equal(loaded.chests.find(c => c.id === chest.id).opened, true);
  loaded.player.hp = 1;
  loaded.player.x = chest.x - loaded.player.w / 2;
  step(loaded, { interact: true }, 1 / 60);
  assert.equal(loaded.player.hp, 1);
});

test('rare chest requires elevated route, adds permanent oak haft exactly once', () => {
  const profile = makeProfile();
  const state = createGame(plan, profile);
  for (const enemy of state.enemies) enemy.alive = false;
  state.player.x = state.exit.x - 5;
  step(state, { interact: true }, 1 / 60);
  assert.equal(state.room.id, 'forest-02');
  const chest = state.chests.find(c => c.kind === 'rare');
  assert.ok(chest);
  state.player.x = chest.x - state.player.w / 2;
  state.player.y = 460 - state.player.h;
  step(state, { interact: true }, 1 / 60);
  assert.equal(chest.opened, false);
  step(state, { interact: false }, 1 / 60);
  state.player.y = 365 - state.player.h;
  step(state, { interact: true }, 1 / 60);
  assert.equal(chest.opened, true);
  assert.equal(equipmentStat(profile, 'haft'), 'oak-haft');
  assert.deepEqual(sanitizeProfile(profile, plan).items, ['oak-haft']);
  const restored = resumeGame(plan, profile, snapshotRun(state));
  assert.equal(restored.chests.find(c => c.id === chest.id).opened, true);
});

test('special costs mana and strikes harder; without mana it cannot fire', () => {
  const state = createGame(plan, makeProfile());
  const foe = state.enemies[0];
  foe.cooldown = 200;
  state.player.x = foe.x - state.player.w - 14;
  state.player.y = foe.y;
  step(state, { special: true }, 1 / 60);
  assert.equal(state.player.mana, 2);
  assert.equal(foe.alive, false);
  assert.equal(state.player.specialTime > 0, true);
  state.player.mana = 0; state.player.attackCooldown = 0;
  step(state, { special: true }, 1 / 60);
  assert.equal(state.player.mana, 0);
});

test('gear from another biome increases attack damage and boost remains after new run', () => {
  const profile = makeProfile();
  profile.items = ['ogum-metal', 'iansa-boots'];
  profile.equipped.blade = 'ogum-metal';
  profile.equipped.boots = 'iansa-boots';
  const state = createGame(plan, profile);
  const foe = state.enemies[0]; foe.cooldown = 200;
  state.player.x = foe.x - state.player.w - 14; state.player.y = foe.y;
  step(state, { attack: true }, 1 / 60);
  assert.equal(foe.alive, false);
  const base = createGame(plan, makeProfile());
  const baseFoe = base.enemies[0]; baseFoe.cooldown = 200;
  base.player.x = baseFoe.x - base.player.w - 14; base.player.y = baseFoe.y;
  step(base, { attack: true }, 1 / 60);
  assert.equal(baseFoe.hp, 1);
});
