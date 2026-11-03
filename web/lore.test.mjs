import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {LORE,validLoreIds} from './lore.mjs';
import {makeProfile,recordLore,sanitizeProfile} from './progression.mjs';
import {createGame,step,snapshotRun,restoreRun} from './engine.mjs';
const plan=JSON.parse(readFileSync(new URL('./data/rooms.json',import.meta.url),'utf8'));

test('21 original narrative memories match every canonical planned room',()=>{
  const ids=plan.rooms.map(r=>r.id).sort();
  assert.deepEqual(Object.keys(LORE).sort(),ids);
  for(const entry of Object.values(LORE)) {
    assert.ok(entry.title.length>5);
    assert.ok(entry.body.length>80);
  }
  assert.deepEqual(validLoreIds(['forest-01','forest-01','bogus']),['forest-01']);
});

test('touching an in-world tablet records one permanent memory and survives reload',()=>{
  const p=makeProfile(),g=createGame(plan,p);
  assert.equal(g.tablet.id,'forest-01');
  g.player.x=g.tablet.x-g.player.w/2;
  g.player.y=g.tablet.y-g.player.h/2;
  step(g,{interact:true},1/60);
  assert.equal(g.tablet.discovered,true);
  assert.deepEqual(p.loreIds,['forest-01']);
  assert.equal(g.profileRevision,1);
  const resumed=restoreRun(plan,p,snapshotRun(g));
  assert.equal(resumed.tablet.discovered,true);
  assert.deepEqual(sanitizeProfile(p,plan).loreIds,['forest-01']);
  assert.equal(recordLore(p,'forest-01'),false);
  assert.equal(recordLore(p,'fake-lore'),false);
});
