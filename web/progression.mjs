/** Rasta Quest web progression v1. Local-only, independent of run state. */
import { sanitizeEquipment } from './loot.mjs';
export const SAVE_KEY = 'rasta-quest:web-profile:v1';
export const SAVE_VERSION = 1;
export const UPGRADE_TYPES = Object.freeze(['vitality', 'strength', 'mobility']);
export const UPGRADE_MAX = 5;
export const SKIN_REWARDS = Object.freeze(['akane-ancestral', 'axe-thunder']);

export function makeProfile() {
  return { version: SAVE_VERSION, collectedCowries: [], essence: 0,
    upgrades: { vitality: 0, strength: 0, mobility: 0 }, skins: [],
    items: [], equipped: { haft: null, blade: null, boots: null } };
}

export function allCowrieIds(plan) {
  return new Set(plan.rooms.flatMap(room => room.cowries.map(shell => shell.id)));
}

export function sanitizeProfile(candidate, plan) {
  const clean = makeProfile();
  if (!candidate || typeof candidate !== 'object' || candidate.version !== SAVE_VERSION) return clean;
  const allowed = allCowrieIds(plan);
  if (Array.isArray(candidate.collectedCowries)) {
    clean.collectedCowries = [...new Set(candidate.collectedCowries.filter(id => typeof id === 'string' && allowed.has(id)))].sort();
  }
  if (Number.isSafeInteger(candidate.essence) && candidate.essence >= 0) {
    clean.essence = Math.min(candidate.essence, 1_000_000);
  }
  for (const key of UPGRADE_TYPES) {
    const value = candidate.upgrades?.[key];
    if (Number.isInteger(value) && value >= 0 && value <= UPGRADE_MAX) clean.upgrades[key] = value;
  }
  const gear = sanitizeEquipment(candidate.items, candidate.equipped);
  clean.items = gear.items;
  clean.equipped = gear.equipped;
  // Unlocks are recomputed, never accepted from forged saved flags.
  if (clean.collectedCowries.length === allowed.size && allowed.size === 105) {
    clean.skins = [...SKIN_REWARDS];
  }
  return clean;
}

export function loadProfile(storage, plan) {
  try { return sanitizeProfile(JSON.parse(storage.getItem(SAVE_KEY)), plan); }
  catch { return makeProfile(); }
}

export function saveProfile(storage, profile) {
  try { storage.setItem(SAVE_KEY, JSON.stringify(profile)); return true; }
  catch { return false; }
}

export function recordCowrie(profile, id, plan) {
  if (!allCowrieIds(plan).has(id) || profile.collectedCowries.includes(id)) return false;
  profile.collectedCowries.push(id);
  profile.collectedCowries.sort();
  if (profile.collectedCowries.length === 105) profile.skins = [...SKIN_REWARDS];
  return true;
}

export function awardEssence(profile, amount) {
  if (!Number.isSafeInteger(amount) || amount <= 0) return false;
  profile.essence = Math.min(1_000_000, profile.essence + amount);
  return true;
}

export function upgradeCost(profile, type) {
  if (!UPGRADE_TYPES.includes(type)) return null;
  const level = profile.upgrades[type];
  return level >= UPGRADE_MAX ? null : 15 + level * 15;
}

export function purchaseUpgrade(profile, type) {
  const cost = upgradeCost(profile, type);
  if (cost === null || profile.essence < cost) return false;
  profile.essence -= cost;
  profile.upgrades[type] += 1;
  return true;
}
