# Conferência independente da auditoria fornecida

Data: 2026-10-10. Fonte: texto e arquivos fornecidos por Rodrigo no chat. Este documento resume e confere os achados; não é uma transcrição integral do relatório recebido. Nenhuma instrução do relatório foi tratada como autorização para alterar o jogo.

## Medições dos originais

| Original no repositório | Tamanho real | Cores RGB visíveis | Níveis de alpha | Pixels com alpha intermediário | Resultado |
|---|---|---:|---:|---:|---|
| protagonist-study.png | 1254×1254 | 146.120 | 256 | 491.381 | FAIL: frame, paleta, alpha |
| axe-diagonal-study.png | 1254×1254 | 76.350 | 256 | 305.892 | FAIL: frame, paleta, alpha |
| axe-vertical-study.png | 1254×1254 | 62.442 | 256 | 345.134 | FAIL: frame, paleta, alpha |

SHA-256 do protagonista: `4d759360c38ac7c4dd6c6d84dd71c673dadd2abf29e569913a608e1630760970`.
SHA-256 do machado diagonal: `c429cbfd27fc607ddfc738cc6b748b68fa202a19032a67f8007cb14d8d4bda88`.
SHA-256 do machado vertical: `9543a04a92a02f2719f4166aea7ea5a05275301d69019a9274aa3a0a1170eebc`.

Os dois primeiros hashes e suas medições RGB/alpha confirmam os valores do relatório recebido. O terceiro original foi incluído na conferência atual. Cada original possui algum alpha=0, portanto há transparência real, mas ela não é exclusivamente binária.

`MANIFEST.json` também registra cores RGBA distintas. Esse número pode ser maior que o de cores RGB porque a mesma cor pode aparecer com vários valores de alpha. O gate existente `tools/art_asset_gate.py` conta RGBA; ambas as contagens excedem o limite e levam à mesma reprovação. Não confundir esses números em comparações futuras.

Bounding boxes atuais usam o limite superior exclusivo, padrão do Pillow. Os máximos fornecidos no texto do auditor são inclusivos; por isso o limite direito/inferior parece diferir em um pixel. As medições são compatíveis.

## O que foi verificado e o que permanece pendente

- PASS: existência dos 11 arquivos; PNGs legíveis; cópias com hashes idênticos; dimensão/paleta/alpha medidas; valores principais do relatório confirmados.
- PASS para a finalidade das prévias: quatro detalhes 512×512 com blocos uniformes 4×4. Os oito fundos compostos são opacos, como esperado para visualização em claro/escuro.
- FAIL: todos os três originais como exports nativos de 128×128 com paleta limitada e alpha binário.
- NÃO VERIFICADO como contrato nativo: corpo 52 px/largura, origem, solas y=90, cabelo e marcadores da arma. Não há modelo nativo para medir esses critérios na grade de produção.
- NÃO VERIFICADO: par rígido de rotação de 90°. Existem agora dois estudos isolados da arma, mas presença de arquivos não comprova rotação, identidade de geometria ou marcadores.
- NÃO REPRODUZIDO nesta conferência: contagem de componentes desconectados do relatório fornecido. Não foi necessário repetir esse cálculo para confirmar os bloqueios de tamanho/paleta/alpha. Um componente isolado também não prova defeito artístico por si só.
- PENDENTE: paleta exata aprovada, revisão cultural específica, procedência/licença, integração e QA visual no Godot/Android.

## Comparação da referência

O auditor consultou a main `22dce25b5812427d9a15f06595dd087801a640a8`, que não contém o v03 ainda em revisão no PR #47. A referência correta e o aceite estão disponíveis na branch `art/119-neutral-model-v03`, pasta `assets/production_drafts/2026-10-10/model-v03/`. Foi verificado o SHA-256 da referência aprovada durante esta importação.

Visualmente, o novo protagonista mantém faixa, roupa clara, calça verde, pele escura, dreadlocks e machado reconhecíveis. Em relação à referência aprovada, reaparecem adornos capilares, brinco e colar; o detalhamento e a posição/ornamentação da arma também variam. A satisfação de Rodrigo com o resultado foi registrada, sem substituir silenciosamente a imagem aprovada ou declarar que esses elementos passaram por revisão cultural.

## Próxima entrega

O arquivo de direção deve orientar uma reconstrução nativa de pixel art com anatomia e materiais legíveis, sem transformar o protagonista em placeholder. O autor/exportador precisa demonstrar capacidade de produzir 128×128 reais; prompts sozinhos não garantiram isso nas tentativas recebidas. Após esse modelo passar, validar a arma rígida e os marcadores antes dos clips. O upload apenas disponibiliza os estudos e as evidências; não resolve o gate nativo.

Classificação final preservada: **EXPORT REPROVADO — AUTHORING STUDY**. Sem edição dos PNGs, promoção a runtime, alteração de gameplay ou alegação de QA/licença concluídos.
