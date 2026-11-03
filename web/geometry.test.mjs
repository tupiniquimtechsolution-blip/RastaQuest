import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, step, VIEW_WIDTH, VIEW_HEIGHT, GROUND_Y } from './engine.mjs';
const plan = JSON.parse(readFileSync(new URL('./data/rooms.json', import.meta.url), 'utf8'));

test('every room generates accessible checkpoints, portals and five physical cowries', () => {
  const game = createGame(plan);
  let bosses = 0;
  for (let i = 0; i < plan.rooms.length; i++) {
    const room = plan.rooms[i];
    // Transition with cleared enemies to inspect each runtime room, not
    // to claim a real human playthrough.
    assert.equal(game.room.id, room.id);
    assert.equal(game.worldWidth, room.planned_camera_widths * VIEW_WIDTH);
    assert.ok(game.worldWidth >= 5 * VIEW_WIDTH);
    assert.equal(game.cowries.length, 5);
    assert.ok(game.checkpoint.x > game.entrance.x && game.checkpoint.x < game.exit.x,
      room.id + ': checkpoint must precede the exit');
    assert.ok(game.exit.x + game.exit.w < game.worldWidth, room.id + ': exit inside world');
    assert.ok(game.player.y >= 0 && game.player.y + game.player.h <= VIEW_HEIGHT);
    for (const shell of game.cowries) {
      assert.ok(shell.x > game.entrance.x && shell.x < game.exit.x,
        room.id + ': shell within exploration route');
      if (shell.upper) {
        const reachable = game.platforms.some(p => p.kind === 'branch' &&
          p.x <= shell.x && p.x + p.w >= shell.x &&
          Math.abs((shell.y + 34) - p.y) <= 2);
        assert.ok(reachable, room.id + ': upper cowrie needs a supporting platform');
      } else {
        assert.ok(shell.y >= GROUND_Y - 70 && shell.y < GROUND_Y);
      }
    }
    assert.ok(game.platforms.some(p => p.kind === 'ground' && p.w === game.worldWidth));
    if (room.boss_room) {
      bosses++;
      assert.equal(game.enemies.filter(e => e.boss).length, 1);
      assert.ok(game.cowries.every(c => c.x < game.enemies[0].x));
    }
    if (i < plan.rooms.length - 1) {
      for (const enemy of game.enemies) enemy.alive = false;
      game.player.x = game.exit.x - 5;
      step(game, { interact: true }, 1 / 60);
      assert.equal(game.roomIndex, i + 1);
      step(game, { interact: false }, 1 / 60);
    }
  }
  assert.equal(bosses, 3);
});

test('room transitions never change profile upgrades or rewind global album', () => {
  const game = createGame(plan);
  const first = game.cowries[0];
  game.player.x = first.x - game.player.w / 2;
  game.player.y = first.y - game.player.h / 2;
  step(game, {}, 1 / 60);
  const identity = first.id;
  for (const enemy of game.enemies) enemy.alive = false;
  game.player.x = game.exit.x - 5;
  step(game, { interact: true }, 1 / 60);
  assert.equal(game.collectedIds.has(identity), true);
  assert.equal(game.totalCollected, 1);
  assert.equal(game.roomCollected, 0);
});
