import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, snapshotRun, restoreRun, step, GROUND_Y } from './engine.mjs';
import { makeProfile } from './progression.mjs';
import { readSavedRun, writeSavedRun, eraseSavedRun } from './run-save.mjs';

const plan=JSON.parse(readFileSync(new URL('./data/rooms.json',import.meta.url),'utf8'));
const local=new Map();
const storage={getItem:k=>local.get(k)||null,setItem:(k,v)=>local.set(k,v),removeItem:k=>local.delete(k)};

test('checkpoint run restores collected shells, enemies, chests, lives and position',()=>{
  const profile=makeProfile();
  const g=createGame(plan,profile);
  const c=g.cowries[0];
  g.player.x=c.x-g.player.w/2;g.player.y=c.y-g.player.h/2;
  step(g,{},1/60);
  assert.equal(g.roomCollected,1);
  const enemy=g.enemies[0];enemy.alive=false;enemy.hp=0;
  g.chests[0].opened=true;
  g.checkpoint.activated=true;g.player.lives=5;g.player.hp=2;
  const data=snapshotRun(g);
  const restored=restoreRun(plan,profile,data);
  assert.equal(restored.room.id,'forest-01');
  assert.equal(restored.roomCollected,1);
  assert.equal(restored.totalCollected,1);
  assert.equal(restored.player.lives,5);
  assert.equal(restored.player.hp,2);
  assert.equal(restored.player.x,restored.checkpoint.x);
  assert.equal(restored.enemies[0].alive,false);
  assert.equal(restored.chests[0].opened,true);
  assert.equal(restored.cowries[0].collected,true);
  assert.equal(restored.collectedIds.size,1);
});

test('later room can resume without doubling previous portal blessing',()=>{
  const g=createGame(plan,makeProfile());
  g.enemies.forEach(e=>e.alive=false);
  g.player.x=g.exit.x-10;g.player.y=GROUND_Y-g.player.h;
  step(g,{interact:true},1/60);
  assert.equal(g.roomIndex,1);
  const buff=g.runBuffs.mana;
  const restored=restoreRun(plan,g.profile,snapshotRun(g));
  assert.equal(restored.roomIndex,1);
  assert.equal(restored.runBuffs.mana,buff);
  assert.equal(restored.player.maxMana,g.player.maxMana);
});

test('invalid or forged saved data is bounded to the canonical 21-room plan',()=>{
  const profile=makeProfile();
  const plain=createGame(plan,profile);
  assert.equal(restoreRun(plan,profile,{version:1,roomIndex:999,roomId:'fake'}).roomIndex,0);
  const raw={...snapshotRun(plain),lives:1e9,hp:1e9,mana:-50,
    collectedIds:['fake','forest-01-b1','forest-01-b1'],
    rewardedRooms:['forest-01','bad'],killedEnemies:['bogus'],checkpoint:true,
    runBuffs:{damage:1e9,mana:1e9,mobility:-1}};
  const result=restoreRun(plan,profile,raw);
  assert.equal(result.player.lives,3,'noninteger unsafe lives rejected');
  assert.equal(result.player.hp,result.player.maxHp);
  assert.equal(result.player.mana,0);
  assert.equal(result.collectedIds.size,1);
  assert.equal(result.rewardedRooms.size,0,'cannot fake a 5/5 bonus');
  assert.equal(result.runBuffs.damage,3);
  assert.equal(result.runBuffs.mana,3);
  assert.equal(result.runBuffs.mobility,0);
});

test('storage adapter roundtrips and rejects unavailable storage gracefully',()=>{
  local.clear();
  assert.equal(readSavedRun(storage),null);
  const state=createGame(plan,makeProfile());
  assert.equal(writeSavedRun(storage,state),true);
  assert.equal(readSavedRun(storage).roomId,state.room.id);
  assert.equal(eraseSavedRun(storage),true);
  assert.equal(readSavedRun(storage),null);
  assert.equal(writeSavedRun({setItem(){throw Error('storage full')}},state),false);
  assert.equal(readSavedRun({getItem(){throw Error('denied')}}),null);
});

test('end state is not persisted as active run',()=>{
  const state=createGame(plan,makeProfile());state.status='won';
  assert.equal(snapshotRun(state),null);
  assert.equal(writeSavedRun(storage,state),false);
});
