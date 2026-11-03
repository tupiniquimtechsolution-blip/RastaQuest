import { VIEW_WIDTH, VIEW_HEIGHT, GROUND_Y } from './engine.mjs';

const SPRITE_PATHS = {
  idle: 'assets/player-idle.png', run1: 'assets/player-run.png',
  run2: 'assets/player-run.png', jump: 'assets/player-jump.png',
  attack: 'assets/player-attack.png',
  enemy: 'assets/enemy-idle.png', enemyRun: 'assets/enemy-idle.png',
  enemyAttack: 'assets/enemy-attack.png', portal: 'assets/portal.png',
  bossForest: 'assets/boss-forest.png', bossCastle: 'assets/boss-castle.png',
  bossCaves: 'assets/boss-caves.png',
  forestTile: 'assets/terrain-forest.png',
  castleTile: 'assets/terrain-castle.png',
  cavesTile: 'assets/terrain-caves.png',
};

const PALETTES = {
  forest: { sky: '#1a4d49', horizon: '#75a587', far: '#326e5f', middle: '#275647', front: '#193b32', ground: '#362f27', grass: '#82ae72', glow: '#b1e7a0' },
  castle: { sky: '#3a374d', horizon: '#a68f88', far: '#5b5771', middle: '#49465c', front: '#302e43', ground: '#363543', grass: '#b0a38c', glow: '#edcfaf' },
  caves: { sky: '#142943', horizon: '#496b83', far: '#34526a', middle: '#263f59', front: '#1a3047', ground: '#273044', grass: '#67afbc', glow: '#93e8e9' },
};

function imageWithAlphaCrop(url) {
  return new Promise((resolve) => {
    const img = new Image();
    img.onload = () => {
      const canvas = document.createElement('canvas');
      canvas.width = img.naturalWidth;
      canvas.height = img.naturalHeight;
      const ctx = canvas.getContext('2d', { willReadFrequently: true });
      ctx.drawImage(img, 0, 0);
      const rgba = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
      let minX = canvas.width, minY = canvas.height, maxX = -1, maxY = -1;
      for (let y = 0; y < canvas.height; y++) for (let x = 0; x < canvas.width; x++) {
        if (rgba[(y * canvas.width + x) * 4 + 3] < 16) continue;
        minX = Math.min(minX, x); minY = Math.min(minY, y);
        maxX = Math.max(maxX, x); maxY = Math.max(maxY, y);
      }
      resolve({ img, crop: maxX < 0 ? [0, 0, canvas.width, canvas.height] : [minX, minY, maxX - minX + 1, maxY - minY + 1] });
    };
    img.onerror = () => resolve(null);
    img.src = url;
  });
}

export async function loadSprites() {
  const entries = await Promise.all(Object.entries(SPRITE_PATHS).map(async ([name, path]) => [name, await imageWithAlphaCrop(path)]));
  return Object.fromEntries(entries);
}

function drawSprite(ctx, sprite, centerX, bottomY, height, facing = 1) {
  if (!sprite) return false;
  const [sx, sy, sw, sh] = sprite.crop;
  const width = height * sw / sh;
  ctx.save();
  ctx.translate(centerX, 0);
  ctx.scale(facing, 1);
  ctx.drawImage(sprite.img, sx, sy, sw, sh, -width / 2, bottomY - height, width, height);
  ctx.restore();
  return true;
}

function ridge(ctx, color, camera, factor, baseY, amplitude, period) {
  ctx.fillStyle = color;
  ctx.beginPath(); ctx.moveTo(0, VIEW_HEIGHT);
  for (let x = 0; x <= VIEW_WIDTH + 20; x += 20) {
    const world = x + camera * factor;
    const y = baseY + Math.sin(world / period) * amplitude + Math.sin(world / (period * .46)) * amplitude * .28;
    ctx.lineTo(x, y);
  }
  ctx.lineTo(VIEW_WIDTH, VIEW_HEIGHT); ctx.closePath(); ctx.fill();
}

function drawBackdrop(ctx, state, palette) {
  const camera = state.cameraX;
  const grad = ctx.createLinearGradient(0, 0, 0, VIEW_HEIGHT);
  grad.addColorStop(0, palette.sky); grad.addColorStop(1, palette.horizon);
  ctx.fillStyle = grad; ctx.fillRect(0, 0, VIEW_WIDTH, VIEW_HEIGHT);

  // The parallax shapes are authored for this preview. Concept boards are not tiled.
  ridge(ctx, palette.far, camera, .12, 275, 27, 115);
  ridge(ctx, palette.middle, camera, .28, 340, 32, 83);
  const stride = state.room.biome === 'forest' ? 165 : 205;
  const start = Math.floor(camera * .47 / stride) - 2;
  const end = start + Math.ceil(VIEW_WIDTH / stride) + 5;
  for (let i = start; i <= end; i++) {
    const x = i * stride - camera * .47;
    if (state.room.biome === 'forest') {
      ctx.fillStyle = '#193e35'; ctx.fillRect(x + 10, 255, 18, 230);
      ctx.fillStyle = i % 2 ? '#2d6854' : '#31735d';
      for (let j = 0; j < 3; j++) { ctx.beginPath(); ctx.ellipse(x + 19, 235 - j * 28, 72 - j * 9, 58 - j * 5, 0, 0, Math.PI * 2); ctx.fill(); }
    } else if (state.room.biome === 'castle') {
      ctx.fillStyle = '#343549'; ctx.fillRect(x, 240 + (i % 3) * 25, 118, 260);
      ctx.fillStyle = '#5d5c6f'; ctx.fillRect(x + 12, 200 + (i % 3) * 25, 90, 35);
      ctx.fillStyle = '#d7b98d'; ctx.fillRect(x + 45, 275 + (i % 3) * 25, 22, 56);
    } else {
      ctx.fillStyle = '#18334b';
      ctx.beginPath(); ctx.moveTo(x - 35, 0); ctx.lineTo(x + 30, 175 + (i % 3) * 40); ctx.lineTo(x + 90, 0); ctx.fill();
      ctx.fillStyle = '#326781'; ctx.beginPath(); ctx.ellipse(x + 20, 360, 45, 11, 0, 0, Math.PI * 2); ctx.fill();
    }
  }
  ridge(ctx, palette.front, camera, .52, 425, 17, 62);
  ctx.fillStyle = '#ffffff0d';
  for (let n = 0; n < 30; n++) {
    const x = ((n * 163.31 - camera * .15) % 1030 + 1030) % 1030 - 35;
    const y = 65 + (n * 97) % 280;
    ctx.beginPath(); ctx.arc(x, y, 1 + n % 3, 0, Math.PI * 2); ctx.fill();
  }
}

function drawPlatform(ctx, platform, camera, palette, tile) {
  const x = platform.x - camera;
  if (x + platform.w < -40 || x > VIEW_WIDTH + 40) return;
  const visibleX = Math.max(x, -10), visibleRight = Math.min(x + platform.w, VIEW_WIDTH + 10);
  ctx.fillStyle = platform.kind === 'branch' ? '#414537' : palette.ground;
  ctx.fillRect(visibleX, platform.y, visibleRight - visibleX, platform.h);
  ctx.fillStyle = palette.grass; ctx.fillRect(visibleX, platform.y, visibleRight - visibleX, 5);
  if (tile) {
    for (let tx = Math.floor((visibleX - x) / 32) * 32; tx < platform.w && x + tx < visibleRight; tx += 32) {
      ctx.drawImage(tile.img, x + tx, platform.y + 5, 32, 25);
    }
  }
  ctx.fillStyle = '#0d151650';
  for (let tx = Math.floor((visibleX - x) / 56) * 56; tx < platform.w && x + tx < visibleRight; tx += 56) {
    ctx.fillRect(x + tx + 10, platform.y + 34, 3, Math.min(15, platform.h - 35));
  }
}

function label(ctx, text, x, y, color = '#f4eddb') {
  ctx.font = 'bold 12px Trebuchet MS, sans-serif';
  const w = ctx.measureText(text).width + 20;
  ctx.fillStyle = '#11231de5'; ctx.fillRect(x - w / 2, y - 20, w, 25);
  ctx.strokeStyle = color; ctx.strokeRect(x - w / 2, y - 20, w, 25);
  ctx.fillStyle = color; ctx.textAlign = 'center'; ctx.fillText(text, x, y - 3);
}

function drawShell(ctx, shell, camera, time, palette) {
  if (shell.collected) return;
  const x = shell.x - camera, y = shell.y + Math.sin(time * 4 + shell.x * .01) * 4;
  if (x < -30 || x > VIEW_WIDTH + 30) return;
  ctx.save(); ctx.translate(x, y);
  ctx.shadowColor = palette.glow; ctx.shadowBlur = 16;
  ctx.fillStyle = '#fae6b2'; ctx.strokeStyle = '#8b653e'; ctx.lineWidth = 2;
  ctx.beginPath(); ctx.moveTo(-13, 6); ctx.bezierCurveTo(-18, -15, 14, -18, 13, 6); ctx.bezierCurveTo(6, 19, -6, 19, -13, 6); ctx.fill(); ctx.stroke();
  ctx.shadowBlur = 0; ctx.strokeStyle = '#8b653e';
  for (let k = -2; k <= 2; k++) { ctx.beginPath(); ctx.moveTo(k * 4, -8); ctx.lineTo(k * 2.5, 7); ctx.stroke(); }
  ctx.fillStyle = '#795335'; ctx.beginPath(); ctx.ellipse(0, 7, 5, 3, 0, 0, Math.PI * 2); ctx.fill();
  ctx.restore();
}

function drawMarkers(ctx, state, camera, sprites, palette) {
  const entranceX = state.entrance.x - camera;
  if (entranceX > -80 && entranceX < VIEW_WIDTH + 80) {
    ctx.fillStyle = '#e9d7a8'; ctx.fillRect(entranceX + 8, 305, 5, GROUND_Y - 305);
    ctx.fillStyle = '#9f7547'; ctx.fillRect(entranceX + 12, 320, 105, 36);
    label(ctx, 'ENTRADA', entranceX + 64, 346, '#f8e2a8');
  }
  const checkpointX = state.checkpoint.x - camera;
  if (checkpointX > -70 && checkpointX < VIEW_WIDTH + 70) {
    ctx.fillStyle = state.checkpoint.activated ? '#e3cc79' : '#8da99e';
    ctx.fillRect(checkpointX, 310, 5, GROUND_Y - 310);
    ctx.beginPath(); ctx.moveTo(checkpointX + 5, 312); ctx.lineTo(checkpointX + 63, 327); ctx.lineTo(checkpointX + 5, 342); ctx.fill();
    label(ctx, state.checkpoint.activated ? 'CHECKPOINT ✓' : 'CHECKPOINT', checkpointX + 30, 300, palette.glow);
  }
  const exitX = state.exit.x - camera + state.exit.w / 2;
  if (exitX > -100 && exitX < VIEW_WIDTH + 100) {
    ctx.save(); ctx.globalAlpha = state.exit.ready ? 1 : .47;
    if (!drawSprite(ctx, sprites.portal, exitX, GROUND_Y + 9, 140)) {
      ctx.strokeStyle = state.exit.ready ? '#b3e7c1' : '#758276'; ctx.lineWidth = 8;
      ctx.beginPath(); ctx.ellipse(exitX, GROUND_Y - 60, 37, 65, 0, 0, Math.PI * 2); ctx.stroke();
    }
    ctx.restore();
    label(ctx, state.exit.ready ? 'E · ENTRAR' : 'DERROTE OS INIMIGOS', exitX, 285, state.exit.ready ? '#c2f9bf' : '#dfb3a1');
  }
}

function drawEnemies(ctx, state, camera, sprites) {
  for (const enemy of state.enemies) {
    if (!enemy.alive) continue;
    const x = enemy.x - camera + enemy.w / 2;
    if (x < -100 || x > VIEW_WIDTH + 100) continue;
    const sprite = enemy.boss ? (state.room.biome === 'castle' ? sprites.bossCastle : state.room.biome === 'caves' ? sprites.bossCaves : sprites.bossForest) : (enemy.cooldown < .25 ? sprites.enemyAttack : sprites.enemyRun);
    ctx.save();
    if (enemy.hurt > 0) ctx.globalAlpha = .55 + Math.sin(state.time * 42) * .35;
    if (!drawSprite(ctx, sprite, x, enemy.y + enemy.h + 4, enemy.boss ? 132 : 83, enemy.facing)) {
      ctx.fillStyle = enemy.boss ? '#a06dba' : '#9b615c'; ctx.fillRect(enemy.x - camera, enemy.y, enemy.w, enemy.h);
    }
    ctx.restore();
    const width = enemy.boss ? 92 : 54;
    ctx.fillStyle = '#1b1419'; ctx.fillRect(x - width / 2, enemy.y - 17, width, 7);
    ctx.fillStyle = enemy.boss ? '#da9fe4' : '#ec927f'; ctx.fillRect(x - width / 2, enemy.y - 17, width * Math.max(0, enemy.hp / enemy.maxHp), 7);
    if (enemy.boss) label(ctx, `GUARDIÃO · FASE ${enemy.phase || 1}`, x, enemy.y - 29, '#f0b4e6');
  }
}

function drawGameplayDetails(ctx, state) {
  const camera=state.cameraX;
  for (const landmark of state.room.landmarks ?? []) {
    const x=landmark.index*VIEW_WIDTH+VIEW_WIDTH*.55-camera;
    if (x < -130 || x > VIEW_WIDTH+130 || landmark.role==='entry' || landmark.role==='exit') continue;
    ctx.save();ctx.globalAlpha=.48;
    const color=state.room.biome==='forest'?'#a8ce77':state.room.biome==='castle'?'#c5a88d':'#80d6ed';
    ctx.strokeStyle=color;ctx.lineWidth=4;
    ctx.beginPath();ctx.arc(x,GROUND_Y-70,32,Math.PI,Math.PI*2);ctx.stroke();
    ctx.fillStyle=color;ctx.fillRect(x-5,GROUND_Y-66,10,54);
    ctx.restore();
    label(ctx,landmark.name.slice(0,30).toUpperCase(),x,GROUND_Y-113,color);
  }
  for (const ring of state.rings ?? []) {
    const x=ring.x-camera;
    if(x < -50 || x > VIEW_WIDTH+50) continue;
    ctx.strokeStyle='#f4c975';ctx.lineWidth=7;
    ctx.beginPath();ctx.arc(x,ring.y,18,0,Math.PI*2);ctx.stroke();
    ctx.strokeStyle='#efdbb8';ctx.lineWidth=3;
    ctx.beginPath();ctx.moveTo(x,0);ctx.lineTo(x,ring.y-21);ctx.stroke();
  }
  for (const chest of state.chests ?? []) {
    const x=chest.x-camera;
    if(x < -80 || x > VIEW_WIDTH+80) continue;
    ctx.fillStyle=chest.kind==='rare'?'#8c6653':'#5f654c';
    ctx.fillRect(x,chest.y+11,chest.w,chest.h-11);
    ctx.fillStyle=chest.opened?'#605949':'#d9ae61';
    ctx.fillRect(x-2,chest.y+(chest.opened?-7:1),chest.w+4,12);
    ctx.fillStyle='#2b2b2b';ctx.fillRect(x+chest.w/2-3,chest.y+13,6,10);
    if(!chest.opened) label(ctx,chest.kind==='rare'?'BAÚ RARO':'BAÚ',x+chest.w/2,chest.y-20,chest.kind==='rare'?'#ffcd8e':'#d7e0bc');
  }
  for (const enemy of state.enemies) {
    if(!enemy.boss || !enemy.alive || enemy.windup<=0) continue;
    const x=enemy.x-camera+enemy.w/2;
    ctx.save();
    ctx.globalAlpha=.27+.15*Math.sin(state.time*24);
    ctx.fillStyle=enemy.phase===2?'#ff5656':'#fca36d';
    const w=enemy.phase===2?340:260;
    ctx.fillRect(x-w/2,GROUND_Y-11,w,11);
    ctx.restore();
  }
}

function drawPlayer(ctx, state, camera, sprites) {
  const p = state.player;
  const x = p.x - camera + p.w / 2;
  ctx.save();
  if (p.invuln > 0 && Math.floor(state.time * 12) % 2 === 0) ctx.globalAlpha = .55;
  const sprite = p.attackTime > 0 ? sprites.attack : !p.grounded ? sprites.jump : Math.abs(p.vx) > 20 ? (Math.floor(state.time * 8) % 2 ? sprites.run1 : sprites.run2) : sprites.idle;
  if (!drawSprite(ctx, sprite, x, p.y + p.h + 5, 91, p.facing)) {
    ctx.fillStyle = '#eed681'; ctx.fillRect(p.x - camera, p.y, p.w, p.h);
  }
  if (p.attackTime > 0) {
    ctx.strokeStyle = p.attackSpecial ? '#7adfff' : '#f9d98cd0'; ctx.lineWidth = 7; ctx.beginPath();
    ctx.arc(x + p.facing * 26, p.y + 28, 40, p.facing > 0 ? -.9 : 2.1, p.facing > 0 ? 1.1 : 4.1); ctx.stroke();
  }
  ctx.restore();
}

export function render(ctx, state, sprites = {}) {
  const palette = PALETTES[state.room.biome] ?? PALETTES.forest;
  ctx.clearRect(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
  drawBackdrop(ctx, state, palette);
  const tile = sprites[`${state.room.biome}Tile`];
  for (const platform of state.platforms) drawPlatform(ctx, platform, state.cameraX, palette, tile);
  drawGameplayDetails(ctx,state);
  drawMarkers(ctx, state, state.cameraX, sprites, palette);
  for (const shell of state.cowries) drawShell(ctx, shell, state.cameraX, state.time, palette);
  drawEnemies(ctx, state, state.cameraX, sprites);
  drawPlayer(ctx, state, state.cameraX, sprites);
  if (state.messageTime > 0 && state.message) {
    ctx.font = 'bold 15px Trebuchet MS, sans-serif'; ctx.textAlign = 'center';
    const w = Math.min(720, ctx.measureText(state.message).width + 34);
    ctx.fillStyle = '#0c1b17e8'; ctx.fillRect((VIEW_WIDTH - w) / 2, 24, w, 38);
    ctx.strokeStyle = '#b1cf9a'; ctx.strokeRect((VIEW_WIDTH - w) / 2, 24, w, 38);
    ctx.fillStyle = '#fff1c8'; ctx.fillText(state.message, VIEW_WIDTH / 2, 49);
  }
  if (state.status === 'gameover') {
    ctx.fillStyle = '#1a0e13b9'; ctx.fillRect(0, 0, VIEW_WIDTH, VIEW_HEIGHT);
    ctx.fillStyle = '#ffe5c7'; ctx.textAlign = 'center'; ctx.font = 'bold 52px Trebuchet MS, sans-serif';
    ctx.fillText('FIM DA JORNADA', VIEW_WIDTH / 2, 250);
    ctx.font = '20px Trebuchet MS, sans-serif'; ctx.fillText('Recomece para tentar outra vez', VIEW_WIDTH / 2, 290);
  }
}

/** A lightweight illustrated 2D hub for between-run navigation. */
export function renderSanctuary(ctx,hub,sprites={}) {
  const camera=hub.cameraX;
  ctx.clearRect(0,0,VIEW_WIDTH,VIEW_HEIGHT);
  const sky=ctx.createLinearGradient(0,0,0,VIEW_HEIGHT);
  sky.addColorStop(0,'#142b30');sky.addColorStop(.72,'#386251');sky.addColorStop(1,'#9b7955');
  ctx.fillStyle=sky;ctx.fillRect(0,0,VIEW_WIDTH,VIEW_HEIGHT);
  // Distant ancestral grove and layered stone relief: not a stretched concept board.
  ridge(ctx,'#254a47',camera,.08,330,38,139);
  ridge(ctx,'#315e55',camera,.20,390,17,92);
  for(let i=0;i<25;i++) {
    const wx=i*175+45,x=wx-camera*.55;
    if(x<-90||x>VIEW_WIDTH+90)continue;
    ctx.fillStyle='#264c40';ctx.fillRect(x,185,20,280);
    ctx.fillStyle=i%2?'#44745d':'#4e886b';
    ctx.beginPath();ctx.arc(x+10,171,50,0,Math.PI*2);ctx.fill();
  }
  // One continuous traversable floor through the whole refuge.
  ctx.fillStyle='#3a372e';ctx.fillRect(0,460,960,80);
  ctx.fillStyle='#b6a378';ctx.fillRect(0,459,960,9);
  ctx.fillStyle='#24382f';for(let i=0;i<40;i++){
    const x=((i*101-camera)%1000+1000)%1000;
    ctx.fillRect(x,479+(i%3)*10,36,4);
  }
  const stations=[
    [420,'Ancestrais','#d6ba82','◌'],[940,'Forja','#ed8f60','⚒'],
    [1490,'Habilidades','#a4d6ff','✦'],[2070,'Fonte','#88dbeb','◈'],
    [2820,'Retorno','#bcf0be','◇'],
  ];
  for(const [world,name,color,glyph] of stations) {
    const x=world-camera;
    if(x<-160||x>VIEW_WIDTH+160)continue;
    ctx.fillStyle='#283a33';ctx.fillRect(x-63,332,126,126);
    ctx.strokeStyle=color;ctx.lineWidth=6;ctx.strokeRect(x-58,335,116,118);
    ctx.fillStyle=color;ctx.textAlign='center';ctx.font='bold 48px serif';
    ctx.fillText(glyph,x,412);
    label(ctx,name.toUpperCase(),x,321,color);
    if(Math.abs(hub.playerX-world)<100)label(ctx,'E · INTERAGIR',x,280,'#fff3c7');
  }
  // Hero uses the same isolated protagonist sprite as gameplay.
  const px=hub.playerX-camera;
  if(!drawSprite(ctx,sprites.idle,px,465,95,1)){
    ctx.fillStyle='#e5c684';ctx.fillRect(px-22,390,44,70);
  }
  ctx.fillStyle='#10251fe8';ctx.fillRect(0,0,VIEW_WIDTH,85);
  ctx.fillStyle='#f4daa0';ctx.font='bold 27px Trebuchet MS,sans-serif';ctx.textAlign='left';
  ctx.fillText('SANTUÁRIO ANCESTRAL',24,35);
  ctx.fillStyle='#e5f0db';ctx.font='15px Trebuchet MS,sans-serif';
  ctx.fillText('Caminhe, converse, melhore Akane e inicie uma nova jornada',24,62);
  const msg=hub.message;
  ctx.fillStyle='#10241ee6';ctx.fillRect(0,492,VIEW_WIDTH,48);
  ctx.font='bold 14px Trebuchet MS,sans-serif';ctx.textAlign='center';ctx.fillStyle='#f9efd2';
  // Wrap long lore into two lines without hiding gameplay.
  const limit=112;
  if(msg.length>limit){ctx.fillText(msg.slice(0,limit),VIEW_WIDTH/2,508);ctx.fillText(msg.slice(limit,limit*2),VIEW_WIDTH/2,528);}
  else ctx.fillText(msg,VIEW_WIDTH/2,521);
}
