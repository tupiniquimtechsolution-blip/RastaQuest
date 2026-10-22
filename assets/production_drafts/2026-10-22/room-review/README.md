# Actual room rendering review

These are actual desktop Godot4.5.1/OpenGL3.3 captures on Intel UHD Graphics with draft textures loaded ONLY through the review/test fixture. Native1280×720 and reduced640×360 use the same world scale; the player/portal/drop pixels are not painted onto a fake screenshot. RENDER_REPORT.json records image dimensions/byte hashes, normalized-LF code hashes and held states. This is not a phone run or owner acceptance.

Diagnostic differences: one-room horizontal camera bounds0..1280; decorative floor fill extended below the camera while the original floor collider/top640 is unchanged; controlled player positions; scene return disconnected solely to inspect the fallen weapon. These changes exist in the renderer, not shipping scene assignments. Portal is an idle-based quiet fade/slide; dropped axe is the same rigid layer and now draws visibly above the backdrop, behind body.

The first render exposed the negative-z dropped-weapon bug, which PR64 corrected and tested. No final art/model/palette/rights/cultural/Gold clearance is granted. Forest/Chaser comparison and framing proposals are separate in ../forest-room-review/.
