/**
 * Rasta Quest web preview simulation. Coordinates are virtual pixels in a
 * 960 × 540 viewport. Player x/y are the top-left corner; ground starts at 460.
 * createGame(plan) creates a run; step(state, input, seconds) mutates and returns
 * it. input accepts left, right, jump, attack, interact, and restart booleans.
 * The canonical room plan supplies IDs and approximate camera-width positions;
 * all collision geometry here is authored specifically for this web preview.
 */
export const VIEW_WIDTH = 960;
export const VIEW_HEIGHT = 540;
export const GROUND_Y = 460;

const PLAYER_WIDTH = 44;
const PLAYER_HEIGHT = 70;
const SPEED = 310;
const GRAVITY = 1850;
const JUMP_SPEED = 745;
const MAX_FALL_SPEED = 1050;

function clamp(value, low, high) {
  return Math.max(low, Math.min(high, value));
}

function overlap(a, b) {
  return a.x < b.x + b.w && a.x + a.w > b.x && a.y < b.y + b.h && a.y + a.h > b.y;
}

function announce(state, message, duration = 2.5) {
  state.message = message;
  state.messageTime = duration;
}

export function validatePlan(plan) {
  if (!plan || !Array.isArray(plan.rooms) || plan.rooms.length !== 21) {
    throw new Error("O plano precisa conter 21 salas.");
  }
  const ids = new Set();
  for (const room of plan.rooms) {
    if (!room.id || !Number.isInteger(room.planned_camera_widths) || room.planned_camera_widths < 5) {
      throw new Error(`Sala inválida: ${room?.id ?? "sem ID"}`);
    }
    if (!Array.isArray(room.cowries) || room.cowries.length !== 5) {
      throw new Error(`${room.id}: são necessários 5 búzios.`);
    }
    for (const cowrie of room.cowries) {
      if (ids.has(cowrie.id) || !Number.isFinite(cowrie.approx_screen)) {
        throw new Error(`${room.id}: ID ou posição de búzio inválida.`);
      }
      if (cowrie.approx_screen < 0 || cowrie.approx_screen >= room.planned_camera_widths) {
        throw new Error(`${room.id}: búzio fora da sala.`);
      }
      if (room.boss_room && cowrie.approx_screen >= room.boss_start_screen) {
        throw new Error(`${room.id}: búzio depois do chefe.`);
      }
      ids.add(cowrie.id);
    }
  }
  if (ids.size !== 105) throw new Error("O plano precisa preservar 105 IDs de búzios.");
  return true;
}

function makeRoomGeometry(room) {
  const width = room.planned_camera_widths * VIEW_WIDTH;
  const platforms = [{ x: 0, y: GROUND_Y, w: width, h: VIEW_HEIGHT - GROUND_Y, kind: "ground" }];
  const cowries = room.cowries.map((source, index) => {
    const x = source.approx_screen * VIEW_WIDTH;
    const upper = index === 1 || index === 3;
    if (upper) {
      platforms.push({ x: x - 138, y: 365, w: 276, h: 19, kind: "branch" });
    }
    return { id: source.id, x, y: upper ? 331 : GROUND_Y - 33, r: 18, collected: false, upper };
  });

  // Low blocks give the jump a practical purpose without closing the main path.
  // The elevated platforms form a side route and return to the ground path.
  for (let screen = 1; screen < room.planned_camera_widths - 1; screen += 1) {
    const blockX = screen * VIEW_WIDTH + 565;
    if (blockX < width - 330) {
      platforms.push({ x: blockX, y: GROUND_Y - 44, w: 92, h: 44, kind: "block" });
    }
  }

  const enemies = [];
  if (room.boss_room) {
    const x = room.boss_start_screen * VIEW_WIDTH + 180;
    enemies.push({ id: `${room.id}-boss`, x, y: GROUND_Y - 96, w: 72, h: 96, hp: 7, maxHp: 7,
      alive: true, boss: true, anchorX: x, patrol: 280, speed: 74, facing: -1, cooldown: 0.8, hurt: 0 });
  } else {
    for (let screen = 1; screen < room.planned_camera_widths - 1; screen += 2) {
      const x = screen * VIEW_WIDTH + 485;
      enemies.push({ id: `${room.id}-enemy-${screen}`, x, y: GROUND_Y - 62, w: 46, h: 62,
        hp: 2, maxHp: 2, alive: true, boss: false, anchorX: x, patrol: 175,
        speed: 82, facing: -1, cooldown: 0.5, hurt: 0 });
    }
  }
  return { width, platforms, cowries, enemies };
}

function enterRoom(state, index) {
  const room = state.rooms[index];
  const geometry = makeRoomGeometry(room);
  state.roomIndex = index;
  state.room = room;
  state.worldWidth = geometry.width;
  state.platforms = geometry.platforms;
  state.cowries = geometry.cowries;
  state.enemies = geometry.enemies;
  state.entrance = { x: 82, y: GROUND_Y - PLAYER_HEIGHT };
  state.exit = { x: geometry.width - 105, y: GROUND_Y - 104, w: 58, h: 104, ready: false };
  state.checkpoint = { x: room.checkpoint_screen * VIEW_WIDTH, y: GROUND_Y - PLAYER_HEIGHT, activated: false };
  state.player.x = state.entrance.x;
  state.player.y = state.entrance.y;
  state.player.vx = 0;
  state.player.vy = 0;
  state.player.grounded = true;
  state.player.invuln = 0.7;
  state.cameraX = 0;
  state.roomCollected = 0;
  state.jumpHeld = false;
  state.interactHeld = false;
  announce(state, `Sala ${index + 1}/21 · ${room.title}`, 3.5);
}

export function createGame(plan) {
  validatePlan(plan);
  const state = {
    rooms: plan.rooms,
    roomIndex: 0,
    room: null,
    worldWidth: 0,
    platforms: [],
    enemies: [],
    cowries: [],
    entrance: null,
    exit: null,
    checkpoint: null,
    cameraX: 0,
    player: { x: 0, y: 0, w: PLAYER_WIDTH, h: PLAYER_HEIGHT, vx: 0, vy: 0,
      hp: 3, maxHp: 3, lives: 3, invuln: 0, grounded: true, facing: 1,
      attackCooldown: 0, attackTime: 0 },
    totalCollected: 0,
    roomCollected: 0,
    collectedIds: new Set(),
    rewardedRooms: new Set(),
    status: "playing",
    message: "",
    messageTime: 0,
    jumpHeld: false,
    interactHeld: false,
    time: 0,
  };
  enterRoom(state, 0);
  return state;
}

function takeDamage(state) {
  const player = state.player;
  if (player.invuln > 0 || state.status !== "playing") return;
  player.hp -= 1;
  player.invuln = 1.15;
  announce(state, "Akane sofreu um golpe!");
  if (player.hp > 0) return;
  player.lives -= 1;
  if (player.lives <= 0) {
    player.hp = 0;
    state.status = "gameover";
    announce(state, "Fim da jornada. Reinicie para tentar de novo.", 60);
    return;
  }
  player.hp = player.maxHp;
  player.x = state.checkpoint.activated ? state.checkpoint.x : state.entrance.x;
  player.y = GROUND_Y - player.h;
  player.vx = 0;
  player.vy = 0;
  player.grounded = true;
  player.invuln = 1.7;
  for (const enemy of state.enemies) {
    enemy.x = enemy.anchorX;
    enemy.hp = enemy.maxHp;
    enemy.alive = true;
    enemy.cooldown = 0.7;
  }
  announce(state, state.checkpoint.activated ? "Retorno ao checkpoint." : "Retorno à entrada.");
}

function movePlayer(state, input, dt) {
  const player = state.player;
  const direction = Number(Boolean(input.right)) - Number(Boolean(input.left));
  player.vx = direction * SPEED;
  if (direction) player.facing = direction;
  if (input.jump && !state.jumpHeld && player.grounded) {
    player.vy = -JUMP_SPEED;
    player.grounded = false;
  }
  state.jumpHeld = Boolean(input.jump);

  player.x = clamp(player.x + player.vx * dt, 0, state.worldWidth - player.w);
  for (const solid of state.platforms) {
    if (solid.kind === "ground" || solid.kind === "branch" || !overlap(player, solid)) continue;
    if (direction > 0) player.x = solid.x - player.w;
    else if (direction < 0) player.x = solid.x + solid.w;
    player.vx = 0;
  }

  const previousTop = player.y;
  const previousBottom = player.y + player.h;
  player.vy = clamp(player.vy + GRAVITY * dt, -JUMP_SPEED, MAX_FALL_SPEED);
  player.y += player.vy * dt;
  player.grounded = false;
  if (player.vy >= 0) {
    let landingY = Infinity;
    for (const solid of state.platforms) {
      const crossing = previousBottom <= solid.y + 3 && player.y + player.h >= solid.y;
      const horizontal = player.x + player.w > solid.x && player.x < solid.x + solid.w;
      if (crossing && horizontal) landingY = Math.min(landingY, solid.y);
    }
    if (landingY < Infinity) {
      player.y = landingY - player.h;
      player.vy = 0;
      player.grounded = true;
    }
  } else {
    for (const solid of state.platforms) {
      if (solid.kind === "branch") continue; // one-way side-route platforms
      const hitCeiling = previousTop >= solid.y + solid.h - 2 && player.y <= solid.y + solid.h;
      const horizontal = player.x + player.w > solid.x && player.x < solid.x + solid.w;
      if (hitCeiling && horizontal) {
        player.y = solid.y + solid.h;
        player.vy = 0;
      }
    }
  }
  if (player.y > VIEW_HEIGHT + 120) takeDamage(state);
}

function attackEnemies(state, input) {
  const player = state.player;
  if (!input.attack || player.attackCooldown > 0) return;
  player.attackCooldown = 0.34;
  player.attackTime = 0.2;
  const hitbox = {
    x: player.facing > 0 ? player.x + player.w - 4 : player.x - 84,
    y: player.y + 10,
    w: 88,
    h: 62,
  };
  let hits = 0;
  for (const enemy of state.enemies) {
    if (!enemy.alive || !overlap(hitbox, enemy)) continue;
    enemy.hp -= 1;
    enemy.hurt = 0.2;
    hits += 1;
    if (enemy.hp <= 0) {
      enemy.hp = 0;
      enemy.alive = false;
    }
  }
  if (hits) announce(state, state.enemies.every(e => !e.alive) ? "Caminho liberado! Procure a saída." : "Golpe certeiro!", 1.4);
}

function updateEnemies(state, dt) {
  const player = state.player;
  for (const enemy of state.enemies) {
    if (!enemy.alive) continue;
    enemy.cooldown = Math.max(0, enemy.cooldown - dt);
    enemy.hurt = Math.max(0, enemy.hurt - dt);
    const distance = player.x + player.w / 2 - (enemy.x + enemy.w / 2);
    if (Math.abs(distance) < 370 && Math.abs(distance) > 67 && !enemy.hurt) {
      const direction = Math.sign(distance);
      enemy.facing = direction;
      enemy.x = clamp(enemy.x + direction * enemy.speed * dt, enemy.anchorX - enemy.patrol, enemy.anchorX + enemy.patrol);
    }
    const close = Math.abs(distance) < (enemy.boss ? 91 : 62);
    const sameLevel = Math.abs((player.y + player.h) - (enemy.y + enemy.h)) < 72;
    if (close && sameLevel && enemy.cooldown <= 0) {
      takeDamage(state);
      enemy.cooldown = enemy.boss ? 1.1 : 1.35;
    }
  }
}

function collectCowries(state) {
  const player = state.player;
  for (const cowrie of state.cowries) {
    if (cowrie.collected) continue;
    const nearestX = clamp(cowrie.x, player.x, player.x + player.w);
    const nearestY = clamp(cowrie.y, player.y, player.y + player.h);
    if (Math.hypot(cowrie.x - nearestX, cowrie.y - nearestY) > cowrie.r + 8) continue;
    cowrie.collected = true;
    state.collectedIds.add(cowrie.id);
    state.totalCollected += 1;
    state.roomCollected += 1;
    announce(state, `Búzio ${state.roomCollected}/5 desta sala`);
  }
  if (state.roomCollected === 5 && !state.rewardedRooms.has(state.room.id)) {
    state.rewardedRooms.add(state.room.id);
    player.lives += 1;
    announce(state, "5 búzios! +1 vida extra", 3.2);
  }
}

function handleExit(state, input) {
  state.exit.ready = state.enemies.every(enemy => !enemy.alive);
  const player = state.player;
  const near = Math.abs(player.x + player.w / 2 - (state.exit.x + state.exit.w / 2)) < 105;
  if (!near || !input.interact || state.interactHeld) return;
  if (!state.exit.ready) {
    announce(state, state.room.boss_room ? "Derrote o guardião para abrir a saída." : "Derrote os inimigos para abrir a saída.");
    return;
  }
  if (state.roomIndex === state.rooms.length - 1) {
    state.status = "won";
    announce(state, "Jornada concluída! Você venceu o protótipo web.", 60);
  } else {
    enterRoom(state, state.roomIndex + 1);
  }
}

export function step(state, input = {}, seconds = 1 / 60) {
  if (state.status !== "playing") {
    if (input.restart) Object.assign(state, createGame({ rooms: state.rooms }));
    return state;
  }
  const dt = clamp(Number.isFinite(seconds) ? seconds : 0, 0, 1 / 30);
  state.time += dt;
  if (state.messageTime > 0) {
    state.messageTime = Math.max(0, state.messageTime - dt);
    if (!state.messageTime) state.message = "";
  }
  const player = state.player;
  player.invuln = Math.max(0, player.invuln - dt);
  player.attackCooldown = Math.max(0, player.attackCooldown - dt);
  player.attackTime = Math.max(0, player.attackTime - dt);
  movePlayer(state, input, dt);
  attackEnemies(state, input);
  updateEnemies(state, dt);
  collectCowries(state);
  if (!state.checkpoint.activated && player.x + player.w / 2 >= state.checkpoint.x) {
    state.checkpoint.activated = true;
    announce(state, "Checkpoint ativado.");
  }
  handleExit(state, input);
  state.interactHeld = Boolean(input.interact);
  state.cameraX = clamp(player.x + player.w / 2 - VIEW_WIDTH * 0.42, 0, Math.max(0, state.worldWidth - VIEW_WIDTH));
  return state;
}
