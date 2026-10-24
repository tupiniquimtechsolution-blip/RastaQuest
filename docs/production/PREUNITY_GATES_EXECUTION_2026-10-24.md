# Rasta Quest — Pré-produção sem Unity: Pacotes A→D

**Data:** 2026-10-24. **Base:** PR #82 (migração Unity em rascunho). **PR de preparação:** #83, base `design/combat-direction-hud-framing`, branch `work/preunity-gates-20261024`. **Situação comercial:** NO-GO.

## A — Engenharia / verificação de regras
Entregue em fonte:
- `unity/Assets/RastaQuest/Core/CombatRules.cs`: maxHealth, dano e ciclo rejeitam NaN/infinito/negativos para impedir corrupção silenciosa.
- `unity/Assets/RastaQuest/Core/JumpRules.cs`: rejeita passos de tempo inválidos.
- `unity/Tests/RulesTests.cs`: regressões do núcleo C# para entradas negativas/não finitas, dano e unicidade de alvos por ataque.
- [Contrato de arquitetura e pendências](PREUNITY_ENGINEERING_2026-10-24.md).

**Não entregue:** Editor, Play Mode, editor scripting compile, Android.

## B — Produção artística e HUD
Entregue em fonte:
- [Contrato JSON ilustrado](../../assets/production_drafts/2026-10-24/unity-illustrated-production/PRODUCTION_CONTRACT.json): personagem, Chaser/Ranged, Floresta/Castelo/Cavernas e HUD mobile, com estado obrigatório PENDING.
- [Packet de produção](UNITY_ILLUSTRATED_PRODUCTION_PACKET_2026-10-24.md).
- `tools/validate_unity_art_contract.py` e testes negativos: inventário, clips, layers, fontes conceituais e barreiras de não aprovação comercial.

**Não entregue:** ilustrações novas, rig, sprites definitivos, tiles de produção, consultas culturais e licença.

## C — Conteúdo / localização / saves
Entregue:
- [Catálogo textual rascunho](content_drafts/unity_content_v01.json): PT-BR/espanhol/inglês, roteiros curtos alinhados ao lore, e 3 escolhas do protótipo ligadas a `.tres` reais.
- [Documento de narrativa/áudio/acessibilidade](UNITY_CONTENT_PACKET_2026-10-24.md).
- [Estratégia de save preservando Godot](UNITY_SAVE_MIGRATION_2026-10-24.md), schema 2/1 MiB; não presume acesso ao sandbox Godot.
- `tools/validate_unity_content_pack.py` e testes de placeholders, recompensas, save schema e ausência de migração automática.

**Não entregue:** engine bindings, gravações, textos aprovados ou persistência Unity.

## D — QA / homologação / publicação
Entregue:
- [Registro PENDING/BLOCKED](../release/acceptance/UNITY_MIGRATION_EVIDENCE_PENDING.json), com 14 gates vinculados a issues e todos sem prova de execução nativa.
- [Runbook reproduzível](../release/acceptance/UNITY_MIGRATION_RUNBOOK_2026-10-24.md).
- `tools/validate_unity_migration_evidence.py` e testes negativos para barrar GO autoatribuído, gates duplicados, PASS sem hash/revisão/evidências.

**Não entregue:** build Unity, APK/AAB, teste físico, 16 KB binário, Gold GO, publicação.

## Critério de continuidade
1. Fonte: CI `Unity Source Contracts` + `Repository Health` (+ Gold Preflight se disparado) no HEAD exato; registrar IDs dos runs no PR.
2. Editor #80: confirmação administrativa, importação/pacotes, logs, Windows e Android build.
3. Smartphone #81: execução da primeira sala, controles com pausa/rotação, física/combat, screenshots nativos e desempenho.
4. Arte #35–38: produzir recursos separados de gameplay, registrar direitos e realizar revisão humana/cultural.
5. Release #50/#29: inspecionar artefato e distribuição; não inferir compatibilidade API36/16 KB de texto-fonte ou de CI Godot.

**Importante:** planejar e validar contratos não substitui criar conteúdo final nem provar execução Unity. Este registro não declara nenhuma issue #80/#81/#35–38/#50 fechada.
