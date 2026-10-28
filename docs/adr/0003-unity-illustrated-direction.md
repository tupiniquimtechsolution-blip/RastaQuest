# ADR 0003 — Unity e ilustração 2D detalhada

Data: 2026-10-24. Estado: direção autorizada; migração em preparação.

Rodrigo escolheu explicitamente «Ilustração 2D detalhada, próxima de Tails of Iron, com identidade própria» e pediu «utilize unity para melhorias, gráficos, movimentações e polimentos». Essas decisões substituem o alvo artístico pixel art e autorizam uma nova implementação em Unity. O APK atualmente entregue continua sendo Godot 4.5.1; não existe conversão automática de GDScript, cenas, física ou saves.

## Decisão

- Preparar Unity 6.3 LTS, editor fixado em 6000.3.27f1, em `unity/`, separado de `game/`.
- Primeira etapa: sala lateral com movimento, pulo duplo, defesa ao redor do corpo, parry, Chaser/projétil, portal, HUD com retrato e barra longa e moldura periférica. Reutilizar artes de revisão apenas como transição, com procedência e hashes.
- Novo alvo: ilustração 2D com contorno expressivo, texturas pintadas, camadas de profundidade, luz focal e sombras de borda. O estudo gerado não é cenário separável, sprite animado, aceitação visual final ou evidência de desempenho.
- Manter identidade do protagonista, machado duplo, eletricidade controlada, portais, Android e perspectiva lateral. Tails of Iron e Sons of Sparta são referências de princípios; o conteúdo continua próprio.
- Núcleo C# independente do motor para testar tempos e regras; componentes Unity integram física, input, animação e UI. Os testes do núcleo não comprovam compilação, renderização nem build Unity.
- Salas, progressão, saves, chefes, áudio, acessibilidade, idiomas e publicação precisam de uma matriz explícita de paridade antes da troca de aplicativo.

## Limites e gates

Não havia Unity nos diretórios padrão, processos ou registros examinados. Rodrigo autorizou instalar Hub, editor e Android. Unity Hub 3.22.4 foi instalado; a instalação do editor retornou «The Windows elevation prompt was cancelled or timed out», inclusive após selecionar uma pasta do usuário. Rodrigo informou que não tem acesso de administrador agora. Editor/módulo Android e eventual ativação de licença são dependências em aberto. Não aceitar termos nem inventar licença. Build Unity e teste físico ficam pendentes até executar o editor real. Fontes ficam em revisão, sem integração do protótipo não compilado à main.

O ADR 0002 permanece como registro da implementação Godot entregue e base de comparação. Não remover esse projeto, reescrever histórico, publicar APK Unity como comercial ou transformar o verde dos testes Godot em verde da migração. GREEN comercial permanece NO-GO.

## Referências de versão

[Unity 6.3 LTS: suporte até dezembro de 2027](https://unity.com/releases/unity-6/support), [6000.3.27f1, publicado em 20/10/2026](https://unity.com/releases/editor/whats-new/6000.3.27f1), [Input System 1.20.1 para 6000.3](https://docs.unity3d.com/6000.3/Documentation/Manual/com.unity.inputsystem.html), [URP 17.3 associado a 6000.3](https://docs.unity3d.com/6000.3/Documentation/Manual/com.unity.render-pipelines.universal.html). Consulta: 24/10/2026. Versão selecionada é reproduzível, não uma afirmação de ser a mais recente.
