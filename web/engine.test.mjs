import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { createGame, step, validatePlan, VIEW_WIDTH, GROUND_Y } from './engine.mjs';

const planPath = fileURLToPath(new URL('./data/rooms.json', import.meta.url));
const plan = JSON.parse(readFileSync(planPath, 'utf8'));

function frames(state, input, count = 60) {
  for (let i = 0; i < count; i += 1) step(state, input, 1 / 60);
}

test('preserves all 21 room plans and 105 unique physical cowries', () => {
  assert.equal(validatePlan(plan), true);
  const game = createGame(plan);
  assert.equal(game.rooms.length, 21);
  assert.equal(game.cowries.length, 5);
  assert.equal(game.worldWidth, game.room.planned_camera_widths * VIEW_WIDTH);
  for (const room of plan.rooms.filter(room => room.boss_room)) {
    assert.ok(room.cowries.every(cowrie => cowrie.approx_screen < room.boss_start_screen));
  }
});

test('movement, jump, landing, obstacle collision and camera follow work', () => {
  const game = createGame(plan);
  const startX = game.player.x;
  frames(game, { right: true }, 80);
  assert.ok(game.player.x > startX + 300);
  assert.equal(game.player.y + game.player.h, GROUND_Y);
  const startY = game.player.y;
  step(game, { jump: true, right: true }, 1 / 60);
  frames(game, { right: true }, 13);
  assert.ok(game.player.y < startY - 80);
  frames(game, {}, 90);
  assert.ok(game.player.grounded);
  assert.ok(game.cameraX > 0);

  const block = game.platforms.find(platform => platform.kind === 'block');
  game.player.x = block.x - game.player.w - 2;
  game.player.y = GROUND_Y - game.player.h;
  frames(game, { right: true }, 20);
  assert.ok(game.player.x + game.player.w <= block.x + 0.01);
});

test('five cowries grant one extra life only once in the room', () => {
  const game = createGame(plan);
  const startingLives = game.player.lives;
  for (const cowrie of game.cowries) {
    game.player.x = cowrie.x - game.player.w / 2;
    game.player.y = cowrie.y - game.player.h / 2;
    step(game, {}, 1 / 60);
  }
  assert.equal(game.roomCollected, 5);
  assert.equal(game.totalCollected, 5);
  assert.equal(game.player.lives, startingLives + 1);
  assert.equal(game.rewardedRooms.size, 1);
  frames(game, {}, 30);
  assert.equal(game.player.lives, startingLives + 1);
  assert.equal(game.collectedIds.size, 5);
});

test('an upper side-route cowrie is reachable by jumping through its one-way platform', () => {
  const game = createGame(plan);
  const upper = game.cowries.find(cowrie => cowrie.upper);
  game.player.x = upper.x - game.player.w / 2;
  game.player.y = GROUND_Y - game.player.h;
  step(game, { jump: true }, 1 / 60);
  frames(game, {}, 65);
  assert.equal(upper.collected, true);
  assert.equal(game.player.y + game.player.h, 365);
});

test('checkpoint survives death, exit stays gated, and next room loads after combat', () => {
  const game = createGame(plan);
  game.player.x = game.checkpoint.x;
  step(game, {}, 1 / 60);
  assert.equal(game.checkpoint.activated, true);
  game.player.invuln = 0;
  game.player.hp = 1;
  const enemy = game.enemies[0];
  game.player.x = enemy.x + 3;
  game.player.y = enemy.y;
  enemy.cooldown = 0;
  step(game, {}, 1 / 60);
  assert.equal(game.player.lives, 2);
  assert.equal(game.player.x, game.checkpoint.x);
  assert.equal(game.player.hp, game.player.maxHp);

  game.player.x = game.exit.x - 10;
  step(game, { interact: true }, 1 / 60);
  assert.equal(game.roomIndex, 0);
  step(game, { interact: false }, 1 / 60);
  for (const foe of game.enemies) {
    foe.x = game.player.x + game.player.w + 8;
    foe.anchorX = foe.x;
    foe.hp = 1;
    foe.cooldown = 20;
    game.player.attackCooldown = 0;
    step(game, { attack: true }, 1 / 60);
  }
  assert.ok(game.enemies.every(foe => !foe.alive));
  assert.equal(game.exit.ready, true);
  step(game, { interact: true }, 1 / 60);
  assert.equal(game.roomIndex, 1);
  assert.equal(game.room.id, plan.rooms[1].id);
});

test('boss rooms keep all cowries before the arena and final exit wins', () => {
  const game = createGame(plan);
  const final = plan.rooms.length - 1;
  // Walk the same runtime transition used for a cleared room.
  for (let roomIndex = 0; roomIndex < final; roomIndex += 1) {
    for (const enemy of game.enemies) enemy.alive = false;
    game.player.x = game.exit.x - 5;
    step(game, { interact: true }, 1 / 60);
    step(game, { interact: false }, 1 / 60);
  }
  assert.equal(game.roomIndex, final);
  assert.equal(game.room.boss_room, true);
  assert.ok(game.cowries.every(cowrie => cowrie.x < game.enemies[0].x));
  assert.equal(game.exit.ready, false);
  game.enemies[0].alive = false;
  game.player.x = game.exit.x - 5;
  step(game, { interact: true }, 1 / 60);
  assert.equal(game.status, 'won');
  step(game, { restart: true }, 1 / 60);
  assert.equal(game.status, 'playing');
  assert.equal(game.roomIndex, 0);
});
