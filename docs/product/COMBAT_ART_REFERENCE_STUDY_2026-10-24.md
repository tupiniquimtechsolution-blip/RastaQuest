# Estudo técnico — combate, exploração e apresentação do Rasta Quest

Data: 24/10/2026. Solicitante: Rodrigo. Estado: pesquisa pública + decisões de direção + proposta de implementação. Não é engenharia reversa nem auditoria do código dos jogos de referência.

## Decisão recebida

O novo alvo é **ilustração 2D detalhada, próxima da linguagem visual de Tails of Iron, com identidade própria**, e **Unity** para a evolução de gráficos, movimento e polimento. A decisão está em [ADR 0003](../adr/0003-unity-illustrated-direction.md). O Godot entregue continua sendo a referência funcional enquanto a paridade da migração não for comprovada.

As quatro imagens têm funções distintas: Sons of Sparta orienta ação lateral e exploração; a imagem 2 orienta a composição do HUD; a imagem 3 orienta enquadramento, profundidade e sombra periférica; Tails of Iron orienta a ambição de combate, variedade e narrativa. A identificação do jogo da imagem 2 não foi confirmada. A imagem não deve ser tratada como interface de Sons of Sparta.

## O que está documentado publicamente

### God of War Sons of Sparta

É um action-platformer 2D de Mega Cat Studios para PS5. A história acompanha Kratos jovem e Deimos na Lacônia. Lança e escudo recebem acessórios com progressão própria, e há três árvores principais de habilidades: ofensiva, defensiva e movimento. Os Gifts of Olympus acrescentam ataques especiais e superataques; incluem opções de precisão à distância, explosões e sequências de curta distância. Há inimigos com perfis distintos, como minotauros, sátiros e legionários mortos-vivos. Exploração recompensa com missões opcionais, encontros escondidos e saque; os ambientes usam pixel art de alta definição. Esses são sistemas documentados, não um conjunto de timings disponível para copiar. [Visão oficial do combate e exploração, Santa Monica Studio](https://blog.playstation.com/2026/02/13/god-of-war-sons-of-sparta-what-you-need-to-know/).

A página oficial descreve correr, saltar, escalar e resolver enigmas ambientais. Seu material de dicas menciona a combinação de ponta, empunhadura e extremidade da lança. [Página oficial e vídeos de aprofundamento](https://www.playstation.com/en-us/games/god-of-war-sons-of-sparta/).

O diretor Zack Manko explica que os artefatos também permitem resolver puzzles e explorar. A mesma ferramenta pode, portanto, ligar progressão de combate e leitura do mundo — uma conclusão de design a partir dessa declaração, não prova de como cada artefato é implementado. [Entrevista oficial com Mega Cat Studios](https://blog.playstation.com/2026/02/16/god-of-war-sons-of-sparta-mega-cat-studios-discuss-origins-of-kratos-and-companys-name/).

The Pit é um modo roguelike separado da campanha. Alterna inimigos e recompensas, usa modificadores globais de dificuldade e recursos próprios para desbloqueios e melhorias permanentes. Pode ser jogado sozinho ou em cooperação local offline de duas pessoas. Isso não comprova cooperação na campanha nem transforma toda a história em uma run. [Descrição oficial do Pit of Agonies](https://blog.playstation.com/2026/02/26/unlock-god-of-war-sons-of-spartas-toughest-challenge-in-the-pit/).

As notas oficiais v1.0.0.4 registram correções de interação de porta e de bloqueio de progressão após derrota em um encontro. Para o Rasta Quest, isso reforça a necessidade de testar derrota, retorno e portal, além de vencer uma sala normalmente. [Notas do desenvolvedor](https://megacatstudios.zendesk.com/hc/en-us/articles/46319433084564-Patch-Notes-v-1-0-0-4).

### Tails of Iron — primeiro jogo

É uma aventura RPG ilustrada à mão: Redgi precisa restaurar seu reino e enfrentar o Frog Clan. O combate exige observar o adversário e reagir, com rolamento, parry, execuções e arco. Equipamentos mudam escolhas: armadura mais protetora pode reduzir a agilidade do rolamento, machados privilegiam impacto e lanças velocidade. O mundo tem seis biomas, segredos, missões e companheiros em certas tarefas. Receitas e projetos encontrados sustentam melhorias de vida e fabricação de equipamento. Chefes apresentam desafios próprios. A página também descreve duas expansões; conteúdo delas não deve ser confundido com requisitos do jogo-base. [Descrição da editora United Label](https://unitedlabelgames.com/tails-of-iron/).

Na entrevista de desenvolvimento, Jack Bennett descreve três pilares: história por missões, combate e exploração/RPG. Explica que a equipe retirou a barra de stamina para que o jogador prestasse mais atenção ao inimigo e experimentasse as ações. Também associa o detalhe visual a contornos fortes e à colocação de elementos em profundidades próprias, criando parallax. Trata-se da intenção e do processo relatados pelo desenvolvedor, não de medição independente de desempenho. [Entrevista direta de Bennett à MCV/DEVELOP](https://mcvuk.com/development-news/when-we-made-behind-the-scenes-of-the-redwall-inspired-soulslike-tails-of-iron/).

### Limites da pesquisa

As fontes consultadas não publicam código, motor interno, tabelas completas de frames, hitboxes, cancelamentos, invulnerabilidade, janelas exatas de parry, algoritmo de IA, orçamento de memória ou desempenho no Galaxy A13. Não atribuímos números inventados a esses jogos. Vídeos e imagens não bastam para medir input latency. Também não foi confirmada aqui uma tabela oficial completa das cores de avisos de Sons of Sparta. Não redefinir os avisos atuais do Rasta Quest com base em guias secundários.

## Tradução para sistemas próprios do Rasta Quest

Esta seção é proposta de design e arquitetura do nosso projeto, não descrição dos jogos pesquisados.

| Sistema | Base existente em Godot | Alvo e gate de migração Unity |
|---|---|---|
| Movimento | aceleração/frenagem, coyote, buffer e pulo duplo | preservar resposta, testar subida/queda, bordas, plataforma unilateral e rotação física |
| Ataque | três golpes de machado, golpe aéreo, acerto único por alvo | separar intenção, fase de dano e apresentação; desenhar antecipação, passagem da lâmina e recuperação diferentes por golpe |
| Defesa | proteção ao redor, dano reduzido, parry e reflexão | manter defesa acessível; sinais indicam qual resposta funciona, sem depender apenas de cor |
| Inimigos | cinco arquétipos e dois chefes na revisão Godot | migrar por arquétipo; provar cada ataque, interrupção, morte e combinação de adversários |
| Exploração | salas largas e portais entre biomas | rotas opcionais reconhecíveis, marcos visuais, atalhos e pequenas recompensas; não prometer um mapa metroidvania inteiro nesta etapa |
| Progressão | três escolhas temporárias, cura e meta leve | manter builds legíveis; habilidades de exploração persistentes exigem decisão de balanceamento e save versionado |
| Narrativa | premissa das fraturas, Refúgio/Santuário | primeira missão com motivação, pista ambiental, consequência e retorno ao Refúgio; nomes e texto narrativo finais ainda pendentes |
| Apresentação | sprites de revisão e fundos existentes | HUD e moldura próprios; redesenhar ativos em ilustração, com personagens separados do cenário e animação consistente |

### Combate e fluidez

Os valores iniciais vêm do **nosso código atual**: movimento 260 px/s, aceleração 1800 px/s², frenagem 2200 px/s², gravidade 1500 px/s²; coyote 100 ms e buffer de pulo 120 ms. Em Unity, 64 pixels de referência correspondem a uma unidade. O salto inicial de 560 px/s torna-se 8,75 unidades/s. São valores de partida para comparação, não prova de paridade física entre motores.

Ataque base: antecipação 50 ms, contato 160 ms, recuperação 90 ms; animação e dano seguem o mesmo relógio. Cada alvo aceita um acerto por ataque. A próxima animação precisa mostrar deslocamento de ombro, quadril, apoio dos pés e arco de lâmina — não só girar uma arma por cima de um corpo parado. Acelerar um ataque precisa ajustar a sequência inteira. Manter buffer de 180 ms e cancelar comandos ao pausar, perder foco ou alterar a área de tela.

Defesa base de migração: janela perfeita de 280 ms, um contra-ataque perfeito por pressão, empurrão e dano de 50% de um golpe comum; segurar defesa reduz dano e pode devolver projéteis. O parry não deve ser um input de precisão impossível no toque. A versão comercial ainda precisa provar resposta contra cada ataque, impedir loops de reflexão e duplicação de dano e tornar inequívoco o que não pode ser bloqueado.

Próxima expansão proposta: classes explícitas de ameaça — golpe comum, projétil refletível, ataque de chão e investida pesada — com ícone, postura, som e área de efeito coerentes. Separar **fase temporal** do golpe de **tipo de resposta** exigida. Os círculos amarelo/vermelho atuais não passam automaticamente a significar regras novas. Introduzir cada classe em encontro seguro e testar com jogador real antes de misturar três ameaças.

### Roster, encontros e chefes

| Papel próprio | Pressão que deve criar | Variação planejada | Verificação |
|---|---|---|---|
| Chaser | distância curta | corte horizontal e golpe atrasado | leitura de dois tempos; sem tremedeira na aproximação |
| Ranged | espaço e linha de tiro | tiro único e salva espaçada | reflexão, cobertura e ausência de tiros invisíveis |
| Charger | compromisso de direção | investida e recuperação vulnerável | direção travada após aviso, não perseguir instantaneamente |
| Controller | escolha de posição | zona temporária e abertura segura | terreno não deve cobrir toda a rota nem o HUD |
| Exploder | prioridade e afastamento | detonação anunciada | alcance visível, reação possível e morte sem dano duplicado |
| Chefes | domínio de padrões | sequências por fase, pausas e contra-ataque | transições, derrota, retorno, morte e portal nunca bloqueiam a run |

Essas variações são backlog, não conteúdo já entregue em Unity. A primeira sala de migração só cobre Chaser e Ranged. Recolorir o mesmo sprite não constitui um novo comportamento. O gerenciador de encontros deve limitar quantos adversários iniciam ataques simultâneos, enquanto outros se reposicionam. Não usar fila invisível que faça o primeiro inimigo oscilar sem motivo.

### Mundo e lore

Primeira fatia proposta: Refúgio → Floresta → encontro de guardião → retorno com uma pista das fraturas. Dentro da Floresta, uma rota alta opcional mostra a diferença entre atravessar e explorar; o caminho principal precisa ter folga para os inimigos passarem sob plataformas. O portal deve alterar arquitetura, paleta, som ambiente e composição de inimigos, mantendo funções de combate reconhecíveis.

Antes de ampliar a história: definir objetivo do protagonista, custo das fraturas para um NPC e informação nova que a primeira missão revela. Usar sinais ambientais e diálogos curtos em PT-BR/ES. Não importar mitologia grega, personagens, nomes, falas ou lore de Tails of Iron. As referências Rastafari e a inspiração do machado exigem revisão cultural do novo material, especialmente símbolos nos antagonistas.

## HUD, moldura e arte — especificação

Observação da imagem 2: retrato no canto superior, nome alinhado e barra horizontal longa com acabamento dourado. Adaptar essa hierarquia com retrato próprio e moldura angular original. Mostrar somente vida e estados reais: não inventar mana, vidas extras, poções, cronômetro ou placar para preencher o espaço. A barra deve representar dano fracionário, cura, morte e limite de vida. Em tela de referência 1280×720: bloco do retrato de aproximadamente 80×88, barra de aproximadamente 298×26, texto legível e área segura do dispositivo respeitada.

Observação da imagem 3: elementos escuros em primeiro plano emolduram uma sala iluminada e separam planos. Aplicação própria: sombras periféricas graduais, vegetação/ruína nas bordas e centro mais claro, sem esconder plataformas, personagens, projéteis, portal ou botões. A UI fica acima dessa camada. Oferecer redução de efeitos; vinheta é apresentação, não geometria de colisão.

O [estudo ilustrado gerado](../../assets/production_drafts/2026-10-24/illustrated-direction-v01/forest-art-target-v01.png) é uma proposta original de composição: guerreiro humano negro, dreadlocks, faixa tricolor, calça verde, botas, machado duplo e eletricidade ciano. Foi gerado com a ferramenta integrada de imagens; prompt e procedência estão no mesmo diretório. Não é captura Unity. A imagem tem cenário, atores e luz na mesma camada: **não usar como fundo de gameplay com personagens já pintados**.

Produção necessária: model sheet ilustrada, paleta/material, vistas, escala, rig ou frames desenhados; retrato próprio; machado com pivô; idle/run/jump/fall, três golpes e aéreo, defesa/parry, hurt/death/portal; equipamentos separados; Chaser e Ranged; camadas de Floresta; depois Castelo, Cavernas, chefes e demais inimigos. Rig 2D pode servir à locomoção, mas ataques exigem poses de silhueta e correções desenhadas. Maior resolução sozinha não resolve articulação ou consistência.

### Unity e Android

Começar por paridade em uma sala; depois introduzir URP 2D com luzes limitadas e sombras selecionadas. URP suporta iluminação 2D de sprites; isso não comprova custo aceitável neste aparelho. [Fluxo oficial de criação 2D](https://docs.unity3d.com/6000.1/Documentation/Manual/2d-game-creation-wokflow.html). O protótipo inicial usa renderização simples e moldura em UI; não anuncia URP já configurado.

Planejar atlas por região, descarregamento entre biomas, redução de overdraw, texturas ETC2 para o alvo GLES3 e amostragem bilinear nos futuros ativos ilustrados. Os sprites pixel art transitórios mantêm point sampling. Não aplicar filtro borrado nem aumentar PNG e chamar isso de redesenho. Os atlas e a compressão finais ainda precisam de perfil no aparelho.

Metas internas propostas: 60 fps desejável, opção estável de 30 fps, resposta consistente do toque e sessão longa sem falha térmica/memória. Não são resultados medidos. Registrar tempos de frame, memória, tamanho de download, temperatura percebida e estabilidade em 20 minutos no Galaxy A13. Validar ARMv7/ARM64, API mínima 24/alvo 36, OpenGL ES 3, instalação e rotação nos dois sentidos. O novo APK de revisão usa identificador separado, sem sobrescrever saves do Godot.

## Ordem de execução e gates

1. Instalar editor/módulo Android, ativar licença com o titular quando exigido e importar projeto real.
2. Compilar e executar sala Unity; provar controles, ataque, defesa/reflexão, contato, câmera, portal e HUD. Os testes C# puros não substituem essa etapa.
3. Produzir primeiro conjunto ilustrado do protagonista, arma e Floresta; revisar em escala de jogo, não apenas em ampliação.
4. Migrar os demais arquétipos, chefes, efeitos, áudio, progressão e idiomas; verificar paridade e saves sem perda de dados.
5. Fechar primeira missão e encontros com variedade, exploração e consequências narrativas.
6. Medir APK exato no Galaxy A13, obter aceite visual da versão, revisar direitos/cultura, assinatura, distribuição e critérios comerciais.

Até cumprir esses gates: **GREEN comercial não alcançado**. A autorização de direção não é aceite da ilustração gerada, nem da animação ou APK futuro.
