# Visual jogável v01

Quatro inimigos com64 novas poses e dois equipamentos rígidos. Veja `reviews/*_walk.gif` e `reviews/*_keys.png`; os GIFs mostram fontes nativas, não capturas de gameplay.

`room-review/` contém52 capturas reais do recorte jogável, inclusive Hub, biomas, portal, acertos/eletricidade/abate e nove padrões hostis. `RENDER_REPORT.json` vincula PNGs e código/recursos por hash. Não é QA físico Android.

- Fontes preservadas: `sources/` (dez imagens, incluindo estudos substituídos).
- Prompts: `PROMPTS.json` e `CORRECTION_PROMPTS.json`, ferramenta integrada ImageGen.
- Reconstrução: `build_polish.py`, com redução BOX, paleta comum32, alpha>=200 e pegas por chave.
- Integridade: `MANIFEST.json`, `verify_polish.py`, `VERIFICATION.json`.
- Procedência: `AUTHORING_PROVENANCE.csv`; direitos/cultura/aprovação final pendentes.

O catálogo de242 recursos é montado por `tools/build_visual_review_pack.py` em `game/visual_review/`, exclusivo do perfil Android Visual Review. Não há promoção ao perfil comercial nesta etapa. Use o relatório [integração visual jogável](../../../../docs/production/PLAYABLE_VISUAL_INTEGRATION_2026-10-23.md) para arquivos, verificações, riscos e gates.
