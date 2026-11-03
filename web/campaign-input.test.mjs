import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, step } from './engine.mjs';
import { makeProfile, SKIN_REWARDS } from './progression.mjs';

const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));

/** Input-only deterministic QA navigator for the fully-upgraded prototype.
 * It cannot teleport, rewrite enemies, collect shells through state edits,
 * bypass a portal, or skip any room. This is NOT a human/baseline balance test.
 */
test('max-upgrade input-only route clears 21 rooms, 3 guardians, 105 real-world shell slots', () => {
  const profile = makeProfile();
  Object.assign(profile.upgrades, { vitality: 5, strength: 5, mobility: 5 });
  const state = createGame(plan, profile);
  const cleared = [];
  const bossesVisited = new Set();
  const maxFrames = 30000;
  let frames = 0;
  while (state.status === 'playing' && frames++ < maxFrames) {
    const p = state.player;
    if (state.room.boss_room) bossesVisited.add(state.room.id);
    const shells = state.cowries.filter(shell => !shell.collected).sort((a, b) => a.x - b.x);
    let direction = 1;
    let jump = false;
    if (shells.length) {
      const target = shells[0];
      const distance = target.x - (p.x + p.w / 2);
      if (distance < -25) {
        direction = -1;
        if (target.upper && distance > -110 && p.grounded) jump = true;
      } else if (distance > 10) {
        direction = 1;
        if (target.upper && distance < 150 && distance > 60 && p.grounded) jump = true;
      } else {
        direction = 0;
        if (target.upper && p.grounded) jump = true;
      }
    } else {
      const foes = state.enemies.filter(enemy => enemy.alive);
      if (foes.length) {
        const nearest = foes.reduce((a, b) => Math.abs(b.x - p.x) < Math.abs(a.x - p.x) ? b : a);
        direction = nearest.x > p.x ? 1 : -1;
      }
    }
    const forwardBlock = state.platforms.find(block =>
      block.kind === 'block' && block.x >= p.x + p.w - 10 &&
      block.x - (p.x + p.w) < 95);
    if (forwardBlock && p.grounded && direction > 0) jump = true;
    const backBlock = state.platforms.find(block =>
      block.kind === 'block' && block.x + block.w <= p.x + 5 &&
      p.x - (block.x + block.w) < 95);
    if (backBlock && p.grounded && direction < 0) jump = true;
    if (!p.grounded || state.jumpHeld) jump = false;

    const foes = state.enemies.filter(enemy => enemy.alive);
    if (foes.length) {
      const near = foes.reduce((a, b) => Math.abs(b.x - p.x) < Math.abs(a.x - p.x) ? b : a);
      if (Math.abs(near.x - p.x) < 85 && p.x > near.x + near.w) direction = -1;
    }
    const interact = !shells.length && foes.length === 0 && Math.abs(state.exit.x - p.x) < 100;
    const oldIndex = state.roomIndex;
    const oldCollected = state.roomCollected;
    step(state, { left: direction < 0, right: direction > 0, jump, attack: true, interact }, 1 / 60);
    if (state.roomIndex !== oldIndex || state.status === 'won') {
      assert.equal(oldCollected, 5, plan.rooms[oldIndex].id + ': must pick all five before exit');
      cleared.push(plan.rooms[oldIndex].id);
    }
  }

  assert.equal(state.status, 'won', 'prototype journey must reach a win with gameplay inputs');
  assert.equal(cleared.length, 21, 'every room must be completed, not skipped');
  assert.deepEqual(cleared, plan.rooms.map(room => room.id));
  assert.equal(bossesVisited.size, 3);
  assert.equal(state.totalCollected, 105);
  assert.equal(profile.collectedCowries.length, 105);
  assert.deepEqual(profile.skins, SKIN_REWARDS);
  assert.equal(state.rewardedRooms.size, 21);
  assert.ok(state.player.lives > 0);
  console.log('Input-only upgraded-profile campaign completed in ' + frames + ' simulated frames.');
});
