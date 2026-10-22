# Visual density decision — Rodrigo, 2026-10-22

Question: “Para preservar o detalhe do modelo que você gostou, posso produzir os sprites com o dobro da resolução (quadro256×256, corpo de104pixels) e exibi-los com o mesmo tamanho atual no jogo? Isso mantém colisões e escala, mas altera a regra anterior de resolução.”

Answer: “Sim, detalhe2× no mesmo tamanho de jogo”. Source: direct user reply in the current execution conversation. No expert, license or final visual acceptance is implied.

| Property | Previous source | Authorized source | World behavior |
|---|---:|---:|---|
| Frame |128×128|256×256|128×128 extent at0.5 render scale|
| Origin |64,64|128,128|center remains0,0|
| Grounded feet |y90|y180|local y26|
| Body height |52|104|52 units|
| Body width, without hair/axe |≤32|≤64|≤32 units|
| Handle |48|96|48 units|
| Axe head |32×18|64×36|32×18 units|
| Hair envelope |18×20|36×40|18×20 units|

Collider28×52, hitbox56×42 at x38, damage scheduling, speed, camera and touch scale stay unchanged. Ground tiles remain32 world units; no terrain-source change is inferred from the character decision. Keep nearest-neighbor sampling; use a single constant actor visual scale, never change individual frame sizes to hide inconsistent poses. Actual mobile readability remains a gate, especially when half a source pixel becomes a fraction of a display pixel.

The32-color/binary-alpha requirement remains. Extra resolution is a detail budget, not permission to add ornaments, modify identity, license references, or claim clips delivered. Reviewed owner-rejected native-python-v01 remains rejected. The three illustrator images in PR47 remain high-resolution studies, not runtime exports.

Execution order: produce and inspect neutral actor/rigid axe → lock model/palette → author all clips → integrate state/lifetime behavior → Forest/Chaser proof → enemy/biome/boss/effect completion → human visual/device review. Finishing/audio follows visual completion as requested. Do not mark this whole sequence complete based on a generated preview or green code tests.
