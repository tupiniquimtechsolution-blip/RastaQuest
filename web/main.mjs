import { createGame, step, restoreRun } from './engine.mjs';
import { readSavedRun, writeSavedRun, eraseSavedRun } from './run-save.mjs';
import { loadSprites, render, renderSanctuary } from './renderer.mjs';
import { createSanctuary, stepSanctuary } from './sanctuary.mjs';
import { loadProfile, saveProfile, purchaseUpgrade, upgradeCost, equipItem, equipSkin } from './progression.mjs';
import { EQUIPMENT, SLOTS, equipmentBonus } from './content.mjs';
import { SKILL_TREE, skillBonus, canPurchaseSkill, purchaseSkill } from './skills.mjs';

const canvas = document.querySelector('#game');
const ctx = canvas.getContext('2d');
const startOverlay = document.querySelector('#startOverlay');
const endOverlay = document.querySelector('#endOverlay');
const helpDialog = document.querySelector('#helpDialog');
const pauseDialog = document.querySelector('#pauseDialog');
const skillsDialog = document.querySelector('#skillsDialog');
const touchButtons = [...document.querySelectorAll('[data-control]')];
const keys = new Set();
const touch = new Set();
let plan, state, profile, sprites = {}, started = false, lastFrame = 0;
let savedRevision = -1;
let lastRunSaveAt = 0, runEnded = false;
let hubActive=false, hub=null;
const profileStore = (() => { try { return window.localStorage; } catch { return null; } })();

const keyMap = new Map([
  ['ArrowLeft', 'left'], ['KeyA', 'left'],
  ['ArrowRight', 'right'], ['KeyD', 'right'],
  ['ArrowUp', 'jump'], ['KeyW', 'jump'], ['Space', 'jump'],
  ['KeyJ', 'attack'], ['KeyK', 'special'], ['KeyL', 'special'],
  ['KeyQ', 'block'],
  ['KeyE', 'interact'], ['Enter', 'interact'],
]);

function updateText(id, value) {
  const node = document.getElementById(id);
  if (node.textContent !== value) node.textContent = value;
}

function biomeName(biome) {
  return { forest: 'FLORESTA', castle: 'CASTELO', caves: 'CAVERNAS' }[biome] ?? biome.toUpperCase();
}

function syncHud() {
  if (!state) return;
  const p = state.player;
  updateText('biomeName', `${biomeName(state.room.biome)} · SALA ${String(state.roomIndex % 7 + 1).padStart(2, '0')}`);
  updateText('roomName', state.room.title);
  updateText('health', '♥ '.repeat(p.hp).trim() + '♡ '.repeat(Math.max(0, p.maxHp - p.hp)).trim());
  updateText('lives', `VIDAS ${String(p.lives).padStart(2, '0')}`);
  updateText('mana', `MANA ${p.mana}/${p.maxMana}`);
  updateText('shells', `BÚZIOS ${state.roomCollected}/5`);
  updateText('total', `ÁLBUM ${profile?.collectedCowries.length ?? 0}/105`);
  updateText('essence', `ESSÊNCIA ${profile?.essence ?? 0}`);
  updateText('runBuff', `BÊNÇÃOS +${state.runBuffs.damage}D / +${state.runBuffs.mana}M / +${state.runBuffs.mobility}V`);
  updateText('upgradeStatus', profile ? `VIDA +${profile.upgrades.vitality} · DANO +${profile.upgrades.strength} · MANA +${profile.upgrades.spirit} · HABILIDADES ${profile.skills.length}/25 · SKINS ${profile.skins.length}/2` : '');
  const fallback = state.exit.ready ? 'Portal aberto: aproxime-se e pressione E ou ENTRAR.' : 'Explore a rota, pegue os búzios e derrote os inimigos.';
  updateText('message', state.message || fallback);
  const dots = document.querySelectorAll('.route-dot');
  dots.forEach((dot, index) => {
    dot.classList.toggle('done', index < state.roomIndex);
    dot.classList.toggle('current', index === state.roomIndex);
    dot.setAttribute('aria-current', index === state.roomIndex ? 'step' : 'false');
  });
  if (state.status !== 'playing' && endOverlay.classList.contains('hidden')) {
    updateText('endEyebrow', state.status === 'won' ? 'JORNADA CONCLUÍDA' : 'TENTE NOVAMENTE');
    updateText('endTitle', state.status === 'won' ? 'Vitória!' : 'Fim da jornada');
    updateText('endBody', state.status === 'won'
      ? `Você atravessou as 21 salas e recolheu ${state.totalCollected} de 105 búzios planejados.`
      : `Você chegou à sala ${state.roomIndex + 1} e recolheu ${state.totalCollected} búzios.`);
    endOverlay.classList.remove('hidden');
  }
}

function currentInput() {
  const values = new Set([...keys, ...touch]);
  try {
    const pad = navigator.getGamepads?.()[0];
    if (pad) {
      const buttons = pad.buttons;
      if (pad.axes[0] < -0.28 || buttons[14]?.pressed) values.add('left');
      if (pad.axes[0] > 0.28 || buttons[15]?.pressed) values.add('right');
      if (buttons[0]?.pressed) values.add('jump');
      if (buttons[2]?.pressed) values.add('attack');
      if (buttons[3]?.pressed) values.add('special');
      if (buttons[1]?.pressed) values.add('interact');
      if (buttons[4]?.pressed) values.add('block');
    }
  } catch { /* Some privacy profiles disable the Gamepad API. */ }
  return Object.fromEntries(['left', 'right', 'jump', 'attack', 'special', 'block', 'interact']
    .map(control => [control, values.has(control)]));
}

function frame(timestamp) {
  if (!lastFrame) lastFrame = timestamp;
  const elapsed = Math.min((timestamp - lastFrame) / 1000, 1 / 30);
  lastFrame = timestamp;
  if (state) {
    if (hubActive) {
      if(started && !helpDialog.open && !pauseDialog.open && !skillsDialog.open) {
        const action=stepSanctuary(hub,currentInput(),elapsed);
        if(action==='new_run') restart();
        else if(action==='equipment') {refreshUpgrades();pauseDialog.showModal();}
        else if(action==='skills') {refreshSkills();skillsDialog.showModal();}
      }
      if(hubActive) {
        renderSanctuary(ctx,hub,sprites);
        updateText('biomeName','SANTUÁRIO');
        updateText('roomName','Pátio dos Ancestrais');
        updateText('message','Ande até as estações e pressione E/ENTRAR.');
        requestAnimationFrame(frame);
        return;
      }
    }
    if (started && !helpDialog.open && !pauseDialog.open && !skillsDialog.open && state.status === 'playing') step(state, currentInput(), elapsed);
    if (started && state.status === 'playing' && timestamp - lastRunSaveAt >= 3000) {
      writeSavedRun(profileStore,state);
      lastRunSaveAt=timestamp;
    }
    if (started && state.status !== 'playing' && !runEnded) {
      eraseSavedRun(profileStore);
      runEnded=true;
    }
    if (profile && state.profileRevision !== savedRevision) {
      saveProfile(profileStore, profile);
      savedRevision = state.profileRevision;
      refreshUpgrades();
    }
    render(ctx, state, sprites);
    syncHud();
  }
  requestAnimationFrame(frame);
}

function restart() {
  if (!plan) return;
  eraseSavedRun(profileStore);
  state = createGame(plan, profile);
  lastRunSaveAt = 0; runEnded=false;
  hubActive=false; hub=null;
  savedRevision = -1;
  started = true;
  keys.clear(); touch.clear();
  touchButtons.forEach(button => button.classList.remove('pressed'));
  startOverlay.classList.add('hidden');
  endOverlay.classList.add('hidden');
  lastFrame = 0;
  syncHud();
}

function setupRoute() {
  const route = document.querySelector('#routeTrack');
  route.replaceChildren();
  plan.rooms.forEach((room, index) => {
    const dot = document.createElement('span');
    dot.className = 'route-dot';
    dot.title = `${index + 1}/21 · ${room.title}`;
    dot.setAttribute('aria-label', `Sala ${index + 1}: ${room.title}`);
    route.append(dot);
  });
}

window.addEventListener('keydown', event => {
  if (event.code === 'Escape' && !helpDialog.open && started) {
    event.preventDefault();
    if(skillsDialog.open) {skillsDialog.close();pauseDialog.showModal();}
    else if(pauseDialog.open) pauseDialog.close();
    else pauseDialog.showModal();
    keys.clear(); touch.clear(); return;
  }
  const control = keyMap.get(event.code);
  if (!control || helpDialog.open || pauseDialog.open || skillsDialog.open) return;
  event.preventDefault();
  keys.add(control);
});
window.addEventListener('keyup', event => {
  const control = keyMap.get(event.code);
  if (!control) return;
  event.preventDefault();
  keys.delete(control);
});
window.addEventListener('blur', () => { keys.clear(); touch.clear(); touchButtons.forEach(button => button.classList.remove('pressed')); });

for (const button of touchButtons) {
  const control = button.dataset.control;
  button.addEventListener('pointerdown', event => {
    event.preventDefault(); button.setPointerCapture(event.pointerId);
    touch.add(control); button.classList.add('pressed');
  });
  const release = event => {
    event.preventDefault(); touch.delete(control); button.classList.remove('pressed');
  };
  button.addEventListener('pointerup', release);
  button.addEventListener('pointercancel', release);
  button.addEventListener('lostpointercapture', release);
}

document.querySelector('#startButton').addEventListener('click', () => { started = true; startOverlay.classList.add('hidden'); });
document.querySelector('#restartButton').addEventListener('click', restart);
document.querySelector('#newGameButton').addEventListener('click',restart);
document.querySelector('#endButton').addEventListener('click', restart);
document.querySelector('#sanctuaryButton').addEventListener('click', () => {
  if(!profile || !started) return;
  eraseSavedRun(profileStore);
  hub=createSanctuary();
  hubActive=true;
  runEnded=true;
  endOverlay.classList.add('hidden');
  keys.clear();touch.clear();
  refreshUpgrades();
});
document.querySelector('#helpButton').addEventListener('click', () => { keys.clear(); touch.clear(); helpDialog.showModal(); });
document.querySelector('#closeHelp').addEventListener('click', () => helpDialog.close());
document.querySelector('#pauseButton').addEventListener('click', () => {
  if (!state || !started) return;
  keys.clear(); touch.clear(); refreshUpgrades(); pauseDialog.showModal();
});
document.querySelector('#closePause').addEventListener('click', () => pauseDialog.close());
document.querySelector('#skillOpen').addEventListener('click', () => {
  pauseDialog.close();
  refreshSkills();
  skillsDialog.showModal();
});
document.querySelector('#closeSkills').addEventListener('click', () => {
  skillsDialog.close(); refreshUpgrades(); pauseDialog.showModal();
});
document.querySelector('#skillGrid').addEventListener('click', event => {
  const button=event.target.closest('button[data-skill]');
  if(!button || !profile) return;
  const id=button.dataset.skill;
  if(purchaseSkill(profile,id)) {
    saveProfile(profileStore,profile);
    applyProfileStats();
    refreshSkills(); refreshUpgrades(); syncHud();
    updateText('skillMessage','Habilidade adquirida e salva!');
  } else updateText('skillMessage','Requisitos ou essência insuficientes.');
});

function applyProfileStats() {
  if(!state || !profile) return;
  const p=state.player;
  const maxHp=3+profile.upgrades.vitality+equipmentBonus(profile,'vitality')+skillBonus(profile,'vitality');
  p.hp=Math.min(maxHp,Math.max(1,p.hp+Math.max(0,maxHp-p.maxHp)));
  p.maxHp=maxHp;
  const maxMana=3+profile.upgrades.spirit+equipmentBonus(profile,'mana')+skillBonus(profile,'mana')+state.runBuffs.mana;
  p.mana=Math.min(maxMana,Math.max(0,p.mana+Math.max(0,maxMana-p.maxMana)));
  p.maxMana=maxMana;
}
function refreshSkills() {
  if(!profile) return;
  const grid=document.querySelector('#skillGrid');
  grid.replaceChildren();
  for(const branch of SKILL_TREE.branches) {
    const section=document.createElement('section');section.className='skill-branch';
    const heading=document.createElement('h3');heading.textContent=branch.title;section.append(heading);
    for(const node of branch.nodes) {
      const owned=profile.skills.includes(node.id);
      const requires=node.requires.every(req=>req===SKILL_TREE.root || profile.skills.includes(req));
      const button=document.createElement('button');
      button.type='button';button.dataset.skill=node.id;
      button.disabled=owned || !requires;
      button.className=owned?'skill-owned':requires?'skill-available':'skill-locked';
      button.textContent=`${owned?'✓ ':requires?'＋ ':'🔒 '}${node.name} · ${owned?'Adquirida':node.cost+' essência'}`;
      section.append(button);
    }
    grid.append(section);
  }
}
document.querySelector('#skinControls').addEventListener('click', event => {
  const button=event.target.closest('button[data-skin-slot]');
  if(!button || !profile)return;
  const slot=button.dataset.skinSlot,id=slot==='akane'?'akane-ancestral':'axe-thunder';
  const next=profile.selectedSkins[slot]===id?'base':id;
  if(equipSkin(profile,slot,next)){
    saveProfile(profileStore,profile);
    refreshUpgrades();syncHud();
  }
});
document.querySelector('#equipmentInventory').addEventListener('click', event => {
  const button = event.target.closest('button[data-equip]');
  if (!button || !profile || !equipItem(profile, button.dataset.equip)) return;
  saveProfile(profileStore, profile);
  applyProfileStats();
  refreshUpgrades(); syncHud();
});
document.querySelector('#upgradeButtons').addEventListener('click', event => {
  const button = event.target.closest('button[data-upgrade]');
  if (!button || !profile) return;
  if (purchaseUpgrade(profile, button.dataset.upgrade)) {
    saveProfile(profileStore, profile);
    savedRevision = state.profileRevision;
    // Equipped permanent vitality is immediately reflected in the active run.
    applyProfileStats();
    refreshUpgrades(); syncHud();
  }
});

function refreshUpgrades() {
  if (!profile) return;
  const names = { vitality: 'Vida máxima', strength: 'Dano do machado', mobility: 'Corrida', spirit: 'Mana máxima' };
  for (const button of document.querySelectorAll('[data-upgrade]')) {
    const type = button.dataset.upgrade;
    const cost = upgradeCost(profile, type);
    button.disabled = cost === null || profile.essence < cost;
    button.textContent = `${names[type]} · nível ${profile.upgrades[type]}/5 · ${cost === null ? 'MÁXIMO' : cost + ' essências'}`;
  }
  updateText('albumProgress', `${profile.collectedCowries.length}/105 búzios únicos`);
  updateText('cosmeticRewards', profile.skins.length ? 'Skins de Akane e do machado desbloqueadas — equipar visuais: em desenvolvimento' : 'Skins de Akane e do machado desbloqueadas ao completar 105/105');
  updateText('essenceBalance', `${profile.essence} essências vermelhas disponíveis`);
  for(const button of document.querySelectorAll('[data-skin-slot]')) {
    const slot=button.dataset.skinSlot;
    const id=slot==='akane'?'akane-ancestral':'axe-thunder';
    const unlocked=profile.skins.includes(id);
    button.disabled=!unlocked;
    button.textContent=`${slot==='akane'?'Akane':'Machado'}: ${unlocked ? (profile.selectedSkins[slot]===id?'Visual ancestral ativo · retornar ao base':'Equipar visual conquistado') : 'Bloqueado até 105/105'}`;
  }
  const inventory = document.getElementById('equipmentInventory');
  if (inventory) {
    inventory.replaceChildren();
    for (const slot of SLOTS) {
      const title = document.createElement('strong');
      title.textContent = {blade:'Lâmina',haft:'Cabo',boots:'Botas',amulet:'Amuleto'}[slot];
      inventory.append(title);
      const owned = profile.equipment.owned.filter(id => EQUIPMENT[id].slot === slot);
      if (!owned.length) {
        const placeholder = document.createElement('span');
        placeholder.textContent = 'Nenhuma peça encontrada';
        inventory.append(placeholder);
      }
      for (const id of owned) {
        const item = EQUIPMENT[id];
        const button = document.createElement('button');
        button.type = 'button';
        button.dataset.equip = id;
        const active = profile.equipment.equipped[slot] === id;
        button.textContent = `${active ? '✓ ' : ''}${item.name} (${item.stat} +${item.value})`;
        button.disabled = active;
        inventory.append(button);
      }
    }
  }
}

async function boot() {
  try {
    const response = await fetch('./data/rooms.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    plan = await response.json();
    profile = loadProfile(profileStore, plan);
    const existing=readSavedRun(profileStore);
    state = restoreRun(plan,profile,existing);
    const resumable=Boolean(existing && existing.roomId===state.room.id && existing.version===1);
    if(resumable) {
      document.querySelector('#startButton').textContent='Continuar jornada';
      document.querySelector('#newGameButton').hidden=false;
    }
    savedRevision = state.profileRevision;
    runEnded=false;
    refreshUpgrades();
    setupRoute(); syncHud();
    sprites = await loadSprites();
  } catch (error) {
    updateText('roomName', 'Erro ao carregar o protótipo');
    updateText('message', `Não foi possível abrir os dados do jogo: ${error.message}. Use o servidor local indicado no README.`);
    document.querySelector('#startButton').disabled = true;
  }
  requestAnimationFrame(frame);
}

window.addEventListener('pagehide', () => {
  if(started && state?.status === 'playing') writeSavedRun(profileStore,state);
});

boot();

// HTTPS and localhost allow the preview to install and work offline after first load.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(() => {}));
}
