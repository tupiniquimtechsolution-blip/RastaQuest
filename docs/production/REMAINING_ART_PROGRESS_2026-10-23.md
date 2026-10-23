# Remaining art — review packet, 2026-10-23

Status: candidate authoring and optional presentation integration; commercial GREEN is **NO-GO**. Packet creation began on2026-10-22, so that directory is retained. Base main: `7dae0f7d891eddef4be7d8688e5fa15b2330eefb` (PR66). Issues35/36/37/38 remain open; this packet does not inherit earlier appearance approvals.

## Delivered files

Packet: `assets/production_drafts/2026-10-22/remaining-art-v01/`.

| Material | Delivered | Scope |
|---|---|---|
| Castle, Caves, Hub | 3 backgrounds1280x720;48 native32x32 tiles;15 props | Candidate environment kits and review-only room layers |
| Ranged, Charger, Controller, Exploder | 8 body keys each,256x256 | idle1/move2/tell1/attack1/hurt1/death2; initial studies |
| Storm Warden, Rift Sovereign | 12 body keys each,512x512 | Pattern-specific tells/attacks and bounded death |
| Hero portal entry | 4 body keys,256x256; separate rigid axe and combined previews | New source poses/gallery; quiet runtime portal entry unchanged |
| Shared effects | 21 keys across7 families | hit/projectile/area/reward plus chain/area/on-kill electricity; source/gallery only |
| Evidence | 47 actual desktop Godot captures, trace, hashes and verification | Not phone QA, acceptance or commercial exports |

`sources/` preserves19 new ImageGen inputs, including the superseded Hub background and its corrected replacement. `PROMPTS.json` and `SUPPLEMENTAL_PROMPTS.json` retain generation instructions/references. `build_art.py` records explicit crops/reduction, palette selection, thresholding and native reconstruction; no concept sheet was promoted to game assets. The approved hero palette and existing rigid axe master are reused for the new portal candidates. `MANIFEST.json` records dimensions, source/export SHA256, palettes, framing and pattern contracts. `AUTHORING_PROVENANCE.csv` is a pending authoring register, not rights evidence.

Source motion GIFs and key sheets under `reviews/` are compositions, distinct from the actual engine captures in `room-review/`. The input/result paths and prompts are preserved so the work can be reproduced and reviewed.

## Runtime and checks

New optional `hostile_art_presenter.gd` validates complete resources before hiding the fallback polygon. It follows actual HostileAttack phases and emitted tell durations; body release poses end independently of persistent projectiles/areas. The two bosses support optional presentation and a bounded decorative death lifetime, after immediate attack cancellation and one-time defeat progression. Unassigned art keeps immediate cleanup. No shipping scene assigns these candidates.

`remaining_art_fixture.gd` and `remaining_art_layers.gd` are review-only. `remaining_art_integration.gd` exercises9 actual patterns, observed damage, emitted tell duration, Exploder self-destruction, cancellation, one defeat, attack-lease cleanup and portal unlock; also12 actual platform-edge landings and9 camera checkpoints across3 biomes. CI includes this regression with timeout and engine-error guards.

`tools/render_remaining_art_review.gd` captures real Godot4.5.1/OpenGL3.3 on desktop, native1280x720 and reduced640x360. Capture modes explicitly identify held-motion inspections, actual tell/active/death phases and static source galleries. PNG hashes and normalized-LF input hashes are recorded in `RENDER_REPORT.json`. Review framing y-154 is a proposal; production camera is unchanged. Theoretical RGBA export storage is51,372,032bytes; this is not measured peak memory/VRAM/device performance.

`verify_art.py` checks source/export hashes, dimensions, color/alpha constraints, crop bounds, foot alignment, tile joins/distinct corners, rigid-axe pixel preservation, stable reward shard,9 trace cases and47 capture hashes/phase metadata. It never grants human, cultural or licensing approval. Run it after reconstruction, integration trace and capture generation; changed render inputs require recapture. Existing art-integrity and focused combat/portal/Forest regressions are checked separately. CI/merge evidence is recorded on the resulting PR and trackers rather than inferred from local checks.

Local results on2026-10-23: new artifact verifier PASS (56 hostile keys,4 portal keys,21FX,48tiles,15props,47captures); historical PR65 capture verifier PASS (12captures); Forest/Chaser v02 artifact verifier PASS (31captures). Actual remaining-art, hostile-attack, Forest-polish and portal/drop integration scripts all exited0 with their success markers and no engine errors. Desktop recapture exited0 with47captures and empty stderr. These results do not assert a clean local Android export; editor environment/build-tools limitations remain separate, and hosted CI validates its own build.

## Remaining risks and next gates

1. Review the exact new versions for anatomy, hair, palette, silhouette and motion. Move2 and short death clips are initial studies; cadence/root registration and ranged/controller embedded equipment still need cleanup. Charger uses the unchanged34x58 collider despite a low wide silhouette; the overlay exposes this mismatch. Boss collider remains78x112.
2. Improve natural background repetition, decorative placement and native/reduced contrast. Hub material proof is not shipping Hub integration. Obtain actual unlabeled role-recognition responses; no recognition pass rate is invented.
3. Bind reviewed portal poses and shared effects with explicit anchors, cancellation, radius/lifetime and reduced-effects behavior. Current quiet idle fade/slide portal remains active. No source gallery is claimed as a live gameplay effect.
4. Record author/tool/source hashes plus rights/terms evidence and exact-version cultural review. Earlier Rodrigo approvals cover their recorded versions only. Cultural/rights status for this new packet is PENDING.
5. Promote specifically reviewed assets in a dedicated playable visual slice, then build an identifiable APK that actually replaces the placeholders. Review installation, controls, readability, performance and lifecycle on Rodrigo's physical GalaxyA13. No device acceptance or placeholder replacement is claimed here.
6. Finish remaining art polish and visual integration before audio/finishing. Commercial signing, store/distribution, Beta/device evidence and Gold checklist remain separate gates. Passing CI or producing an APK does not make commercial GREEN true.

External material used: built-in ImageGen outputs and repository canonical direction boards only; no new third-party package, vendor art or structural dependency adopted. Existing Python/Pillow reconstruction tooling is reused under Rodrigo's prior authorization.
