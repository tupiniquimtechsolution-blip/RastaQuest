import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createGame, step, GROUND_Y } from './engine.mjs';
import { makeProfile } from './progression.mjs';

const plan=JSON.parse(readFileSync(new URL('./data/rooms.json',import.meta.url),'utf8'));
const middle=obj=>obj.x+(obj.w??0)/2;

function control(state) {
  const p=state.player,center=middle(p);
  const cowrie=state.cowries.find(c=>!c.collected);
  const enemy=state.enemies.filter(e=>e.alive).sort((a,b)=>a.x-b.x)[0];
  const target=cowrie??enemy??state.exit;
  const tx=middle(target),delta=tx-center;
  const input={left:false,right:false,jump:false,attack:false,special:false,interact:false};
  if(delta>13)input.right=true;
  if(delta< -13)input.left=true;

  // Auto-attack nearby foes while traversing; all actions are via step(), no teleport.
  const threat=state.enemies.find(e=>e.alive && Math.abs(middle(e)-center)<145 &&
    Math.abs((p.y+p.h)-(e.y+e.h))<85);
  if(threat) {
    const gap=middle(threat)-center;
    // Hold a safe axe reach rather than walking into the enemy on every frame.
    // A one-frame approach turns Akane when a threat has crossed behind him.
    const approach=Math.abs(gap)>102 || (Math.sign(gap)!==p.facing && Math.abs(gap)>5);
    input.left=approach && gap<0;input.right=approach && gap>0;
    input.special=p.mana>0 && Math.abs(gap)<139;
    input.attack=true;
  }

  // Step up when nearing low collisions, or jump onto the high cowrie platforms.
  const obstacle=state.platforms.find(s=>s.kind==='block' &&
    ((input.right && s.x-(p.x+p.w)>=0 && s.x-(p.x+p.w)<105) ||
     (input.left && p.x-(s.x+s.w)>=0 && p.x-(s.x+s.w)<105)) &&
    s.y-(p.y+p.h)<=0);
  const upper=cowrie?.upper && Math.abs(delta)<140;
  if(p.grounded && (upper||obstacle))input.jump=true;
  if(upper && !p.grounded){
    input.right=delta>12;input.left=delta< -12;
  }
  if(!cowrie && !enemy && Math.abs(delta)<100)input.interact=true;
  return input;
}

test('whole 21-room campaign can be traversed using only player input and combat', {timeout:120000},()=>{
  const game=createGame(plan,makeProfile());
  const start=Date.now();
  let count=0,lastRoom=0,stuck=0,lastX=game.player.x;
  for(;count<160000 && game.status==='playing';count++){
    const input=control(game);
    step(game,input,1/60);
    if(game.roomIndex!==lastRoom){lastRoom=game.roomIndex;stuck=0;lastX=game.player.x;}
    if(count%120===0){
      if(Math.abs(game.player.x-lastX)<10)stuck++;
      else stuck=0;
      lastX=game.player.x;
      if(stuck>=9)break;
    }
  }
  const dbg={status:game.status,room:game.room.id,roomIndex:game.roomIndex,
    x:Math.round(game.player.x),y:Math.round(game.player.y),
    collected:game.roomCollected,total:game.totalCollected,lives:game.player.lives,
    enemies:game.enemies.filter(e=>e.alive).map(e=>e.id),steps:count,stuck,seconds:(Date.now()-start)/1000};
  assert.equal(game.status,'won','Input-only campaign failed: '+JSON.stringify(dbg));
  assert.equal(game.totalCollected,105,'Input-only campaign missed shells: '+JSON.stringify(dbg));
});
