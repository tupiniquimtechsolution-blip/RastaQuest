# Rasta Quest — migração Unity em revisão

Direção autorizada por Rodrigo em 24/10/2026: **Unity + ilustração 2D detalhada com identidade própria**. Editor selecionado: **6000.3.27f1 (6.3 LTS)**. A instalação foi autorizada, incluindo módulo Android, SDK/NDK e Java. Consulte o registro de entrega para o resultado real da instalação e validação; a presença destes fontes não significa que já existe APK Unity testado.

## Escopo deste projeto

Protótipo separado do `game/` Godot. O núcleo C# define ataque em fases, combo, acerto único, defesa, parry, reflexão e pulo duplo. Adaptadores Unity implementam uma sala lateral de três larguras de tela de referência, Chaser/Ranged, plataformas unilaterais elevadas, câmera, portal com escolha explícita de cura e alternância Floresta/Castelo/Cavernas, input por toque/teclado, retrato com barra de vida longa e moldura periférica.

As 274 imagens copiadas são **artes de revisão transitórias**, idênticas às do Godot, com origem/hashes registrados em `Assets/Resources/ReviewArt/IMPORT_MANIFEST.json`. Não são o novo conjunto ilustrado nem ativos comercialmente homologados. O [estudo de direção](../assets/production_drafts/2026-10-24/illustrated-direction-v01/forest-art-target-v01.png) fica fora de Resources: seus personagens pintados não entram no fundo de gameplay.

## Preparar e executar

1. Instalar/ativar Unity 6000.3.27f1 pelo Hub com Android Build Support e seus módulos filhos. Login/licença são do titular; não colocar credenciais no repositório.
2. Na raiz do repositório: `python -B tools/sync_unity_review.py --check`. Se os assets de origem mudarem, executar sem `--check` e revisar o diff.
3. No Hub, abrir esta pasta `unity/`, aguardar a importação de Input System 1.20.1 e uGUI 2.0.0.
4. Usar o menu **Rasta Quest → Preparar sala Unity**, abrir `Assets/Scenes/UnityReview.unity` e pressionar Play.
5. Teclado: A/D ou setas movem; W/seta para cima/espaço pulam; J ataca; K defende; Esc pausa. No toque, analógico esquerdo, gesto para cima e botões circulares à direita. O botão II abre pausa, idioma PT/ES e redução da sombra.

Os controles e as strings desta sala são de revisão. Idioma PT/ES e sombra reduzida ficam salvos localmente; não substituem as configurações, traduções e saves da campanha. Após a derrota há botão de reinício da tentativa, que limpa melhorias e retorna à Floresta. Veja o [roteiro e limites do primeiro teste real](../docs/production/UNITY_PRETEST_HANDOFF_2026-10-28.md).

## Build reproduzível

Executar o editor real com `-batchmode -quit -projectPath <pasta-unity> -executeMethod RastaQuest.Editor.ReviewBuild.Windows -logFile <arquivo>` para Windows, ou `RastaQuest.Editor.ReviewBuild.Android` para Android. Resultados vão para `Builds/`, ignorada pelo Git. O build Android é de desenvolvimento, pacote `com.tupiniquim.rastaquest.unityreview`, versão `1.0.0-unity.1`, código 1000006, ARMv7+ARM64, SDK mínimo 25 (Android 7.1, piso do Unity 6.3)/alvo 36, GLES3, rotação horizontal nos dois sentidos.

O comando de preparação grava cena/configuração; revisar e versionar os arquivos gerados **após executar o editor**. Não versionar Library, Temp, caches, APKs, chaves ou tokens. O editor deverá gerar o lock de pacotes real; um lock não resolvido não é fabricado aqui.

## Fonte e paridade

- [Matriz de paridade Unity ↔ Godot e gates de aceitação](../docs/production/UNITY_PARITY_GATE_2026-10-24.md).
- `python -B tools/check_unity_source_contracts.py`: checks de integridade, referências e configuração em fonte; **não** executa o Editor ou APK.
- Analógico centralizado e IDs de toques liberados após cancelamento são correções em revisão, não validações físicas.

## Verificações e limites

- `tools/sync_unity_review.py --check`: confirma origem e igualdade dos bytes, não qualidade/autorizações artísticas.
- `Tests/RulesTests.cs`: executável C# independente com casos de tempo de ataque, hit único, combo, cancelamento, parry, reflexão, cura e salto. Não depende do Unity e não comprova importação/Play Mode.
- `python -B tools/check_unity_source.py`: repete sincronismo, compilação/execução de todas as regras C# e checagem de whitespace; grava relatório e hashes em `Builds/SourceChecks/` sem declarar runtime testado.
- `RastaQuest.Editor.ReviewBuild.Prepare/Windows/Android`: somente o sucesso do editor real comprova cada etapa.
- Próximos gates: regressão de input/colisão/portal em Play Mode, capturas nativas, APK real, instalação/rotação/desempenho no A13, equipamentos alinhados, todos os arquétipos e chefes, saves/progressão, áudio e narrativa.
- URP 2D, luzes e sombras dinâmicas são a etapa seguinte após a paridade inicial; não estão configurados neste protótipo. O estudo ilustrado exige produção de assets separados e animação nova.

**GREEN comercial: NO-GO.** O APK Godot anterior não foi substituído.

Veja [pesquisa e especificação](../docs/product/COMBAT_ART_REFERENCE_STUDY_2026-10-24.md) e [ADR 0003](../docs/adr/0003-unity-illustrated-direction.md).
