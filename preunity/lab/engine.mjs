export function sampleClip(clip, time) {
  const t = Math.max(0, Math.min(1, Number(time) || 0));
  const keys = clip.keys;
  let a = keys[0], b = keys.at(-1);
  for (let i = 1; i < keys.length; i++) if (t <= keys[i].t) { a = keys[i-1]; b = keys[i]; break; }
  const u = b.t === a.t ? 0 : (t-a.t)/(b.t-a.t);
  const names = new Set([...Object.keys(a.angles), ...Object.keys(b.angles)]);
  return {root: a.root.map((v,i)=>v+(b.root[i]-v)*u), angles: Object.fromEntries([...names].map(k=>[k,(a.angles[k]||0)+((b.angles[k]||0)-(a.angles[k]||0))*u]))};
}
export function solveRig(rig, pose) {
  const result = {};
  for (const bone of rig.bones) {
    const parent = bone.parent ? result[bone.parent] : null;
    if (bone.parent && !parent) throw Error('Bone parent must precede child: '+bone.id);
    const from = parent ? parent.to : [pose.root[0], -130+pose.root[1]];
    const angle = (parent ? parent.angle : 0)+bone.angle+(pose.angles[bone.id]||0);
    const rad=angle*Math.PI/180;
    result[bone.id]={from:[...from],to:[from[0]+Math.cos(rad)*bone.length,from[1]+Math.sin(rad)*bone.length],angle,length:bone.length};
  }
  return result;
}
export function canPreviewUnlock(node, unlocked) { return node.requires.every(id=>id==='raiz_ancestral'||unlocked.has(id)); }
export function resolveReaction(attack, response, phase) {
  if (phase!=='contact') return {ok:false,reason:'Fora da janela de contato desta simulação.'};
  if (attack.kind==='area') return {ok:false,reason:'Área/armadilha: sair do alcance; não aparar.'};
  if (response==='parry' && attack.kind==='melee') return {ok:true,reason:'Defesa precisa contra golpe corpo a corpo.'};
  if (response==='rebate' && attack.kind==='projectile' && attack.reflectable) return {ok:true,reason:'Projétil refletível rebatido.'};
  if (response==='evade' && attack.kind==='charge') return {ok:true,reason:'Recuo fora da pista da investida.'};
  if (response==='shield' && attack.blockable) return {ok:true,reason:'Defesa frontal; custos e duração ainda em estudo.'};
  return {ok:false,reason:'Essa resposta não atende a este ataque.'};
}
