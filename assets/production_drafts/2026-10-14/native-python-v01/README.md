# Reconstrução Python v01 — candidato nativo para revisão

Data: 2026-10-14. Rodrigo escolheu neste chat: **“Reconstrução com Python”**. Isso autoriza este rascunho, sem registrar aceite artístico do resultado. TASK-119 / Issue #35 continuam em andamento.

## Entrega

| Arquivo | Conteúdo |
|---|---|
| `protagonist_neutral_candidate_01.png` | Novo desenho nativo, neutro e voltado para a direita, em 128×128; personagem com machado. |
| `weapon_double_axe_neutral_candidate_01.png` | Machado isolado, cabo vertical e cabeça simétrica. |
| `weapon_double_axe_rotation_90_candidate_01.png` | Os mesmos pixels girados 90° no sentido horário, sem interpolação. |
| `protagonist.ora`, `axe_neutral.ora`, `axe_rotation_90.ora` | Fontes OpenRaster com camadas PNG, XML e composição final. |
| `layers/` | Camadas separadas e máscara usada para medir o corpo sem cabelo/arma. |
| `author_native.py` | Fonte editável da reconstrução, com coordenadas e cores autorais. |
| `verify_native.py` | Conferência independente dos arquivos gravados, sem importar a rotina de desenho. |
| `TECHNICAL_GATE.json`, `MANIFEST.json` | Medições, hashes, marcadores, método e pendências. |
| `previews/` | Comparação com v03, fundos claro/escuro em 1× e 4×, painéis estáticos 1280×720 e 640×360. |

Direção selecionada: `../../2026-10-10/model-v03/protagonist-neutral-study-v03.png`, SHA-256 `152940d341a63fa65b64c8043675b4c63bfd5a19021e4f109c12fc0352279edd`. O arquivo original permanece intacto. Seu registro de aprovação cobre a direção visual, não este novo desenho.

O desenho foi reconstruído com coordenadas inteiras em Python/Pillow; os três exports não usam recorte, redução, traçado automático ou quantização da ilustração. A referência só é lida para conferir o hash e gerar a comparação de revisão; é redimensionada exclusivamente nessa prévia. A autoria deste rascunho é automatizada por Codex AI, não atribuída a um artista humano.

## Resultado técnico medido

- Três exports reais de **128×128**, com fundo transparente e alpha exclusivamente **0/255**.
- **22 cores visíveis no conjunto**; protagonista com 22, cada machado com 10. Todos os tons pertencem à proposta de 24 cores de 2026-10-10; eletricidade não foi desenhada.
- Corpo sem cabelo/arma: bbox **[52,39,81,91]**, largura **29 px**, altura **52 px**, último pixel das solas em **y=90**. Origem registrada **(64,64)**; não é uma configuração já integrada ao Godot.
- Cabelo: bbox **[44,35,62,55]**, envelope **18×20 px**, seis clusters definidos na fonte. A distinção visual desses clusters ainda precisa de revisão humana.
- Cabeça do machado: bbox **[48,37,80,55]**, **32×18 px**, simetria horizontal conferida nos pixels. Cabo/pommel ocupa **48 linhas**, y=55..102 inclusive; largura maior no pommel também é registrada na bbox da camada.
- Rotação rígida conferida com todos os pixels, cores e transparência preservados. Pivô no centro da cabeça **(63,5;45,5)**; transformação em coordenadas de imagem: `x'=109-y`, `y'=x-18`.
- As duas pegas do modelo carregado correspondem aos marcadores do machado após rotação e translação. O braço/cabo foi composto em camadas; isso não substitui revisão de interseções em animações.
- Os arquivos OpenRaster foram reabertos e suas camadas recompostas; resultado idêntico aos exports. Não houve teste de abertura num editor gráfico instalado.

Bounding boxes usam máximo exclusivo. A posição do pixel da sola usa índice inclusivo. O corpo mede 52 px porque ocupa y=39..90, e não por subtrair apenas os índices extremos.

## Verificações

O gate existente (`tools/art_asset_gate.py`, frame 128×128, teto 32) passou nos três exports. A conferência adicional validou hashes, máscara do corpo, envelope do cabelo, cabeça/cabo, simetria, rotação exata, marcadores das pegas, paleta conjunta e recomposição dos ORAs. A prévia 640×360 corresponde à redução nearest-neighbor do painel 1280×720.

Para reproduzir, executar `author_native.py` e depois `verify_native.py` com o Python/Pillow já disponíveis. Os PNGs nativos mantiveram os mesmos hashes nas reexecuções desta entrega; bytes do contêiner ORA podem variar por timestamps ZIP. As prévias usam Arial do Windows. Esses scripts substituem somente os arquivos gerados deste diretório quando executados; não alteram referências nem assets de runtime.

## Avaliação visual e riscos

A inspeção local dos painéis claro/escuro e da comparação v03 foi realizada. A primeira construção teve a cabeça reduzida e a curvatura das lâminas corrigida antes desta entrega. Este resultado continua uma interpretação simplificada: rosto, massa do cabelo, tecido, musculatura e ornamentos têm menos informação que o estudo aprovado. Aprovação de geometria não demonstra fidelidade artística; Rodrigo deve avaliar rosto/cabelo, roupa, proporções e arma antes de travar o modelo e a paleta.

O painel de escala contém piso e módulos de 32 px apenas como guia de medidas. É uma composição estática; não é cenário final, captura do Godot, teste Android ou prova de leitura durante combate.

`BASIC_EXPORT_CHECKS = PASS`; `MODEL_LOCK = PENDING`; `PALETTE_LOCK = PENDING`; `CULTURAL_REVIEW = PENDING_SPECIFIC_VERSION`; `RIGHTS_CLEARANCE = PENDING`. Conhecemos referência, método, ferramentas e data, mas não há evidência nova de licença/termos dos materiais de origem. Não inferir liberação de direitos da autoria do script.

Próximo gate: Rodrigo revisar este candidato; corrigir diferenças visuais e fixar modelo/paleta antes dos clips. Revisão cultural específica, procedência/direitos e QA Godot/Android permanecem pendentes. Sem arquivos em `game/assets/`, sem clips finais, sem mudanças em colisão, hitbox ou tempos de combate.
