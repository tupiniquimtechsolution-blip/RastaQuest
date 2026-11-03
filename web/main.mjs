import { createGame, step } from './engine.mjs';
import { loadSprites, render } from './renderer.mjs';
import { loadProfile, saveProfile, purchaseUpgrade, upgradeCost } from './progression.mjs';

const canvas = document.querySelector('#game');
const ctx = canvas.getContext('2d');
const startOverlay = document.querySelector('#startOverlay');
const endOverlay = document.querySelector('#endOverlay');
const helpDialog = document.querySelector('#helpDialog');
const pauseDialog = document.querySelector('#pauseDialog');
const touchButtons = [...document.querySelectorAll('[data-control]')];
const keys = new Set();
const touch = new Set();
let plan, state, profile, sprites = {}, started = false, lastFrame = 0;
let savedRevision = -1;
const profileStore = (() => { try { return window.localStorage; } catch { return null; } })();

const keyMap = new Map([
  ['ArrowLeft', 'left'], ['KeyA', 'left'],
  ['ArrowRight', 'right'], ['KeyD', 'right'],
  ['ArrowUp', 'jump'], ['KeyW', 'jump'], ['Space', 'jump'],
  ['KeyJ', 'attack'], ['KeyK', 'attack'],
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
  updateText('shells', `BÚZIOS ${state.roomCollected}/5`);
  updateText('total', `ÁLBUM ${profile?.collectedCowries.length ?? 0}/105`);
  updateText('essence', `ESSÊNCIA ${profile?.essence ?? 0}`);
  updateText('upgradeStatus', profile ? `VIDA +${profile.upgrades.vitality} · DANO +${profile.upgrades.strength} · CORRIDA +${profile.upgrades.mobility} · SKINS ${profile.skins.length}/2` : '');
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
  return Object.fromEntries(['left', 'right', 'jump', 'attack', 'interact'].map(control => [control, values.has(control)]));
}

function frame(timestamp) {
  if (!lastFrame) lastFrame = timestamp;
  const elapsed = Math.min((timestamp - lastFrame) / 1000, 1 / 30);
  lastFrame = timestamp;
  if (state) {
    if (started && !helpDialog.open && !pauseDialog.open && state.status === 'playing') step(state, currentInput(), elapsed);
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
  state = createGame(plan, profile);
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
    event.preventDefault(); pauseDialog.open ? pauseDialog.close() : pauseDialog.showModal();
    keys.clear(); touch.clear(); return;
  }
  const control = keyMap.get(event.code);
  if (!control || helpDialog.open || pauseDialog.open) return;
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
document.querySelector('#endButton').addEventListener('click', restart);
document.querySelector('#helpButton').addEventListener('click', () => { keys.clear(); touch.clear(); helpDialog.showModal(); });
document.querySelector('#closeHelp').addEventListener('click', () => helpDialog.close());
document.querySelector('#pauseButton').addEventListener('click', () => {
  if (!state || !started) return;
  keys.clear(); touch.clear(); refreshUpgrades(); pauseDialog.showModal();
});
document.querySelector('#closePause').addEventListener('click', () => pauseDialog.close());
document.querySelector('#upgradeButtons').addEventListener('click', event => {
  const button = event.target.closest('button[data-upgrade]');
  if (!button || !profile) return;
  if (purchaseUpgrade(profile, button.dataset.upgrade)) {
    saveProfile(profileStore, profile);
    savedRevision = state.profileRevision;
    // Equipped permanent vitality is immediately reflected in the active run.
    const newMaxHp = 3 + profile.upgrades.vitality;
    if (newMaxHp > state.player.maxHp) state.player.hp += newMaxHp - state.player.maxHp;
    state.player.maxHp = newMaxHp;
    refreshUpgrades(); syncHud();
  }
});

function refreshUpgrades() {
  if (!profile) return;
  const names = { vitality: 'Vida máxima', strength: 'Dano do machado', mobility: 'Corrida' };
  for (const button of document.querySelectorAll('[data-upgrade]')) {
    const type = button.dataset.upgrade;
    const cost = upgradeCost(profile, type);
    button.disabled = cost === null || profile.essence < cost;
    button.textContent = `${names[type]} · nível ${profile.upgrades[type]}/5 · ${cost === null ? 'MÁXIMO' : cost + ' essências'}`;
  }
  updateText('albumProgress', `${profile.collectedCowries.length}/105 búzios únicos`);
  updateText('cosmeticRewards', profile.skins.length ? 'Skins de Akane e do machado desbloqueadas — equipar visuais: em desenvolvimento' : 'Skins de Akane e do machado desbloqueadas ao completar 105/105');
  updateText('essenceBalance', `${profile.essence} essências vermelhas disponíveis`);
}

async function boot() {
  try {
    const response = await fetch('./data/rooms.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    plan = await response.json();
    profile = loadProfile(profileStore, plan);
    state = createGame(plan, profile);
    savedRevision = state.profileRevision;
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

boot();

// HTTPS and localhost allow the preview to install and work offline after first load.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(() => {}));
}
