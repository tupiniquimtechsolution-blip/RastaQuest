# Independent electricity and portal effect studies

Seven newly generated effect keys: lightning_proc3×60ms =180ms; portal interaction rim4×90ms =360ms. Sources/prompts, individual256×256 PNGs, atlases, GIFs and native contact sheet are included. Source sheets are high-resolution ImageGen output with partial alpha/hidden RGB, not native exports. Build uses a common uniform scale per sheet, BOX reduction, an explicitly selected8-color FX palette, binary alpha and zero hidden RGB. Native clean-up/shape continuity and final art acceptance are not claimed.

These effects are separate scene layers at0.5 render scale, origin128,128. Body/weapon keeps its32-color prototype palette; FX uses8 blue/cyan colors. A composed scene may use40 colors. This does not change or silently claim a32-color combined actor/effect export. The portal rim roughly matches the existing84-world-unit visual height; no34-radius trigger, player collider or portal position changes.

`verify_effects.py` checks actual source/export hashes, frame size, shared FX palette, binary transparency, distinct keys, durations, bounds and an empty central20×40 opening in each rim frame. It does not establish identical ellipses, flash comfort or mobile readability. GIFs add700ms at the end for review only, outside the game timeline. Sources/exports remain outside game/assets.

The rim is named **portal_interaction** deliberately: it is NOT the protagonist's required portal_enter body clip or proof of an integrated portal transition. Current code still enters immediately. Pending hooks must lock input/combat, preserve encounter/reward/death precedence, use a bounded gameplay timer and respect reduced_flashes. Electricity is still the existing combat signal; these pixels are not wired to it. Effects must never cause damage or alter collision windows.

Next: visual density/contrast comparison with the protagonist and Chaser in a real room; reduced-flash variant/behavior; body portal poses and bounded interaction hook; rigged dropped axe on death; culture/provenance/rights records; final export promotion and physical QA. Commercial GREEN remains pending.
