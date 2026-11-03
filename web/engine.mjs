/**
 * Rasta Quest web preview simulation. Coordinates are virtual pixels in a
 * 960 × 540 viewport. Player x/y are the top-left corner; ground starts at 460.
 * createGame(plan) creates a run; step(state, input, seconds) mutates and returns
 * it. input accepts left, right, jump, attack, interact, and restart booleans.
 * The canonical room plan supplies IDs and approximate camera-width positions;
 * all collision geometry here is authored specifically for this web preview.
 */
import { recordCowrie, awardEssence, awardEquipment } from './progression.mjs';
import { buildChests, buildRings, blessingForNextRoom, equipmentBonus } from './content.mjs';
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
    enemies.push({ id: `${room.id}-boss`, x, y: GROUND_Y - 96, w: 72, h: 96, hp: 10, maxHp: 10, phase: 1, windup: 0,
      alive: true, boss: true, anchorX: x, patrol: 280, speed: 74, facing: -1, cooldown: 0.8, hurt: 0 });
  } else {
    for (let screen = 1; screen < room.planned_camera_widths - 1; screen += 2) {
      const x = screen * VIEW_WIDTH + 485;
      enemies.push({ id: `${room.id}-enemy-${screen}`, x, y: GROUND_Y - 62, w: 46, h: 62,
        hp: 2, maxHp: 2, alive: true, boss: false, anchorX: x, patrol: 175,
        speed: 82, facing: -1, cooldown: 0.5, hurt: 0 });
    }
  }
  return { width, platforms, cowries, enemies, chests: buildChests(room, VIEW_WIDTH, GROUND_Y), rings: buildRings(room, VIEW_WIDTH) };
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
  state.chests = geometry.chests;
  state.rings = geometry.rings;
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
  if (index > 0) {
    const buff = blessingForNextRoom(index);
    const old = state.runBuffs[buff.effect] || 0;
    const cap = buff.effect === 'mobility' ? 90 : 3;
    state.runBuffs[buff.effect] = Math.min(cap, old + buff.value);
  }
  state.player.maxMana = 3 + (state.profile?.upgrades.spirit ?? 0) + equipmentBonus(state.profile, 'mana') + (state.runBuffs.mana || 0);
  state.player.mana = state.player.maxMana;
  state.jumpHeld = false;
  state.interactHeld = false;
  announce(state, `Sala ${index + 1}/21 · ${room.title}`, 3.5);
}

export function createGame(plan, profile = null) {
  validatePlan(plan);
  const state = {
    rooms: plan.rooms,
    profile,
    runBuffs: { damage: 0, mana: 0, mobility: 0 },
    profileRevision: 0,
    roomIndex: 0,
    room: null,
    worldWidth: 0,
    platforms: [],
    enemies: [],
    cowries: [],
    chests: [], rings: [],
    entrance: null,
    exit: null,
    checkpoint: null,
    cameraX: 0,
    player: { x: 0, y: 0, w: PLAYER_WIDTH, h: PLAYER_HEIGHT, vx: 0, vy: 0,
      hp: 3 + (profile?.upgrades.vitality ?? 0) + equipmentBonus(profile,'vitality'),
      maxHp: 3 + (profile?.upgrades.vitality ?? 0) + equipmentBonus(profile,'vitality'),
      mana: 3 + (profile?.upgrades.spirit ?? 0) + equipmentBonus(profile,'mana'),
      maxMana: 3 + (profile?.upgrades.spirit ?? 0) + equipmentBonus(profile,'mana'),
      lives: 3, invuln: 0, grounded: true, facing: 1, grappleBoost: 0,
      attackSpecial: false,
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
    if (enemy.boss) { enemy.windup = 0; enemy.phase = 1; }
  }
  announce(state, state.checkpoint.activated ? "Retorno ao checkpoint." : "Retorno à entrada.");
}

function movePlayer(state, input, dt) {
  const player = state.player;
  const direction = Number(Boolean(input.right)) - Number(Boolean(input.left));
  player.grappleBoost = Math.max(0, player.grappleBoost - dt);
  const mobility = equipmentBonus(state.profile, 'mobility') + (state.runBuffs.mobility || 0);
  player.vx = direction * (SPEED + (state.profile?.upgrades.mobility ?? 0) * 18 + mobility + (player.grappleBoost > 0 ? 160 : 0));
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
  const special = Boolean(input.special) && player.mana > 0;
  if ((!input.attack && !input.special) || player.attackCooldown > 0) return;
  if (input.special && !special && !input.attack) {
    announce(state, 'Mana insuficiente para o ataque especial.', 0.7);
    return;
  }
  if (special) player.mana -= 1;
  player.attackSpecial = special;
  player.attackCooldown = Math.max(0.19, (special ? 0.48 : 0.34) - equipmentBonus(state.profile, 'handling') * 0.025);
  player.attackTime = special ? 0.28 : 0.2;
  const hitbox = {
    x: player.facing > 0 ? player.x + player.w - 4 : player.x - (special ? 142 : 84),
    y: player.y + (special ? -8 : 10),
    w: special ? 146 : 88,
    h: special ? 90 : 62,
  };
  let hits = 0;
  for (const enemy of state.enemies) {
    if (!enemy.alive || !overlap(hitbox, enemy)) continue;
    enemy.hp -= 1 + (special ? 2 : 0) + (state.profile?.upgrades.strength ?? 0) + equipmentBonus(state.profile, 'damage') + (state.runBuffs.damage || 0);
    enemy.hurt = 0.2;
    hits += 1;
    if (enemy.hp <= 0) {
      enemy.hp = 0;
      enemy.alive = false;
      if (state.profile && awardEssence(state.profile, enemy.boss ? 20 : 5)) state.profileRevision += 1;
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
    if (enemy.boss) {
      enemy.phase = enemy.hp <= Math.ceil(enemy.maxHp / 2) ? 2 : 1;
      if (enemy.windup > 0) {
        enemy.windup = Math.max(0, enemy.windup - dt);
        if (!enemy.windup) {
          const attackDistance = Math.abs(player.x + player.w / 2 - (enemy.x + enemy.w / 2));
          if (attackDistance < (enemy.phase === 2 ? 170 : 130) && sameLevel) takeDamage(state);
          enemy.cooldown = enemy.phase === 2 ? 1.05 : 1.5;
        }
      } else if (Math.abs(distance) < 190 && sameLevel && enemy.cooldown <= 0) {
        enemy.windup = enemy.phase === 2 ? 0.38 : 0.65;
        announce(state, enemy.phase === 2 ? 'O guardião acelera! Desvie do impacto!' : 'O guardião prepara um golpe!', 0.8);
      }
    } else if (close && sameLevel && enemy.cooldown <= 0) {
      takeDamage(state);
      enemy.cooldown = 1.35;
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
    if (state.profile && recordCowrie(state.profile, cowrie.id, { rooms: state.rooms })) state.profileRevision += 1;
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

function handleOptionalInteractions(state, input) {
  if (!input.interact || state.interactHeld) return false;
  const p = state.player;
  const cx = p.x + p.w / 2, cy = p.y + p.h / 2;
  // Chests are interactable in ground and elevated secret routes.
  const chest = state.chests.find(c => !c.opened && Math.abs(cx - (c.x + c.w / 2)) < 76 && Math.abs(cy - (c.y + c.h / 2)) < 85);
  if (chest) {
    chest.opened = true;
    if (chest.kind === 'rare') {
      if (state.profile && awardEquipment(state.profile, chest.equipmentId)) {
        state.profileRevision += 1;
        announce(state, 'Equipamento permanente encontrado! Veja Pausa / Equipar.', 3);
      } else announce(state, 'Baú raro explorado.', 2);
    } else {
      const gain = state.roomIndex % 2 === 0 ? 'hp' : 'mana';
      const max = gain === 'hp' ? 'maxHp' : 'maxMana';
      p[gain] = Math.min(p[max], p[gain] + 2);
      announce(state, gain === 'hp' ? 'Baú: vida recuperada!' : 'Baú: mana recuperada!');
    }
    return true;
  }
  if (!p.grounded) {
    const ring = state.rings.find(ring => Math.abs(cx - ring.x) < 80 && Math.abs(cy - ring.y) < 85);
    if (ring) {
      p.vy = -720;
      p.grappleBoost = 0.32;
      announce(state, 'Impulso na argola!');
      return true;
    }
  }
  return false;
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
    if (input.restart) Object.assign(state, createGame({ rooms: state.rooms }, state.profile));
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
  const interacted = handleOptionalInteractions(state, input);
  if (!state.checkpoint.activated && player.x + player.w / 2 >= state.checkpoint.x) {
    state.checkpoint.activated = true;
    announce(state, "Checkpoint ativado.");
  }
  if (!interacted) handleExit(state, input);
  state.interactHeld = Boolean(input.interact);
  state.cameraX = clamp(player.x + player.w / 2 - VIEW_WIDTH * 0.42, 0, Math.max(0, state.worldWidth - VIEW_WIDTH));
  return state;
}

/** Run snapshot is separate from profile/metaprogression. It resumes safely at
 * a checkpoint (or entrance) rather than serializing live physics internals. */
export const RUN_VERSION = 1;

export function snapshotRun(state) {
  if (!state || state.status !== 'playing') return null;
  return {
    version: RUN_VERSION,
    roomIndex: state.roomIndex,
    roomId: state.room.id,
    lives: state.player.lives,
    hp: state.player.hp,
    mana: state.player.mana,
    collectedIds: [...state.collectedIds].sort(),
    rewardedRooms: [...state.rewardedRooms].sort(),
    killedEnemies: state.enemies.filter(e => !e.alive).map(e => e.id),
    openedChests: state.chests.filter(c => c.opened).map(c => c.id),
    checkpoint: Boolean(state.checkpoint.activated),
    runBuffs: { ...state.runBuffs },
  };
}

export function restoreRun(plan, profile, snapshot) {
  const fresh = createGame(plan, profile);
  if (!snapshot || snapshot.version !== RUN_VERSION ||
      !Number.isInteger(snapshot.roomIndex) || snapshot.roomIndex < 0 ||
      snapshot.roomIndex >= plan.rooms.length ||
      snapshot.roomId !== plan.rooms[snapshot.roomIndex].id) return fresh;

  const validIds = new Set(plan.rooms.flatMap(room => room.cowries.map(c => c.id)));
  const uniqueIds = [...new Set(Array.isArray(snapshot.collectedIds) ?
    snapshot.collectedIds.filter(id => typeof id === 'string' && validIds.has(id)) : [])];
  const awarded = new Set();
  for (const room of plan.rooms) {
    if (room.cowries.every(c => uniqueIds.includes(c.id)) &&
      Array.isArray(snapshot.rewardedRooms) &&
      snapshot.rewardedRooms.includes(room.id)) awarded.add(room.id);
  }
  if (snapshot.roomIndex > 0) enterRoom(fresh,snapshot.roomIndex);
  const buffs = snapshot.runBuffs ?? {};
  fresh.runBuffs = {
    damage: Number.isInteger(buffs.damage) ? clamp(buffs.damage,0,3) : 0,
    mana: Number.isInteger(buffs.mana) ? clamp(buffs.mana,0,3) : 0,
    mobility: Number.isInteger(buffs.mobility) ? clamp(buffs.mobility,0,90) : 0,
  };
  fresh.player.maxMana = 3 + (profile?.upgrades.spirit ?? 0) +
    equipmentBonus(profile,'mana') + fresh.runBuffs.mana;
  fresh.player.mana = Number.isInteger(snapshot.mana) ?
    clamp(snapshot.mana,0,fresh.player.maxMana) : fresh.player.maxMana;
  fresh.player.lives = Number.isSafeInteger(snapshot.lives) && snapshot.lives >= 1 && snapshot.lives <= 99 ?
    snapshot.lives : fresh.player.lives;
  fresh.player.hp = Number.isInteger(snapshot.hp) ?
    clamp(snapshot.hp,1,fresh.player.maxHp) : fresh.player.maxHp;
  fresh.collectedIds = new Set(uniqueIds);
  fresh.totalCollected = uniqueIds.length;
  fresh.rewardedRooms = awarded;
  let roomCount=0;
  for(const cowrie of fresh.cowries) {
    if (fresh.collectedIds.has(cowrie.id)) { cowrie.collected = true; roomCount++; }
  }
  fresh.roomCollected = roomCount;
  const killed = new Set(Array.isArray(snapshot.killedEnemies) ? snapshot.killedEnemies : []);
  for (const enemy of fresh.enemies) if(killed.has(enemy.id)) { enemy.alive = false; enemy.hp = 0; }
  const opened = new Set(Array.isArray(snapshot.openedChests) ? snapshot.openedChests : []);
  for (const chest of fresh.chests) if(opened.has(chest.id)) chest.opened = true;
  fresh.checkpoint.activated = Boolean(snapshot.checkpoint);
  fresh.player.x = fresh.checkpoint.activated ? fresh.checkpoint.x : fresh.entrance.x;
  fresh.player.y = GROUND_Y - fresh.player.h;
  fresh.player.vx = 0; fresh.player.vy = 0; fresh.player.grounded = true;
  fresh.player.invuln = 1.5;
  fresh.cameraX = clamp(fresh.player.x - VIEW_WIDTH*.42,0,Math.max(0,fresh.worldWidth-VIEW_WIDTH));
  fresh.exit.ready = fresh.enemies.every(enemy => !enemy.alive);
  announce(fresh, 'Jornada restaurada do checkpoint.',3);
  return fresh;
}
