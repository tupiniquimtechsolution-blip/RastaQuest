# Pacote A — Engenharia e regressões antes do Editor Unity

**Data:** 2026-10-24. **Estado:** revisão de fonte; compilação Unity/Play Mode/Android não executadas. **Escopo:** PR derivado do rascunho #82.

## Interface entre regras e motor

- `CombatRules` é a autoridade de `AttackPhase`, janela de parry, saúde, restituição e unicidade de acerto. Adaptadores Unity não podem ditar dano a partir de eventos de animação.
- `JumpRules` concentra coyote-time, buffer e dois saltos; parâmetros de física Unity permanecem na camada adaptadora.
- `SliceInput` representa intenção instantânea; a apresentação/HUD não retém controle físico das ações.
- `SliceBootstrap` orquestra apenas uma sala de revisão; não é `RunManager`, `SaveManager` ou campanha.
- `ReviewArt` e o catálogo de 274 PNGs pertencem exclusivamente ao perfil de revisão.
- Contratos puros continuam sem dependências Unity (`RastaQuest.Core.asmdef` com `noEngineReferences`), e podem ser verificados pelo compilador C# independente no workflow.

## Defeitos evitados e limite do ajuste

As regras agora rejeitam `NaN`, infinitos e valores negativos em entrada de dano/tempo e proíbem saúde máxima inválida. Antes, um número não finito poderia contaminar o estado de saúde; após o ajuste um valor inválido gera uma exceção em vez de se propagar silenciosamente. Isso é uma defesa de contrato: produtores de eventos também devem validar suas entradas e registrar o erro nos fluxos de execução. Não alteramos os valores do balanceamento, dano positivo, salto, janela de parry, cooldown ou curas.

## Verificação independente

O workflow `Unity Source Contracts (not Editor or APK)` compila `CombatRules.cs`, `JumpRules.cs` e `RulesTests.cs` com compilador C# do Windows. Novas asserções cobrem saúde inválida, dano inválido, ciclo inválido, tempo de salto inválido e reinício do dedupe entre ataques. Exceções negativas são intencionais. Um check verde prova apenas essas regras puras; não é evidência de colisão/tempo de frame real.

## Próximas tarefas técnicas dependentes do Editor

1. Converter testes de fonte em testes EditMode/PlayMode no Unity Test Framework, sem substituir a suíte portátil.
2. Executar `RastaQuest.Editor.ReviewBuild.Prepare`; medir sistema de referência de 64 px/unidade, 2D physics and camera.
3. Coletar logs de Console e do executável, capturas, animações e timeline de golpes; reproduzir com FPS baixo/alto.
4. Medir touch, rotação, tamanho seguro e performance no Galaxy A13 antes de fechar #81.

O PR #82 continua rascunho; nem esta revisão nem CI autorizam promoção comercial.
