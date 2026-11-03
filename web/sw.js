/* Prototype offline shell cache. Bump version when changing deploy assets. */
const VERSION = 'rasta-quest-preview-20261103-v4';
const SHELL = [
  './', './index.html', './style.css', './main.mjs', './engine.mjs',
  './progression.mjs', './run-save.mjs', './loot.mjs', './renderer.mjs', './data/rooms.json', './data/skills.json',
  './manifest.webmanifest', './app-icon.svg'
];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(VERSION).then(cache => cache.addAll(SHELL)));
  self.skipWaiting();
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(
    keys.filter(key => key.startsWith('rasta-quest-preview-') && key !== VERSION).map(key => caches.delete(key))
  )));
  self.clients.claim();
});
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET' || new URL(event.request.url).origin !== self.location.origin) return;
  event.respondWith(fetch(event.request).then(response => {
    if (response.ok && response.type === 'basic') {
      const copy = response.clone();
      event.waitUntil(caches.open(VERSION).then(cache => cache.put(event.request, copy)));
    }
    return response;
  }).catch(async () => {
    const cached = await caches.match(event.request);
    if (cached) return cached;
    if (event.request.mode === 'navigate') return caches.match('./index.html');
    return Response.error();
  }));
});