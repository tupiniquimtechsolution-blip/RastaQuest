import { snapshotRun } from './engine.mjs';

export const RUN_SAVE_KEY='rasta-quest:web-run:v1';
export function readSavedRun(storage) {
  try { const raw=storage?.getItem(RUN_SAVE_KEY); return raw ? JSON.parse(raw) : null; }
  catch { return null; }
}
export function writeSavedRun(storage,state) {
  try {
    const snapshot=snapshotRun(state);
    if (!snapshot || !storage) return false;
    storage.setItem(RUN_SAVE_KEY,JSON.stringify(snapshot));
    return true;
  } catch { return false; }
}
export function eraseSavedRun(storage) {
  try { storage?.removeItem(RUN_SAVE_KEY); return true; }
  catch { return false; }
}
