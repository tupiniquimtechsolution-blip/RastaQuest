import test from 'node:test';
import { inflateSync } from 'node:zlib';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const here = fileURLToPath(new URL('.', import.meta.url));
const read = path => readFileSync(here + path, 'utf8');
test('manifest supports standalone landscape web preview', () => {
  const manifest = JSON.parse(read('manifest.webmanifest'));
  assert.equal(manifest.short_name, 'Rasta Quest');
  assert.equal(manifest.orientation, 'landscape');
  assert.equal(manifest.display, 'standalone');
  assert.ok(manifest.icons.some(icon => icon.src === './app-icon.svg'));
});
test('HTML declares manifest and web UI remains a game canvas', () => {
  assert.match(read('index.html'), /rel="manifest"/);
  assert.match(read('index.html'), /id="game"/);
  assert.match(read('index.html'), /id="pauseDialog"/);
});
test('offline shell includes runtime and room data', () => {
  const worker = read('sw.js');
  for (const path of ['engine.mjs','progression.mjs','skills.mjs','sanctuary.mjs','run-save.mjs','content.mjs','renderer.mjs','data/rooms.json','index.html','player-idle','boss-forest']) {
    assert.ok(worker.includes(path), path);
  }
});


test('install icons are real PNGs with correct advertised pixel dimensions', () => {
  const manifest=JSON.parse(read('manifest.webmanifest'));
  for(const size of [192,512]) {
    const icon=manifest.icons.find(i=>i.src===`./icon-${size}.png`);
    assert.ok(icon && icon.type==='image/png');
    const bytes=readFileSync(here+`icon-${size}.png`);
    assert.equal(bytes.subarray(0,8).toString('hex'),'89504e470d0a1a0a');
    assert.equal(bytes.readUInt32BE(16),size);
    assert.equal(bytes.readUInt32BE(20),size);
  }
});


test('raster icon PNG chunks have valid CRC and decodable 2-bit palette pixels', () => {
  const crc=bytes=>{
    let c=0xffffffff;
    for(const b of bytes){c^=b;for(let j=0;j<8;j++)c=(c&1)?(c>>>1)^0xedb88320:(c>>>1);}
    return(c^0xffffffff)>>>0;
  };
  for(const size of [192,512]) {
    const png=readFileSync(here+`icon-${size}.png`);
    let at=8, idat=[],plte=false;
    while(at<png.length) {
      const count=png.readUInt32BE(at),tag=png.toString('ascii',at+4,at+8);
      const data=png.subarray(at+8,at+8+count);
      assert.equal(crc(png.subarray(at+4,at+8+count)),png.readUInt32BE(at+8+count),tag+' CRC');
      if(tag==='PLTE')plte=true;
      if(tag==='IDAT')idat.push(data);
      at+=count+12;
      if(tag==='IEND')break;
    }
    assert.ok(plte,'indexed PNG has a palette');
    assert.equal(at,png.length);
    const pixels=inflateSync(Buffer.concat(idat));
    assert.equal(pixels.length,(1+size/4)*size);
    assert.ok(pixels.some(x=>x!==0),'image is not empty');
  }
});
