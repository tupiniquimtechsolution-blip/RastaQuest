/** Navigable 2D refuge after death. All stations are part of one lateral hub. */
export const SANCTUARY_WIDTH=3220;
export const SANCTUARY_STATIONS=Object.freeze([
  {id:'elder',x:420,name:'Salão dos Ancestrais',action:'lore',
    lore:'A sabedoria do caminho está em reconhecer a própria história, Akane. O machado não rasga portais; os marcos ancestrais guardam as passagens.'},
  {id:'forge',x:940,name:'Forja Ancestral',action:'equipment'},
  {id:'tree',x:1490,name:'Raízes do Trovão',action:'skills'},
  {id:'source',x:2070,name:'Fonte da Vida e Mana',action:'equipment'},
  {id:'portal',x:2820,name:'Portão de Retorno',action:'new_run'},
]);
export function createSanctuary() {
  return {playerX:96,groundY:460,cameraX:0,message:'Bem-vindo ao Santuário Ancestral. Explore e pressione E nas estações.',
    interactHeld:false};
}
export function stepSanctuary(hub,input={},dt=1/60) {
  const delta=Math.max(0,Math.min(dt,1/30));
  const direction=Number(Boolean(input.right))-Number(Boolean(input.left));
  hub.playerX=Math.max(44,Math.min(SANCTUARY_WIDTH-44,hub.playerX+direction*300*delta));
  hub.cameraX=Math.max(0,Math.min(SANCTUARY_WIDTH-960,hub.playerX-960*.4));
  let action=null;
  if(input.interact && !hub.interactHeld) {
    const near=SANCTUARY_STATIONS.find(s=>Math.abs(hub.playerX-s.x)<100);
    if(near) {
      if(near.action==='lore')hub.message=near.lore;
      else {hub.message=near.name;action=near.action;}
    } else hub.message='Caminhe até uma estação e pressione E.';
  }
  hub.interactHeld=Boolean(input.interact);
  return action;
}
