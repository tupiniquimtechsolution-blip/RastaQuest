/** Zero-npm Chromium smoke via CDP: actual browser UI, controls, PWA and mobile viewport.
 * Requires Google Chrome/Chromium installed on runner; no external website is visited.
 */
import { spawn, execFileSync } from 'node:child_process';
import { mkdtemp, mkdir, writeFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root=fileURLToPath(new URL('../',import.meta.url));
const screenshotDir=join(root,'web','test-results');
const sleep=ms=>new Promise(done=>setTimeout(done,ms));
const assert=(value,message)=>{if(!value)throw Error(message);};
function findChrome(){
  for(const name of ['google-chrome','chromium','chromium-browser']){
    try{return execFileSync('which',[name],{encoding:'utf8'}).trim();}
    catch{}
  }
  throw Error('Chrome/Chromium not found. Install browser on CI runner to run actual smoke.');
}
async function waitUntil(fn, timeout=16000){
  const until=Date.now()+timeout;let last;
  while(Date.now()<until){try{const v=await fn();if(v)return v;}catch(e){last=e;}await sleep(140);}
  throw Error('Timed out waiting for browser readiness: '+(last?.message||''));
}
const chromePath=findChrome();
const userDir=await mkdtemp(join(tmpdir(),'rasta-quest-chrome-'));
const port=9322;
let server,chrome,ws;
try{
  server=spawn(process.execPath,['web/serve.mjs'],{cwd:root,stdio:'ignore'});
  await waitUntil(async()=>{const res=await fetch('http://127.0.0.1:4173/');return res.ok;});
  chrome=spawn(chromePath,['--headless=new','--no-sandbox','--disable-gpu',
    '--disable-dev-shm-usage','--remote-allow-origins=*',
    '--remote-debugging-port='+port,'--user-data-dir='+userDir,
    '--window-size=1280,900','http://127.0.0.1:4173/'],{stdio:'ignore'});
  const page=await waitUntil(async()=>{
    const r=await fetch('http://127.0.0.1:'+port+'/json/list');
    if(!r.ok)return null;
    return (await r.json()).find(x=>x.type==='page'&&x.webSocketDebuggerUrl);
  });
  ws=new WebSocket(page.webSocketDebuggerUrl);
  await new Promise((resolve,reject)=>{ws.addEventListener('open',resolve,{once:true});ws.addEventListener('error',reject,{once:true});});
  let counter=0;const pending=new Map(),exceptions=[];
  ws.addEventListener('message',e=>{
    const m=JSON.parse(e.data);
    if(m.method==='Runtime.exceptionThrown')exceptions.push(m.params?.exceptionDetails?.text||'JS exception');
    const item=pending.get(m.id);
    if(item){pending.delete(m.id);m.error?item.reject(Error(JSON.stringify(m.error))):item.resolve(m.result);}
  });
  async function call(method,params={}){
    const id=++counter;
    return new Promise((resolve,reject)=>{
      pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));
    });
  }
  async function evalJS(expression) {
    const r=await call('Runtime.evaluate',{expression,returnByValue:true,awaitPromise:true});
    if(r.exceptionDetails)throw Error('Browser JS error: '+r.exceptionDetails.text);
    return r.result?.value;
  }
  await call('Page.enable');await call('Runtime.enable');
  await call('Emulation.setDeviceMetricsOverride',{width:1280,height:900,deviceScaleFactor:1,mobile:false});
  await waitUntil(async()=>await evalJS("!!document.querySelector('#startButton') && !document.querySelector('#startButton').disabled && document.querySelector('#routeTrack')?.children.length===21"));
  const ready=await evalJS("document.querySelector('#startButton').click();document.querySelector('#startOverlay').classList.contains('hidden')");
  assert(ready,'start overlay did not close');
  await call('Input.dispatchKeyEvent',{type:'keyDown',key:'d',code:'KeyD',windowsVirtualKeyCode:68});
  await sleep(1850);
  await call('Input.dispatchKeyEvent',{type:'keyUp',key:'d',code:'KeyD',windowsVirtualKeyCode:68});
  const shell=await waitUntil(async()=>await evalJS("document.querySelector('#shells').textContent.includes('1/5')"));
  assert(shell,'first cowrie cannot be collected by walking');
  assert(await evalJS("document.querySelector('#total').textContent.includes('1/105')"),'persistent album counter did not update');
  assert(await evalJS("document.querySelector('#pauseButton') && document.querySelector('#mana') && document.querySelector('#skillOpen')"),'new gameplay UI is missing');
  const skillsCount=await evalJS("(() => {document.querySelector('#pauseButton').click();document.querySelector('#skillOpen').click();const n=document.querySelectorAll('[data-skill]').length;document.querySelector('#closeSkills').click();document.querySelector('#closePause').click();return n})()");
  assert(skillsCount===25,'pause menu did not render 25 canonical skill nodes');
  await mkdir(screenshotDir,{recursive:true});
  let screen=await call('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});
  await writeFile(join(screenshotDir,'desktop-first-cowrie.png'),Buffer.from(screen.data,'base64'));
  await call('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:true});
  await sleep(300);
  const mobile=await evalJS("({buttons:[...document.querySelectorAll('[data-control]')].filter(x=>getComputedStyle(x).display!=='none').length,scrollWidth:document.documentElement.scrollWidth,width:innerWidth})");
  assert(mobile.buttons>=6,'mobile controls are missing');
  assert(mobile.scrollWidth<=mobile.width+3,'mobile document has horizontal overflow');
  screen=await call('Page.captureScreenshot',{format:'png',captureBeyondViewport:false});
  await writeFile(join(screenshotDir,'mobile-controls.png'),Buffer.from(screen.data,'base64'));
  const sw=await waitUntil(async()=>await evalJS("navigator.serviceWorker?.controller ? true : false"),12000);
  assert(sw,'PWA service worker did not take control');
  assert(await evalJS("fetch('./manifest.webmanifest').then(r=>r.ok)"),'manifest cannot be fetched');
  await call('Network.enable');
  await call('Network.emulateNetworkConditions',{offline:true,latency:0,downloadThroughput:0,uploadThroughput:0});
  await call('Page.reload',{ignoreCache:true});
  await waitUntil(async()=>await evalJS("!!document.querySelector('#startButton') && !document.querySelector('#startButton').disabled"),12000);
  assert(await evalJS("document.querySelector('#total').textContent.includes('1/105')"),
    'album should remain available after offline reload');
  await call('Network.emulateNetworkConditions',{offline:false,latency:0,downloadThroughput:-1,uploadThroughput:-1});
  assert(exceptions.length===0,'Browser exceptions: '+exceptions.join('; '));
  console.log('BROWSER SMOKE OK: real Chrome, 21-room route, start, keyboard, first cowrie, 25-node skills, mobile controls, PWA offline reload; screenshots saved.');
}finally{
  try{ws?.close();}catch{}
  try{chrome?.kill('SIGTERM');}catch{}
  try{server?.kill('SIGTERM');}catch{}
  await rm(userDir,{recursive:true,force:true}).catch(()=>{});
}
