/* Room loot and art-direction data for the 2D web vertical slice.
   Original fictional item names inspired respectfully by the user's narrative brief.
   None of these are claims about actual religious objects or rites. */
const definitions = [
  ['forest-01','haft','Cabo de Carvalho', 'handling',1],
  ['forest-02','blade','Lâmina da Justiça', 'damage',1],
  ['forest-03','amulet','Folha do Caçador', 'vitality',1],
  ['forest-04','haft','Cabo de Imbuia', 'handling',2],
  ['forest-05','boots','Passos de Ogum', 'mobility',18],
  ['forest-06','amulet','Talismã do Trovão', 'mana',1],
  ['forest-07','blade','Lâmina da Raiz Purificada', 'damage',2],
  ['castle-01','blade','Ferro de Ogum', 'damage',1],
  ['castle-02','boots','Botas do Vento de Iansã', 'mobility',24],
  ['castle-03','blade','Lâmina das Sete Centelhas', 'damage',2],
  ['castle-04','amulet','Guarda Ancestral', 'vitality',2],
  ['castle-05','haft','Cabo de Ferro Temperado', 'handling',3],
  ['castle-06','amulet','Selo da Memória', 'mana',2],
  ['castle-07','blade','Lâmina da Torre Liberta', 'damage',3],
  ['caves-01','boots','Botas dos Ecos', 'mobility',20],
  ['caves-02','haft','Cabo de Pedra Viva', 'handling',4],
  ['caves-03','amulet','Guarda da Nascente', 'vitality',2],
  ['caves-04','blade','Cristal de Trovão', 'damage',3],
  ['caves-05','boots','Passo do Cristal', 'mobility',28],
  ['caves-06','amulet','Amuleto da Água Serena', 'mana',3],
  ['caves-07','blade','Lâmina do Último Eco', 'damage',4],
];
export const EQUIPMENT = Object.freeze(Object.fromEntries(definitions.map(
  ([id,slot,name,stat,value])=>[id,Object.freeze({id,slot,name,stat,value})]
)));
export const SLOTS = Object.freeze(['blade','haft','boots','amulet']);

export function buildChests(room, viewport = 960, groundY = 460) {
  const commonX = Math.min(room.planned_camera_widths * viewport - 500, viewport * 0.92);
  const upperCowrie = room.cowries[3];
  // The rare chest sits on the same reachable one-way high route as the fourth cowrie.
  const rareX = upperCowrie.approx_screen * viewport + 60;
  return [
    { id: room.id+'-common',kind:'common',x:commonX,y:groundY-38,w:46,h:38,opened:false },
    { id: room.id+'-rare',kind:'rare',x:rareX,y:365-38,w:46,h:38,
      equipmentId:room.id,opened:false },
  ];
}
export function equipmentBonus(profile, stat) {
  const slotIds = Object.values(profile?.equipment?.equipped ?? {});
  return slotIds.reduce((sum,id)=> {
    const item = EQUIPMENT[id];
    return sum+(item?.stat===stat ? item.value : 0);
  },0);
}
export function buildRings(room, viewport=960) {
  return [1.7,Math.min(room.planned_camera_widths-1.2,3.7)]
    .map((screen,index)=>({id:room.id+'-ring-'+index,x:screen*viewport,y:280,cooldown:0}));
}
export const BLESSINGS = Object.freeze([
  {id:'forca',title:'Axé do Trovão',effect:'damage',value:1},
  {id:'folego',title:'Fôlego da Jornada',effect:'mana',value:1},
  {id:'vento',title:'Passo do Vento',effect:'mobility',value:20},
]);
export function blessingForNextRoom(roomIndex) {
  return BLESSINGS[roomIndex % BLESSINGS.length];
}
