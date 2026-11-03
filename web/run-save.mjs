import { snapshotRun } from './engine.mjs';
export const RUN_SAVE_KEY = 'rasta-quest:web-run:v1';
export function loadRun(storage) {
  try { const raw = storage?.getItem(RUN_SAVE_KEY); return raw ? JSON.parse(raw) : null; }
  catch { return null; }
}
export function saveRun(storage, state) {
  const snapshot = snapshotRun(state);
  if (!snapshot) return clearRun(storage);
  try { storage?.setItem(RUN_SAVE_KEY, JSON.stringify(snapshot)); return Boolean(storage); }
  catch { return false; }
}
export function clearRun(storage) {
  try { storage?.removeItem(RUN_SAVE_KEY); return true; }
  catch { return false; }
}
