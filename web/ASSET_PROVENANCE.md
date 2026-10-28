# Procedência dos sprites do protótipo web

Os 13 PNGs em `web/assets/` são cópias byte a byte de sprites individuais em `game/visual_review/`. Cada SHA-256 foi conferido com `game/visual_review/catalog.json` da cópia local do PR #84. O acervo está classificado como **visual-review-only**, com `commercial_approved: false`. O uso aqui é provisório e limitado ao protótipo; revisão visual da versão exata, comprovação de direitos/termos e revisão cultural continuam pendentes.

`boss-forest.png` usa o sprite de *controller* como substituto temporário para a sala de chefe da floresta. O desenho próprio do chefe ainda não foi aprovado. Os PNGs de ator têm canvas transparente maior que a figura e são desenhados com recorte no navegador.

As 21 pranchas de salas e as nove camadas de estudo de parallax permanecem fora da renderização do jogo. Chão, plataformas e colisões são definidos no código web; nenhuma prancha foi usada como fundo pronto.

| Arquivo em `web/assets/` | Original no repositório | Fonte registrada no catálogo | SHA-256 |
| --- | --- | --- | --- |
| `player-idle.png` | `game/visual_review/player/idle_01.png` | `assets/production_drafts/2026-10-22/axe-idle-2x/player_idle_01.png` | `0fd06fa6dbdbbbe3fcb8e36143b5b8bf53224817036837041c078e1558b1962e` |
| `player-run.png` | `game/visual_review/player/flow_run_01.png` | `assets/production_drafts/2026-10-23/flow-v03/run_01.png` | `06f2482977b19a7e0d187fa2450ea3a4f35e56d06df534da99ec2e27ac38693c` |
| `player-jump.png` | `game/visual_review/player/jump_01.png` | `assets/production_drafts/2026-10-22/airborne-2x/jump_combined_01.png` | `ecc4c7dea34abcf3e6d2869c2af37102169dccca9c9dd272d42bc2fb38ef4938` |
| `player-attack.png` | `game/visual_review/player/flow_attack_axe_04.png` | `assets/production_drafts/2026-10-23/flow-v03/attack_axe_04.png` | `c0bf4b407bc4f3ed31f34820e304326d095d2f0b1784109986f0625e3f33a000` |
| `enemy-idle.png` | `game/visual_review/chaser/chaser_idle_01.png` | `assets/production_drafts/2026-10-22/forest-chaser-polish/chaser_idle_01.png` | `d715143f737e649a716364f764323ed279fdb632f5d9953ab287a04926090ab6` |
| `enemy-attack.png` | `game/visual_review/chaser/chaser_attack_01.png` | `assets/production_drafts/2026-10-22/forest-chaser-polish/chaser_attack_01.png` | `5ce36a341a3d94900c182a9acaaa69208b3813ddd2ebd6562694a1e535cda4de` |
| `portal.png` | `game/visual_review/portal/idle.png` | `assets/production_drafts/2026-10-22/effects-2x/fx_portal_interaction_02.png` | `a546ed6a7466d015181d8d9a9b9b66e3abf70adcce641b0f03578df0a2547bab` |
| `boss-forest.png` | `game/visual_review/polished/actors/controller/idle_01.png` | `assets/production_drafts/2026-10-23/playable-visual-v01/actors/controller/idle_01.png` | `3fa3a3153a47f17cd0bce02c1f387f740a99cb2d1f73a5c2f47a54e6b3b0c925` |
| `boss-castle.png` | `game/visual_review/remaining/actors/storm_warden/idle_01.png` | `assets/production_drafts/2026-10-22/remaining-art-v01/actors/storm_warden/idle_01.png` | `430bce6cc97aeadb295e25cf2e7ab821d2fb89f912fa48ed253b406bd66d13ce` |
| `boss-caves.png` | `game/visual_review/remaining/actors/rift_sovereign/idle_01.png` | `assets/production_drafts/2026-10-22/remaining-art-v01/actors/rift_sovereign/idle_01.png` | `0fe44f48bcccf47cbcb21f765655332e9acd8a56c90d854d15909396898f7f7e` |
| `terrain-forest.png` | `game/visual_review/environments/forest/terrain_top_1.png` | `assets/production_drafts/2026-10-22/forest-chaser-polish/terrain_top_1.png` | `d4110eabef5059557e9154696b21a0da7ef0cca540aa75db229688e19f5b505b` |
| `terrain-castle.png` | `game/visual_review/environments/castle/terrain_top_1.png` | `assets/production_drafts/2026-10-22/remaining-art-v01/environments/castle/terrain_top_1.png` | `eee436755b5a48464fdfb55cc5800d52ed27857b5e71b133a72b1d18d22db184` |
| `terrain-caves.png` | `game/visual_review/environments/caves/terrain_top_1.png` | `assets/production_drafts/2026-10-22/remaining-art-v01/environments/caves/terrain_top_1.png` | `c3a7f80b33e14058d19a93d39392e1ed5d90b7f690b8f4cc77357fcea6841b5d` |

Total: 13 PNGs, 187978 bytes.
