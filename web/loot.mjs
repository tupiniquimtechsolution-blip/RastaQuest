/**
 * Provisional, original fantasy equipment. The names and cultural references
 * require cultural and art review before final publication.
 */
export const EQUIPMENT = Object.freeze({
  'oak-haft': { name: 'Cabo de Carvalho Consagrado', slot: 'haft', note: 'Manejo do machado' },
  'ogum-metal': { name: 'Metal da Lança de Ogum', slot: 'blade', note: 'Reforça o dano do machado' },
  'iansa-boots': { name: 'Botas do Vento de Iansã', slot: 'boots', note: 'Aumenta a mobilidade' },
});
export const EQUIPMENT_IDS = Object.freeze(Object.keys(EQUIPMENT));
export const RARE_CHESTS = Object.freeze({
  'forest-02': 'oak-haft',
  'castle-05': 'ogum-metal',
  'caves-04': 'iansa-boots',
});

export function chestsForRoom(room, viewWidth, groundY) {
  if (!room || !Number.isFinite(viewWidth) || !Number.isFinite(groundY)) return [];
  const common = {
    id: room.id + '-common',
    kind: 'common',
    reward: room.room_number % 2 ? 'health' : 'mana',
    x: Math.round(viewWidth * 1.15),
    y: groundY - 23,
    opened: false,
  };
  const rareId = RARE_CHESTS[room.id];
  if (!rareId) return [common];
  const upper = room.cowries?.[1]?.approx_screen ?? 2;
  return [common, {
    id: room.id + '-rare',
    kind: 'rare',
    reward: rareId,
    x: Math.round(upper * viewWidth),
    y: groundY - 141,
    opened: false,
  }];
}

export function sanitizeEquipment(items, equipped) {
  const safeItems = [...new Set(Array.isArray(items) ? items.filter(id =>
    typeof id === 'string' && Object.hasOwn(EQUIPMENT, id)) : [])].sort();
  const safeEquipped = { haft: null, blade: null, boots: null };
  for (const slot of Object.keys(safeEquipped)) {
    const id = equipped?.[slot];
    if (typeof id === 'string' && safeItems.includes(id) && EQUIPMENT[id].slot === slot) {
      safeEquipped[slot] = id;
    }
  }
  return { items: safeItems, equipped: safeEquipped };
}

export function discoverEquipment(profile, id) {
  if (!Object.hasOwn(EQUIPMENT, id) || profile.items.includes(id)) return false;
  profile.items.push(id);
  profile.items.sort();
  const slot = EQUIPMENT[id].slot;
  if (!profile.equipped[slot]) profile.equipped[slot] = id;
  return true;
}

export function equipEquipment(profile, id) {
  if (!profile.items.includes(id) || !Object.hasOwn(EQUIPMENT, id)) return false;
  profile.equipped[EQUIPMENT[id].slot] = id;
  return true;
}

export function equipmentStat(profile, slot) {
  const id = profile?.equipped?.[slot];
  return typeof id === 'string' && profile.items?.includes(id) && EQUIPMENT[id]?.slot === slot ? id : null;
}
