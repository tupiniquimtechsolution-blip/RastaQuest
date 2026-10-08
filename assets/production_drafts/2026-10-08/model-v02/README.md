# TASK-119 — lateral model iteration v02

Built-in ImageGen rebuilt one neutral right-facing pose from canonical identity references, without cropping miniature frames. Exact prompt: PROMPT.json. Original output preserved; no downscale/palette conversion claimed as authoring.

Visual inspection: profile and silhouette are clearer than v01, one eye visible, fewer small ornaments. Chest/strap still suggests slight torso rotation; blade lobes are not proven symmetric. Gold trim and cloth detail remain denser than the requested simple limited-palette model. Hair/axe dimensions and contact/grip markers still require a measured native redraw. This iteration has not been approved by Rodrigo; earlier acceptance applies to earlier versions only.

Technical gate: 1254x1254, 96,101 visible colors, partial alpha. SHA-256: 2cbf685f21f6efb8044501dad5ee464ecd0ce48214ce8b9cd8ee4fdffcd291b8. The independent gate returns exit 1 for frame_size_mismatch, palette_exceeds_limit and partial_alpha_requires_cleanup. The requested exact128x128 was not fulfilled. TECHNICAL_GATE.json captures the result.

SCALE_REVIEW.html displays the unchanged source at approximate 52px body height on a 1280x720 proof area, plus the approved 28x52 collider guide. It is a browser inspection aid, not a Godot room, reconstructed export, Android QA or final model. Approximate head/sole measurements are visual estimates and explicitly labeled. No asset was promoted to game/assets. Rights remain pending.

Next: manually author/clean a native128x128 model with integer clusters, <=32 colors and alpha0/255; measure body52px, foot y90, axe/hair bounds and palette; validate native/reduced/mobile display before ten clips. Further large generated boards alone cannot complete this gate.
