# Rasta Quest — Unity 6000.6.10f1: ensaio de compatibilidade, não migração homologada

**Data:** 21/11/2026. **Motivo:** o proprietário informou que o PC Windows está instalando o Editor Unity 6000.6.10f1 (grafia oficial: sem ponto entre "10" e "f1").

## Decisão de risco

- Não cancelar a instalação por causa do projeto anterior: **6000.6.10f1 existe oficialmente** ([notas de lançamento, 19/11/2026](https://unity.com/releases/editor/whats-new/6000.6.10f1)).
- A base Unity do Rasta Quest em [PR #82](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/82) permanece em **6000.3.27f1**. A automação de Windows foi introduzida no [PR #106](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/106).
- **Esta branch** é a cópia isolada para **6000.6.10f1**; o arquivo `unity/ProjectSettings/ProjectVersion.txt` foi ajustado apenas nesta branch. Nenhum `main`/PR #82/#106 foi sobrescrito nem mesclado.
- Manter pacotes Input System `1.20.1` e uGUI `2.0.0` inicialmente. A [lista oficial 6000.6](https://docs.unity.com/en-us/engine/6000.6/manual/packages-list/packages-all/pack-safe/com-unity-inputsystem) reconhece Input System 1.20.1; **somente o Editor real** pode provar resolução dos pacotes, importação, compilação, Play Mode, builds Windows/Android.
- Nunca converter o projeto original de trabalho **no mesmo diretório** pelo Editor mais recente; fazer checkout em pasta separada. Uma vez migrados, arquivos serializados e lockfile podem não reabrir sem alterações na versão anterior.

## Passos para o Windows nesta branch

```powershell
git clone --branch compat/unity-6000-6-10f1-review-20261121 https://github.com/tupiniquimtechsolution-blip/RastaQuest.git RastaQuest-Unity-66
cd RastaQuest-Unity-66
powershell.exe -NoProfile -File .\tools\unity_native_gate_windows.ps1 -CheckOnly
```

Instalar pelo Unity Hub o **6000.6.10f1** e, para Android, **Android Build Support + Android SDK & NDK Tools + OpenJDK** (conforme [Unity 6.6](https://docs.unity.com/en-us/engine/6000.6/manual/platform-specific/android/getting-started/sdksetup/install-dependencies)). Abrir apenas `RastaQuest-Unity-66\unity` no Hub. Aguardar compilação de scripts e resolução de pacotes; caso apareçam erros, salvar o texto da Console, `Editor.log`, versão e lockfile real. NÃO aceitar avisos genéricos como confirmação de compatibilidade sem testar.

Após conferir Play Mode com **Rasta Quest → Preparar sala Unity**, fechar o Editor e executar o gate nativo:

```powershell
powershell.exe -NoProfile -File .\tools\unity_native_gate_windows.ps1 -RunProbe
```

É possível executar primeiro `-SkipAndroid -RunProbe` se os módulos Android ainda não estiverem prontos. O script verifica a versão fixada no projeto e cria `unity/Builds/NativeGate/<UTC>/NATIVE_GATE_REPORT.json`, arquivos de build, logs e, com `-RunProbe`, capturas do executável Windows. Conferir logs e evidências antes de declarar cada gate.

## Verificações e escopo

Os workflows GitHub desta branch **apenas** validam script PowerShell, inventário dos 274 PNGs de revisão, referências e regras C# independentes quando acionadas. Não instalam o Unity e não executam Play Mode ou APK. O smoke Android físico continua pendente na [issue #81](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81); a instalação e builds reais são o gate [#80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80).

**Estado:** compatibilidade Unity 6.6 **A TESTAR**, jogo 2D em evolução, **NO-GO comercial**. Evitar criar `packages-lock.json` artificial, mudar Target API por suposição ou converter a linha `main`.

## Correções do primeiro teste real (21/11/2026)

Ao abrir o projeto no Unity 6000.6.10f1, o titular observou o Package Manager rejeitar `com.unity.modules.textrendering@1.0.0`; depois de remover a entrada localmente, a compilação indicou:

- `SlicePlayer.cs(53,58) CS0619` — Unity 6.6 não aceita `Object.GetInstanceID()`. Não converter `EntityId` para `int` ou usar `GetHashCode()`: a regra de combate C# exige identificação única por inimigo para não acertar duas vezes em um único golpe. O adapter Unity agora atribui `HitTargetId` via `Interlocked.Increment` durante `SliceEnemy.Initialize()`, preservando `CombatRules.ClaimTarget(int)` e os testes C# independentes.
- `SliceBootstrap.cs(26,106) CS0119` — `SliceBootstrap.Sprite(...)` oculta o símbolo do tipo `Sprite` na chamada `Sprite.Create`. A linha usa `UnityEngine.Sprite.Create` explicitamente.
- `unity/Packages/manifest.json` remove a dependência `com.unity.modules.textrendering`, conforme correção de importação confirmada pelo proprietário.

As alterações foram versionadas nesta branch de compatibilidade; não sobrescrever o projeto histórico 6.3. O workflow valida sintaxe/contratos, **não recompila scripts Unity**. Após aplicar a versão corrigida ao checkout local, sair do Safe Mode apenas quando a Console não tiver erros vermelhos. Atualizar os registros de #80/PR #107 com o resultado real.

Referência oficial: [migração de InstanceID para EntityId na Unity 6000.6](https://docs.unity.com/en-us/engine/6000.6/manual/scripting/get-started/instanceid-to-entityid-migration). Os IDs de hit nesta camada são inteiros internos de encontro, não uma conversão dos identificadores Unity.

## Segundo teste real — falha TextureImporter durante Prepare (22/11/2026)

Após abrir um ZIP novo da branch e acionar `Rasta Quest > Preparar sala Unity`, o Unity 6000.6.10f1 reportou `InvalidOperationException: Review asset is not a Sprite: Assets/Resources/ReviewArt/chaser/chaser_attack_01.png` em `ReviewBuild.VerifyReviewSprites:86`. A Console também mostrou centenas de avisos de `TextureImporter object at version 1, below the supported minimum` para `.png.meta`. A verificação já falha **antes** do Play Mode.

Diagnóstico confirmado nos arquivos: `unity/Assets/Resources/ReviewArt/chaser/chaser_attack_01.png.meta` (e outras amostras) continha apenas `fileFormatVersion: 2` e `guid: ...`, sem bloco `TextureImporter:`. Isso não descreve explicitamente o modo `Sprite` e a combinação com Unity 6.6 não foi corrigida por Reimport. A Unity registra a limitação de atualizar versões antigas de `TextureImporter` nessa família: [Unity Issue UUM-151536](https://issuetracker.unity.com/issues/24570/textureimporter-meta-below-the-supported-minimum-version-is-never-upgraded-and-the-warning-suggests-an-action-that-does-not-exist). Como o reporte cobre versão 9 e nosso caso usa metadados incompletos que o Editor vê como versão 1, a relação exata é **hipótese**; não atribuir causalidade inequívoca ao bug externo.

Correção de engenharia adicionada: `unity/Assets/RastaQuest/Editor/ReviewSpriteRepair.cs`, com menu `Rasta Quest > Reparar metadados dos sprites (Unity 6.6)`. O script chama `AssetDatabase.ForceReserializeAssets(paths, ForceReserializeAssetsOptions.ReserializeMetadata)`, preserva os GUIDs, aplica `TextureImporterType.Sprite` / `SpriteImportMode.Single`, salva e reimporta 274 PNGs, e verifica `LoadAssetAtPath<Sprite>`. `ReviewBuild.Prepare` também tenta a reparação automaticamente ao detectar PNGs com metadados sem `TextureImporter:`. Caso o editor não consiga reparar, emite diagnóstico com os primeiros arquivos restantes. Não descartar `.meta` e não excluir `Library`.

Para a cópia local instalada **anterior** a esse commit, sem baixar o ZIP completo novamente: copiar somente `ReviewSpriteRepair.cs` para `unity/Assets/RastaQuest/Editor`; recompilar, usar novo menu de reparação, então `Preparar sala Unity` e Play.

**Validação de runtime:** correção ainda **não executada no PC**; testes de fonte não substituem a evidência nativa. Verificar a ocorrência de `RQ_REVIEW_META_REPAIR_OK total=274` no Console, depois `RQ_UNITY_PREPARE_OK`. 
