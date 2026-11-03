/**
 * Offline HTML packer for internal game playtesting. Zero external dependencies.
 * Converts the existing reviewed web runtime into one self-contained document,
 * so an end user can open a downloaded HTML file without Node/Unity/network.
 *
 * This is a build-only transform; the canonical code remains the ES modules
 * and rooms.json. It is not a native Android/Windows build.
 */
import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const root = dirname(fileURLToPath(import.meta.url));
const read = path => readFileSync(join(root, path), 'utf8');
const plan = JSON.parse(read('data/rooms.json'));
const skillDesign = JSON.parse(read('data/skills.json'));
if (skillDesign.branches?.reduce((total, branch) => total + branch.nodes.length, 0) !== 25) {
  throw new Error('Unexpected skill tree version');
}
if (plan.rooms?.length !== 21 || plan.expected_cowries !== 105) {
  throw new Error('Unexpected room plan, refusing to build offline preview');
}
const modules = ['loot.mjs', 'progression.mjs', 'engine.mjs',
  'run-save.mjs', 'renderer.mjs', 'main.mjs'];
const assetNames = [
  'player-idle.png', 'player-run.png', 'player-jump.png',
  'player-attack.png', 'enemy-idle.png', 'enemy-attack.png', 'portal.png',
  'boss-forest.png', 'boss-castle.png', 'boss-caves.png',
  'terrain-forest.png', 'terrain-castle.png', 'terrain-caves.png',
];
const assets = new Map(assetNames.map(name =>
  [name, 'data:image/png;base64,' + readFileSync(join(root, 'assets', name)).toString('base64')]));

let js = modules.map(name => {
  let source = read(name);
  source = source.replace(/^import\s+[^;]+;\s*$/gm, '');
  source = source.replace(/\bexport\s+(?=(?:const|let|function|async|class)\b)/g, '');
  return '// bundled: ' + name + '\n' + source;
}).join('\n\n');

js = js.replace(/(['"])assets\/([a-z0-9-]+\.png)\1/g, (match, quote, name) => {
  const asset = assets.get(name);
  if (!asset) throw new Error('Unknown sprite path: ' + name);
  return quote + asset + quote;
});

const fetchClause = `    const response = await fetch('./data/rooms.json', { cache: 'no-store' });
    if (!response.ok) throw new Error(\`HTTP \${response.status}\`);
    plan = await response.json();`;
if (!js.includes(fetchClause)) throw new Error('Room-plan loader changed; update bundler');
js = js.replace(fetchClause, '    plan = __RASTA_EMBEDDED_PLAN__;');
const skillsClause = `      const skillResponse = await fetch('./data/skills.json', { cache: 'no-store' });
      if (!skillResponse.ok) throw new Error('skill-design ' + skillResponse.status);
      const skillDesign = await skillResponse.json();`;
if (!js.includes(skillsClause)) throw new Error('Skill design loader changed; update bundler');
js = js.replace(skillsClause, '      const skillDesign = __RASTA_EMBEDDED_SKILLS__;');
const serviceWorkerClause = `if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(() => {}));
}`;
if (!js.includes(serviceWorkerClause)) throw new Error('Service worker setup changed; update bundler');
js = js.replace(serviceWorkerClause, '// No service worker registration in file:// distribution.');
js = 'const __RASTA_EMBEDDED_PLAN__ = ' + JSON.stringify(plan) + ';\n' +
  'const __RASTA_EMBEDDED_SKILLS__ = ' + JSON.stringify(skillDesign) + ';\n' + js;

// Validates the complete assembled script, including duplicate declarations.
new Function(js);
let html = read('index.html');
html = html.replace('<link rel="manifest" href="./manifest.webmanifest">', '');
html = html.replace('<link rel="icon" type="image/svg+xml" href="./app-icon.svg">', '');
html = html.replace('<link rel="stylesheet" href="./style.css">', '<style>\n' + read('style.css') + '\n</style>');
const sourceScript = '<script type="module" src="./main.mjs"></script>';
if (!html.includes(sourceScript)) throw new Error('Entry script changed; update bundler');
html = html.replace(sourceScript, '<script>\n' + js.replace(/<\/script/gi, '<\\/script') + '\n</script>');
const outdir = join(root, 'dist');
mkdirSync(outdir, { recursive: true });
const output = join(outdir, 'rasta-quest-offline.html');
writeFileSync(output, html);
console.log('Standalone HTML built: web/dist/rasta-quest-offline.html', Buffer.byteLength(html), 'bytes');
