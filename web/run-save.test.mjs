import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, resumeGame, step } from './engine.mjs';
import { makeProfile } from './progression.mjs';
import { RUN_SAVE_KEY, loadRun, saveRun, clearRun } from './run-save.mjs';
const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));
const store = () => {
  const values = new Map();
  return {
    getItem: key => values.get(key) ?? null,
    setItem: (key, value) => values.set(key, value),
    removeItem: key => values.delete(key)
  };
};
test('checkpoint, unique shells, dead enemies and lives survive safe browser restart', () => {
  const profile = makeProfile();
  const game = createGame(plan, profile);
  game.player.x = game.checkpoint.x;
  step(game, {}, 1 / 60);
  const cowrie = game.cowries[0];
  game.player.x = cowrie.x - game.player.w / 2;
  game.player.y = cowrie.y - game.player.h / 2;
  step(game, {}, 1 / 60);
  game.enemies[0].alive = false;
  game.enemies[0].hp = 0;
  game.player.lives = 6;
  const memory = store();
  assert.equal(saveRun(memory, game), true);
  const reopened = resumeGame(plan, profile, loadRun(memory));
  assert.equal(reopened.roomIndex, 0);
  assert.equal(reopened.checkpoint.activated, true);
  assert.equal(reopened.player.x, game.checkpoint.x);
  assert.equal(reopened.roomCollected, 1);
  assert.equal(reopened.totalCollected, 1);
  assert.equal(reopened.cowries[0].collected, true);
  assert.equal(reopened.enemies[0].alive, false);
  assert.equal(reopened.player.lives, 6);
  assert.equal(clearRun(memory), true);
  assert.equal(loadRun(memory), null);
});

test('malformed and out-of-range run payloads fail closed and never crash', () => {
  const profile = makeProfile();
  for (const payload of [null, {}, { version: 999 }, {
    version: 1, roomIndex: 99, hp: 3, lives: 1,
    collectedIds: [], rewardedRooms: [], defeatedEnemyIds: [],
  }]) {
    const game = resumeGame(plan, profile, payload);
    assert.equal(game.roomIndex, 0);
    assert.equal(game.status, 'playing');
  }
  assert.equal(loadRun({ getItem(){ throw Error('blocked'); }}), null);
  assert.equal(saveRun({ setItem(){ throw Error('blocked'); }}, createGame(plan)), false);
});

test('resume keeps 5/5 completion and does not mint another life on reload', () => {
  const game = createGame(plan);
  for (const cowrie of game.cowries) {
    game.player.x = cowrie.x - game.player.w / 2;
    game.player.y = cowrie.y - game.player.h / 2;
    step(game, {}, 1 / 60);
  }
  assert.equal(game.player.lives, 4);
  const memory = store();
  saveRun(memory, game);
  const resumed = resumeGame(plan, null, loadRun(memory));
  assert.equal(resumed.roomCollected, 5);
  for (let i = 0; i < 10; i++) step(resumed, {}, 1 / 60);
  assert.equal(resumed.player.lives, 4);
  assert.equal(resumed.rewardedRooms.size, 1);
});

test('completed rooms, current room and run identity restore independently of profile', () => {
  const game = createGame(plan);
  game.collectedIds.add(plan.rooms[0].cowries[0].id);
  game.rewardedRooms.add(plan.rooms[0].id);
  // Use same room transition mechanic, bypassing combat solely for setup.
  for (const enemy of game.enemies) enemy.alive = false;
  game.player.x = game.exit.x - 5;
  step(game, { interact: true }, 1 / 60);
  assert.equal(game.roomIndex, 1);
  const memory = store(); saveRun(memory, game);
  const resumed = resumeGame(plan, null, loadRun(memory));
  assert.equal(resumed.roomIndex, 1);
  assert.equal(resumed.totalCollected, 1);
  assert.equal(resumed.rewardedRooms.has(plan.rooms[0].id), true);
});
