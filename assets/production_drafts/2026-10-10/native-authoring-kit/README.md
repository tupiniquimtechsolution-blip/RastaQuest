# Pacote de execução nativa — TASK-119 / Issue #35

Data: 2026-10-10. Entrega deste pacote: instruções de execução e paleta proposta. Nenhum sprite foi produzido ou aceito por este pacote.

## Referência e objetivo

Reconstruir um único modelo neutro e um machado isolado na grade nativa antes de iniciar animações. Preservar rosto, roupa, volumes, cabelo e silhueta do machado da direção aprovada:

- Arquivo: `../model-v03/protagonist-neutral-study-v03.png`.
- SHA-256: `152940d341a63fa65b64c8043675b4c63bfd5a19021e4f109c12fc0352279edd`.
- Registro de Rodrigo: `../model-v03/OWNER_VISUAL_APPROVAL.md`.
- Contrato: `docs/production/PROTAGONIST_PRODUCTION_SPEC.md`.

O lote `../prompt-return-01/` é material de estudo e auditoria. Não substitui a direção selecionada: apresenta novos adornos e três originais de 1254×1254 reprovados no gate. Não usar redução automática ou quantização da ilustração como comprovação de reconstrução final.

## Primeira entrega solicitada

| Arquivo proposto | Conteúdo verificável |
|---|---|
| `protagonist_neutral_candidate_01.png` | Modelo neutro, frame transparente de 128×128, corpo de 52 px, largura corporal até 32 px sem cabelo/arma, origem (64,64), solas em y=90. |
| `weapon_double_axe_neutral_candidate_01.png` | Arma isolada no mesmo frame, cabo de 48 px e cabeça simétrica de 32×18 px; registrar pega, centro e eixos. |
| `weapon_double_axe_rotation_90_candidate_01.png` | Mesmo desenho girado rigidamente 90°, com direção e pivô registrados; comparar máscara, cores e marcadores. |
| Fonte editável e `MANIFEST.json` | Camadas separadas de corpo, cabelo, roupa, arma e efeitos; medidas reais, hashes, paleta utilizada e procedência. |

Esses nomes descrevem arquivos a produzir; eles ainda não existem. Efeitos e animações ficam para a etapa seguinte. Cabelo: seis clusters principais e envelope de repouso de 18×20 px. Faixa acima dos olhos em vermelho/amarelo/verde; calça verde, botas marrons e roupa clara. Não acrescentar colar, brinco, contas ou símbolos culturais novos.

Em 52 px, detalhes competem por poucos pixels. Priorizar rosto/perfil, faixa, massa dos dreadlocks, roupa e duas lâminas; validar semelhança visual com Rodrigo. Formas genéricas que apenas passam nas medidas não atendem à entrega.

## Paleta para experimentar

`PALETTE_PROPOSAL.json` contém 24 cores visíveis. Mantém as 16 propostas na spec e acrescenta oito propostas para roupa clara, ouro, luz da pele e lâmina. Não foi extraída automaticamente da ilustração. É um orçamento compartilhado para protagonista, arma e eletricidade; não são 32 cores por arquivo.

Alpha permitido: 0 no fundo e 255 nos pixels visíveis. Paleta exata e novos tons continuam pendentes de comparação na cena e aprovação; a existência deste JSON não fixa a paleta.

## Manifest da entrega real

Registrar somente medições demonstradas, usando `null` para itens ainda não verificados:

- Arquivo, SHA-256, dimensões, cores RGB/RGBA visíveis, níveis de alpha e resultado do gate.
- Origem, linha de contato, bounding boxes de corpo/cabelo/arma e convenção de coordenadas. Para caixas, explicitar se o limite máximo é exclusivo; não confundir altura do conteúdo com distância entre coordenadas dos extremos.
- Camadas e máscara usadas para medir corpo sem cabelo/arma; seis clusters identificáveis do cabelo.
- Cabo/cabeça, marcador de pega e centro da cabeça; pivô, sentido e transformação do par a 90°. Não declarar rotação rígida por semelhança visual entre duas gerações.
- Lista efetivamente utilizada de cores no conjunto dos três PNGs, comparada à proposta e ao teto de 32.
- Autor/ferramenta/data, referência usada e evidência de termos/direitos, com pendências explícitas.
- Aceite visual, revisão cultural, direitos e QA em campos separados. Aprovação da direção v03 não preenche esses campos automaticamente.

## Conferência antes dos clips

Executar o gate existente sobre os três PNGs reais, com `--frame 128 128 --palette-limit 32`, e arquivar a saída. Ele verifica tamanho, cores por arquivo, transparência e alpha; **não** verifica paleta conjunta, anatomia, cabelo, medidas da arma, marcadores, semelhança ou rotação. Esses itens precisam de evidência adicional.

Mostrar comparação com a v03 e prévias em fundos claro/escuro, 1× e ampliação nearest-neighbor. Em seguida, comparar a leitura em uma cena 1280×720 e 640×360. Uma composição de revisão não equivale a teste no Godot ou no Android. Registrar execução real no dispositivo quando ocorrer.

## Estado e próximos gates

As tentativas anteriores do gerador produziram estudos grandes em vez de exports nativos. Nesta execução não foram encontrados Aseprite/LibreSprite/Godot/Blender no PATH ou nos diretórios de Program Files consultados; isso não prova ausência em toda a máquina. A escolha entre reconstrução técnica em Python como rascunho e execução por pixel artist foi apresentada a Rodrigo e continua pendente na criação deste pacote.

TASK-119 permanece Em Andamento. Próximos gates: produzir candidato nativo; conferir pixels/medidas; Rodrigo revisar fidelidade e paleta; revisão cultural específica e procedência; clips; integração e QA. Nenhum arquivo deste pacote vai para `game/assets/`, e colisões, hitbox e tempos de combate permanecem sob o contrato existente.

Verificação deste pacote: JSON válido, 24 cores e IDs únicos, 16 tons da spec e oito novos tons propostos, alpha permitido 0/255 e hash da referência conferido. Isso valida a proposta documental; não é um resultado de gate técnico de sprite. CI e a escolha do método devem ser acompanhados no PR #47 e na TASK-119, sem declarar conclusão da produção.

Atualização — 2026-10-14: Rodrigo escolheu **“Reconstrução com Python”**. O primeiro candidato nativo, suas fontes e medições estão em `../../2026-10-14/native-python-v01/`. A escolha do método foi resolvida; aceite visual e paleta continuam pendentes. O texto acima registra o estado deste pacote na data de criação.
