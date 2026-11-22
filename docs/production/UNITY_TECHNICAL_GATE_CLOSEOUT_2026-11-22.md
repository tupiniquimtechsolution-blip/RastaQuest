# Rasta Quest — fechamento técnico Unity 6.6 (evidências e pendências)
**Checkpoint:** 22/11/2026, America/Sao_Paulo  
**Produto:** Rasta Quest | **Engine/versão:** Unity 6000.6.10f1  
**Branch:** `compat/unity-6000-6-10f1-review-20261121`  
**PR:** [#107](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/107) (**DRAFT, não mesclada**)  
**Base de execução do agente Unity:** `54f4b9e65069a2b2b025bbd3c31bb8762d48c57d`  
**Status global:** **Windows technical PASS reportado; Android físico PENDENTE; comercial NO-GO**.

## 1. Síntese verificável — o que pode ser afirmado

**Verificado diretamente no GitHub nesta auditoria:**
- 274 assets `unity/Assets/Resources/ReviewArt/**/*.png.meta` saneados e versionados na branch, com bloco `TextureImporter` e parâmetros de Sprite/64 PPU;
- gerador `tools/sync_unity_review.py` e modelo `tools/unity_review_texture_importer.yaml` ajustados para metadados reproduzíveis; CI verifica conteúdo sem reescrever arte;
- o commit `54f4b9e` concluiu com sucesso os três workflows *Repository Health*, *Unity Source Contracts (not Editor or APK)* e *Unity Windows Native Gate Script Contracts (no Editor)*. Esses workflows **não executam Unity Editor, Windows player nem APK Android**;
- as configurações da branch definem min API26, target API36 e foco Android em paisagem;
- a PR permanece draft e isolada da main. Não existe autorização de merge/publicação.

**Evidência relatada pelo agente Unity que operou o Windows (arquivos locais e logs não anexados ao GitHub):**
- checkout novo, sem reparação manual, carregou **274 Sprites** e nenhum fallback;
- `Rasta Quest > Preparar sala Unity` e player Windows funcionaram;
- `NativeReviewProbe` a **1280 × 720**, **16 capturas / 0 falhas**, cobrindo: ataque, movimento, salto duplo, parry, plataforma, reflexão de projétil, pausa, recompensa/portal, derrota, botão **Tentar novamente** (clique/toque **sintéticos**), tecla R, reset de vida **5/5** e `Time.timeScale=1`, Chaser/Ranged orientados dos dois lados;
- **sete warnings CS0618** resolvidos na compilação executada;
- gerados ZIP da build Windows, APK Android de desenvolvimento, `NATIVE_REPORT.json` e CSV SHA-256 no computador;
- APK inspecionado: **IL2CPP**, **ARMv7 + ARM64**, min **26** / target **36**, paisagem, assinatura v2 e `zipalign` passam, 5 bibliotecas ARM64 com **16 KB** de alinhamento ELF; `libc++_shared.so` de ARMv7 tem alinhamento ELF de **4 KB**. A revisão do probe usada para construir APK precede ampliação posterior **somente dos testes**, segundo agente; correlacionar hashes na documentação final.

**Limitação obrigatória:** o relatório local e os binários não foram abertos/reexecutados neste chat. Não afirmar que artefatos/hashes foram auditados independentemente. O probe simula toques, não prova gestos humanos em celular.

## 2. Correções editoriais e de segurança realizadas após o probe

A branch substituiu a entrada de menu que havia falhado em 274/274 sprites (`Reparar metadados dos sprites`) por `Rasta Quest > Verificar sprites da revisao (somente leitura)`. O novo comando **não reimporta nem escreve**; confere inventário, GUID e Sprite. `tools/check_unity_source_contracts.py` impede o retorno acidental de `ForceReserializeAssets` e `SaveAndReimport` ao helper. A auditoria e o guia de compatibilidade foram atualizados para distinguir procedimentos históricos dos atuais.

**Status deste ajuste final:** código + CI fonte no GitHub; **nova entrada do menu ainda não validada no Editor real**. Nenhuma reinstalação ou limpeza de `Library` é necessária para realizar essa verificação. Não executar mais o menu de reparo obsoleto.

## 3. Matriz de aceite por etapa

| Gate | Estado | Próxima evidência |
| --- | --- | --- |
| U0 — instalação/importação Editor | **PASS reportado** | `RQ_UNITY_REVIEW_ASSETS_OK`, `RQ_UNITY_PREPARE_OK`; checkout novo |
| U1 — Windows e estabilidade jogável | **PASS no probe reportado** | 16 capturas, zero falhas; teste humano adicional para UX não substituído |
| U2 — .meta/gerador determinístico | **CONCLUÍDO TECNICAMENTE** | GitHub versionado; teste checkout novo reportado |
| U3a — build Windows/QA sintético | **PASS reportado** | relatório e ZIP com hash ainda somente no PC |
| U3b — APK desenvolvimento | **GERADO/INSPECIONADO** | hash APK/identificador do código fonte e relatório sanitizado |
| U3c — QA Android físico | **PENDENTE** | [Issue #81](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81); dispositivo/autorização |
| U4 — Floresta 01 longa de produção | **A FAZER** | 5–8 telas laterais, 5 búzios, checkpoint, inimigos, portal |
| Release completo / Gold | **NO-GO** | 21 salas, 105 búzios, 3 chefes, licenças, cultura, saves, QA real e aprovação |

**Issue [#80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80):** fechada como **concluída no escopo Windows Editor/import/build** com ressalva dos arquivos locais. **Issue [#81](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81):** aberta, roteiro Android atualizado a min API26/Unity 6.6.

## 4. Plano remanescente mínimo, sem retrabalho

**R1 — Editorial (já executado nesta branch):** desativar fluxo quebrado de reparação de Sprites no Editor, obrigar checker somente leitura e atualizar documentação.

**R2 — Preservar artefatos (executável no PC):** entregar **relatório SANITIZADO** `NATIVE_GATE_REPORT.json`, `NATIVE_REPORT.json`, lista 16 capturas e hashes **SHA-256** de ZIP Windows/APK/versão Git. Não versionar `Library`, `Builds`, APK/ZIP binários, backups pessoais, nem caminhos de usuário. Somente relatório resumido e URLs/IDs se autorizados.

**R3 — Verificar menu read-only (Editor local):** sincronizar branch da PR #107, abrir o projeto na Unity 6000.6.10f1, esperar compilação, acionar somente `Rasta Quest > Verificar sprites da revisao (somente leitura)`, esperar `RQ_UNITY_REVIEW_META_CHECK_OK total=274 importedSprites=274 guids=274 readOnly=true`. Confirmar hashes dos `.png.meta` inalterados. Se falhar, trazer primeira exceção.

**R4 — Físico Android (depende de dispositivo):** confirmar no APK `com.tupiniquim.rastaquest.unityreview`, assinatura de desenvolvimento e hash, depois instalar no Galaxy A13 sem remover app Godot nem apagar saves; validar toque de 2+ dedos, botão *Tentar novamente*, orientação esquerda/direita e safe area, pausa/retomada, bloqueio/desbloqueio, FPS e estabilidade, registrar ambiente/primeiro erro. Alinhamento ELF 16 KB estático não equivale a teste efetivo em dispositivo de páginas 16 KB.

**R5 — Após U3:** vertical slice Floresta 01 horizontal extensa, separada da cena técnica de três biomas. Não confundir protótipo web/Godot, arte de revisão e 21 salas prontas.

## 5. Fontes e governança

- [PR Unity #107](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/107)
- [Audit/roadmap histórico com checkpoint atualizado](https://github.com/tupiniquimtechsolution-blip/RastaQuest/blob/compat/unity-6000-6-10f1-review-20261121/docs/production/UNITY_AUDITORIA_E_PLANO_DE_CORRECAO_2026-11-22.md)
- [Guia atualizado de compatibilidade Unity 6.6](https://github.com/tupiniquimtechsolution-blip/RastaQuest/blob/compat/unity-6000-6-10f1-review-20261121/docs/production/UNITY_6000_6_10F1_COMPATIBILITY_2026-11-21.md)
- [Issue #80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80) / [Issue #81](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81)
- [Agenor / Notion — checkpoint](https://app.notion.com/p/420189310488812d809be2952a01923b) · [Miro](https://miro.com/app/board/uXjVHl4fqwQ=/).

**Princípio:** `CI estático` ≠ `Player Windows executado` ≠ `toque humano Android` ≠ `GO comercial`. Decisões e status devem sempre indicar a camada de evidência.
