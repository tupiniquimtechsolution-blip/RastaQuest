# Run prototype progress — issue35

Six newly generated lower-body poses were combined with the previous identity-stable torso/head/arm layers. Exports use a single source scale,32-color binary-alpha working palette and constant256px frame/0.5 intended rendering. This is a layered authoring prototype, not six independently drawn full-body poses or accepted final motion.

Source hip framing is corrected by translation only; planted foot edges are y180, airborne edges y175. Native1–2px contact corrections are recorded. A real blade/body overlap with the inclined idle weapon was detected and resolved by selecting the exact90degree rigid weapon for all run frames; no weapon resizing or new blade drawing. Shared grip and zero blade/body alpha overlap pass.

The prototype has six60ms timeline keys (360ms cycle), initially matched to source run speed260world units/s and estimated46unit contact stride. Actual foot slip, near/far leg continuity, torso/hip seam, movement-speed adaptation and phone motion acceptance are unverified. The common presenter remains unchanged and no production SpriteFrames is assigned.

Files: assets/production_drafts/2026-10-22/run-2x/ (source/prompt, declared build method, torso/arm/leg/weapon layers, frames/atlas, manifest/report and GIF/contact sheet). Saved-file hashes, frame/palette/alpha, six distinct leg exports, contact records, rigid weapon/layer composition and grip/blade checks pass. No runtime/export/schema/version changes or new Android build.

Prototypes now exist for idle/run/jump/fall; none is final accepted. Body attacks, hurt/death and effects/portal remain. Visual cleanup/room proof, Forest/Chaser and other environments/enemies/bosses still precede finishing/audio. Rights/final culture/device/commercial gates remain open.
