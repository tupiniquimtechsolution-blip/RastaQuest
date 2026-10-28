import { createGame, step } from './engine.mjs';
import { loadSprites, render } from './renderer.mjs';

const canvas = document.querySelector('#game');
const ctx = canvas.getContext('2d');
const startOverlay = document.querySelector('#startOverlay');
const endOverlay = document.querySelector('#endOverlay');
const helpDialog = document.querySelector('#helpDialog');
const touchButtons = [...document.querySelectorAll('[data-control]')];
const keys = new Set();
const touch = new Set();
let plan, state, sprites = {}, started = false, lastFrame = 0;

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
  updateText('total', `TOTAL ${state.totalCollected}/105`);
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
    if (started && !helpDialog.open && state.status === 'playing') step(state, currentInput(), elapsed);
    render(ctx, state, sprites);
    syncHud();
  }
  requestAnimationFrame(frame);
}

function restart() {
  if (!plan) return;
  state = createGame(plan);
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
  const control = keyMap.get(event.code);
  if (!control || helpDialog.open) return;
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

async function boot() {
  try {
    const response = await fetch('./data/rooms.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    plan = await response.json();
    state = createGame(plan);
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
