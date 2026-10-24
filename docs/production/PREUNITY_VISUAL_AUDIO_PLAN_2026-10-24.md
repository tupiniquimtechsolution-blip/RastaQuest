# Próximos trabalhos antes do Unity — visual, animação e som

> Registro inicial preservado. O avanço posterior está em [Execução das seis frentes](PREUNITY_EXECUTION_2026-10-24.md): bancada executável, dez novos PNGs e 12 SFX gerados. As afirmações abaixo sobre ausência de áudio descrevem a inspeção anterior à geração; o JSON de cues já reflete os arquivos atuais.

## O que esta entrega conclui

- Duas pranchas da [árvore v02](../../assets/production_drafts/2026-10-24/skill-tree-v02/README.md), com Técnicas de Combate no lugar do ramo de melhoria de arma.
- Quatro [pranchas de movimento](../../assets/production_drafts/2026-10-24/combat-motion-v01/README.md): 12 estudos, cada um com cinco poses-chave. Isso não entrega clips interpolados, rig ou atlas pronto.
- Ligação das 25 habilidades aos estudos visuais; habilidades passivas reutilizam poses e efeitos quando adequado.
- Catálogo inicial de 42 efeitos sonoros planejados, com 12 cues para um primeiro lote de teste, prompts e estados sem geração.
- README visual para navegar pelas artes e pelos documentos, preservando os originais e as versões anteriores.

Tudo continua em 2D. A troca de cabo, lâmina, ponteira e aparência fica em Equipamentos/Machado. A árvore desenvolve técnicas e respostas, como cortes, rebatida, guarda e sequências; não duplica a personalização da arma.

## Ordem sugerida de trabalho independente do editor

| Prioridade | Entrega | Pode avançar sem Unity | Como saber que terminou |
|---|---|---|---|
| P0 | Modelo definitivo de Akane e machado | Sim | Proporções, pegada, tamanho da arma, pivô e pés consistentes nas duas direções. |
| P0 | Animações de produção a partir dos estudos | Sim | Rig 2D ou quadros intermediários, camadas de VFX separadas e animatics revisados. Não recortar miniaturas geradas como solução final. |
| P0 | Reações e transições | Sim | Entrada/saída de golpe e defesa, interrupção por dano/morte, pouso, retomada da corrida e respostas dos inimigos documentadas e animadas. |
| P0 | Especificação das habilidades | Sim | Efeito, pré-requisito, custo, cancelamento e resposta contra cada tipo de inimigo definidos; árvore consistente sem duplicar equipamentos. |
| P0 | Primeiro lote de SFX | Sim, após validar a geração | 12 cues de teste ou gravações originais, com variações, identificação, licença/procedência e audição em celular. |
| P1 | Biblioteca visual dos biomas | Sim | Separar fundos, parallax, peças de chão, plataformas, props e VFX das 21 pranchas; definir medidas de travessia. Prancha não é tileset. |
| P1 | Interface adaptável | Sim | Estados de toque/foco, nós bloqueados, detalhes, navegação, proporções e textos em PT-BR/ES/EN; revisar tamanhos pequenos e fontes licenciadas. |
| P1 | Animatics de confronto | Sim | Sequência de preparação do inimigo → resposta de Akane → contato → recuperação legível, com som sincronizado. |
| P1 | Dados e verificações fora da engine | Sim | IDs de clips/cues, grafo de habilidades, textos e dependências coerentes; testes C# puros podem validar regras quando houver implementação aprovada. |
| P1 | Santuário e promoção | Sim | Organizar camadas e pontos de interesse do santuário em 2D; peças promocionais usam artes arquivadas, sem apresentar conceitos como captura de gameplay real. |
| Gate editor | Importação e primeira sala | Não conclui sem Unity | Compilação real, rig/Animator, controles, colisões, luz/VFX, áudio e save funcionando no editor. |
| Gate dispositivo | Android / Galaxy A13 | Exige build real e aparelho | Desempenho, memória, latência de toque/áudio, legibilidade, bateria e estabilidade medidos. |

Não é necessário esperar o Unity para produzir os arquivos e avaliar animatics. É necessário o editor para comprovar sua integração e comportamento na versão Unity. Os bloqueios de instalação e validação documentados anteriormente não foram resolvidos por esta entrega visual.

## Áudio: o que já existe e o que falta

A busca nesta cópia não encontrou WAV/OGG/MP3/FLAC/AIFF em assets, game ou unity. O gerenciador Godot cria os buses Music e SFX; isso não significa que haja uma biblioteca sonora pronta. Nenhuma nova geração de áudio foi solicitada nesta etapa, que é de planejamento após as artes.

O catálogo conectado do Higgsfield foi consultado em modo somente leitura em 24/10/2026. Ele lista **Mirelo Text to Audio** para efeitos sonoros e **Sonilo Music** para música, ambos marcados como “Game pipeline only”; também lista modelos de voz/TTS. [Snapshot de capacidades](audio_drafts/AUDIO_CAPABILITY_SNAPSHOT_2026-10-24.json). A listagem não comprova que um job será aceito, quanto custará ou como soará. Não houve cotação, geração ou audição, e não foi presumido uso gratuito. Antes de gerar: confirmar parâmetros/rota disponível, acesso, custo e termos do arquivo de saída. Esta é inspeção de capacidade do conector já disponível, não escolha definitiva de fornecedor.

### Catálogo inicial de SFX

| Família | Cues planejados | Conteúdo |
|---|---:|---|
| Combate | 10 | Cortes leve/pesado/ascendente/baixo, impacto em corpo/armadura, bloqueio, parry, rebatida e quebra de guarda. |
| Trovão | 6 | Carga, onda, explosão local, ativação/impacto/fim do escudo. |
| Movimento | 6 | Passos em pedra/madeira/terra, impulso de salto, pouso e avanço/esquiva. |
| Inimigos | 5 | Aviso do cavaleiro, flecha, carga do arcanista, aviso de investida e mudança de fase de chefe. |
| Ambientes | 6 | Floresta, castelo, cavernas, cascata, forja e portal ativo. |
| Interface e progressão | 9 | Foco, confirmação, voltar, indisponível, habilidade, búzio, vida extra, baú e portal. |
| Total | 42 | Cada cue tem ID, prompt, duração-alvo, número de variações, tipo de canal e estado. |

[SFX_CUE_PLAN_2026-10-24.json](audio_drafts/SFX_CUE_PLAN_2026-10-24.json) é um plano; todos os caminhos de áudio e hashes estão vazios porque os arquivos não existem ainda. O primeiro lote tem 12 cues: corte leve, impacto em armadura, defesa precisa, rebatida, carga, onda, foco, confirmação, búzio, vida extra, passo em pedra e avanço. Aprovar a identidade desse lote antes de produzir toda a biblioteca. As variações planejadas são uma meta de gravação/geração, não uma quantidade já entregue.

### Direção sonora e integração futura

- Combate combina ar, peso físico, couro/tecido e metal. O trovão é uma camada reconhecível e controlada; não colocar explosão longa em todo ataque.
- Passos e impactos frequentes precisam de variações para reduzir repetição. Avisos de inimigo devem diferir de confirmação da interface e do som de ataque do jogador.
- Cues curtos de gameplay em mono quando posicionais; ambientes em estéreo quando apropriado. Mestres-alvo WAV PCM 48 kHz/24-bit, preservando o original gerado e verificando o formato real antes de converter. Formato/compressão de runtime é decisão posterior.
- Conferir início, cauda, silêncio, clicks, clipping, consistência de volume e laços contínuos. Fazer audição com fones e alto-falante do celular; não afirmar loudness final sem medição.
- Separar camadas de swing, contato e eletricidade. Uma ação sem acerto toca o swing, não o impacto; um acerto em armadura difere de um bloqueio. Contato deve respeitar o evento confirmado do combate e evitar som duplicado por hit/target.
- Marcadores de animação sincronizam apresentação; não comandam dano. Alertas visuais continuam presentes para jogar sem som. Música, voz/narração e SFX são frentes distintas; não usar voz sintetizada para substituir impactos.
- Registrar prompt/take, origem, termos de uso e hash dos selecionados. Revisão cultural e direitos já fazem parte dos gates do projeto; nenhum áudio é declarado aprovado aqui.

## Próximo ponto concreto

Revisar as técnicas e poses, produzir o modelo/rig e animatics de três ações piloto (corte ascendente, defesa precisa e avanço), depois testar o lote inicial de 12 cues. Expandir para os demais movimentos e sons após essa revisão. O README aponta para todas as artes atuais e mantém as versões anteriores acessíveis. Nenhuma integração, teste de Unity ou release foi declarado.
