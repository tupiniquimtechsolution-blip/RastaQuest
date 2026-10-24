import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {sampleClip,solveRig,canPreviewUnlock,resolveReaction} from './engine.mjs';
const rig=JSON.parse(readFileSync(new URL('./rig.json',import.meta.url)));
const clips=JSON.parse(readFileSync(new URL('./clips.json',import.meta.url)));
test('Every clip keeps rigid bone lengths at endpoints and interpolated poses',()=>{
  for(const c of clips.clips) for(let i=0;i<=40;i++){
    const r=solveRig(rig,sampleClip(c,i/40));
    for(const b of Object.values(r))assert.ok(Math.abs(Math.hypot(b.to[0]-b.from[0],b.to[1]-b.from[1])-b.length)<1e-7);
  }
});
test('Clip time is clamped and named keys interpolate',()=>{
 const c={keys:[{t:0,root:[0,0],angles:{arm:0}},{t:1,root:[10,-20],angles:{arm:90}}]};
 assert.deepEqual(sampleClip(c,-1),sampleClip(c,0));assert.deepEqual(sampleClip(c,2),sampleClip(c,1));
 assert.equal(sampleClip(c,.5).angles.arm,45);assert.deepEqual(sampleClip(c,.5).root,[5,-10]);
});
test('Unavailable predecessors cannot be skipped in skill preview',()=>{
 const node={requires:['tecnicas_2']};assert.equal(canPreviewUnlock(node,new Set()),false);
 assert.equal(canPreviewUnlock(node,new Set(['tecnicas_2'])),true);
});
test('Parry is not universal and does not work outside its demonstration window',()=>{
 assert.equal(resolveReaction({kind:'melee'},'parry','contact').ok,true);
 assert.equal(resolveReaction({kind:'melee'},'parry','windup').ok,false);
 assert.equal(resolveReaction({kind:'area'},'parry','contact').ok,false);
 assert.equal(resolveReaction({kind:'projectile',reflectable:false},'rebate','contact').ok,false);
 assert.equal(resolveReaction({kind:'projectile',reflectable:true},'rebate','contact').ok,true);
 assert.equal(resolveReaction({kind:'charge'},'evade','contact').ok,true);
});
