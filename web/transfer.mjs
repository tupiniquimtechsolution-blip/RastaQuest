import { sanitizeProfile, SAVE_VERSION } from './progression.mjs';
export const TRANSFER_FORMAT = 'rasta-quest-profile-export';
export const MAX_PROFILE_BYTES = 64_000;

/** Explicit opt-in export; never includes a password, email or device token. */
export function serializeTransfer(profile, plan) {
  return JSON.stringify({ format: TRANSFER_FORMAT, version: 1,
    profile: sanitizeProfile(profile, plan) }, null, 2);
}

/** Validates untrusted local files; does not access storage or mutate the game. */
export function parseTransfer(raw, plan) {
  if (typeof raw !== 'string' || raw.length > MAX_PROFILE_BYTES) throw Error('Arquivo inválido ou muito grande.');
  let payload;
  try { payload = JSON.parse(raw); } catch { throw Error('O arquivo não contém JSON válido.'); }
  if (!payload || payload.format !== TRANSFER_FORMAT || payload.version !== 1 ||
      !payload.profile || payload.profile.version !== SAVE_VERSION ||
      !Array.isArray(payload.profile.collectedCowries)) {
    throw Error('Formato de perfil não reconhecido.');
  }
  return sanitizeProfile(payload.profile, plan);
}
