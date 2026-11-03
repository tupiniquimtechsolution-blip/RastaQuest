import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { SKILL_TREE, SKILL_NODES, sanitizeSkills, canPurchaseSkill, purchaseSkill, skillBonus } from './skills.mjs';
import { makeProfile, sanitizeProfile } from './progression.mjs';
import { createGame, step } from './engine.mjs';
import { createSanctuary, stepSanctuary, SANCTUARY_STATIONS } from './sanctuary.mjs';

const plan=JSON.parse(readFileSync(new URL('./data/rooms.json',import.meta.url),'utf8'));

test('skill tree follows the exact v02 five branches and 25-node structure',()=>{
  assert.equal(SKILL_TREE.title,'Raízes do Trovão');
  assert.equal(SKILL_TREE.branches.length,5);
  assert.equal(Object.keys(SKILL_NODES).length,25);
  for(const branch of SKILL_TREE.branches) {
    assert.equal(branch.nodes.length,5);
    branch.nodes.forEach((n,i)=>{
      assert.equal(n.tier,i+1);
      assert.deepEqual(n.requires,[i===0?'raiz_ancestral':branch.nodes[i-1].id]);
      assert.ok(n.cost>0);
    });
  }
});

test('essence buys nodes in prerequisite order; forged tiers are discarded',()=>{
  const p=makeProfile();
  p.essence=100;
  assert.equal(canPurchaseSkill(p,'vigor_2'),false);
  assert.equal(purchaseSkill(p,'vigor_2'),false);
  assert.equal(purchaseSkill(p,'vigor_1'),true);
  assert.equal(purchaseSkill(p,'vigor_2'),true);
  assert.equal(purchaseSkill(p,'vigor_2'),false);
  assert.equal(skillBonus(p,'vitality'),2);
  assert.deepEqual(sanitizeSkills(['vigor_1','vigor_3','bogus']),['vigor_1']);
  assert.deepEqual(sanitizeProfile({...p,skills:['vigor_4','vigor_1','vigor_2']},plan).skills,['vigor_1','vigor_2']);
  const state=createGame(plan,p);
  assert.equal(state.player.maxHp,5);
});

test('defense skill uses mana instead of hit points while blocking',()=>{
  const p=makeProfile();p.skills=['defesa_1'];
  const state=createGame(plan,p);
  const foe=state.enemies[0];
  foe.cooldown=0;foe.speed=0;
  state.player.x=foe.x-30;state.player.y=foe.y;
  state.player.invuln=0;
  const originalHp=state.player.hp,originalMana=state.player.mana;
  step(state,{block:true},1/60);
  assert.equal(state.player.hp,originalHp);
  assert.equal(state.player.mana,originalMana-1);
});

test('sanctuary is walkable and its stations open lore, equipment, skills and new run',()=>{
  const hub=createSanctuary();
  assert.equal(SANCTUARY_STATIONS.length,5);
  assert.ok(SANCTUARY_STATIONS.at(-1).x > 960*2);
  hub.playerX=420;
  assert.equal(stepSanctuary(hub,{interact:true}),null);
  assert.match(hub.message,/machado não rasga portais/);
  stepSanctuary(hub,{interact:false});
  hub.playerX=940;
  assert.equal(stepSanctuary(hub,{interact:true}),'equipment');
  stepSanctuary(hub,{interact:false});
  hub.playerX=1490;
  assert.equal(stepSanctuary(hub,{interact:true}),'skills');
  stepSanctuary(hub,{interact:false});
  hub.playerX=2820;
  assert.equal(stepSanctuary(hub,{interact:true}),'new_run');
  for(let i=0;i<500;i++)stepSanctuary(hub,{right:true},1/30);
  assert.ok(hub.playerX<=3220-44);
  assert.ok(hub.cameraX<=3220-960);
});
