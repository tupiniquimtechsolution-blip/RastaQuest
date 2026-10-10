# Retorno dos prompts nativos — lote 01

Recebido em 2026-10-10 de Rodrigo: 11 PNGs e relatório de auditoria colado no chat. Rodrigo informou: “Gostei do resultado”. Os arquivos foram copiados sem alteração e receberam nomes descritivos no repositório. Nome recebido, destino, SHA-256 e medições estão em `MANIFEST.json`.

## Organização

- `originals/protagonist-study.png`: protagonista recebido como `Guerreiro Rastafari com Machado Ornamental.png`.
- `originals/axe-diagonal-study.png`: machado recebido como `Imagem do ChatGPT 10 de out. de 2026, 16_56_48-1.png`.
- `originals/axe-vertical-study.png`: machado adicional recebido como `Imagem do ChatGPT 10 de out. de 2026, 16_56_51-2.png`.
- `previews/`: oito prévias em fundos claro/escuro, preservadas com os nomes recebidos.
- `MANIFEST.json`: inventário e verificações independentes.
- `AUDIT_REVIEW.md`: conferência do relatório fornecido, contexto correto da referência aprovada e próximos gates.

O conjunto dos PNGs tem 4.260.251 bytes. Nenhum arquivo se aproxima do limite de 100 MiB. Todos os hashes das cópias foram comparados com seus arquivos de origem. Nenhuma imagem foi editada, reduzida, quantizada ou reconstruída durante esta importação.

## Resultado da conferência

Os três originais têm 1254×1254 pixels, excedem 32 cores visíveis e possuem alpha intermediário. São AUTHORING STUDIES, com export técnico reprovado. As oito prévias têm fundo opaco e finalidade de auditoria; não são exports de jogo. As quatro prévias de detalhe 4× possuem blocos uniformes 4×4, compatíveis com a ampliação indicada. Isso não reduz a resolução do original nem prova leitura em gameplay.

O relatório fornecido identificou dois originais. O terceiro machado, vertical, foi recebido neste lote e agora é rastreável, mas não recebe o nome `weapon_double_axe_rotation_90_01.png`: não foi demonstrado que seja uma rotação rígida de 90° do mesmo desenho, com as mesmas medidas e marcadores.

## Referência para a próxima auditoria

A direção visual v03 aprovada está em `../model-v03/protagonist-neutral-study-v03.png`, SHA-256 `152940d341a63fa65b64c8043675b4c63bfd5a19021e4f109c12fc0352279edd`. O registro de Rodrigo está em `../model-v03/OWNER_VISUAL_APPROVAL.md`.

Na data desta importação, a referência está no [PR #47](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/47), branch `art/119-neutral-model-v03`, e ainda não está na main `22dce25b5812427d9a15f06595dd087801a640a8`. Para a referência imutável apresentada: [v03 no commit 174ae852](https://github.com/tupiniquimtechsolution-blip/RastaQuest/blob/174ae8524be78526da1cb4e9af2495ed93837e3d/assets/production_drafts/2026-10-10/model-v03/protagonist-neutral-study-v03.png).

Assim, a ausência de v03 na main consultada pelo auditor é uma diferença de branch, não uma perda de arquivo. A importação não substitui a referência v03 aprovada. Este lote apresenta diferenças visuais, incluindo adornos no cabelo, brinco e colar, que não estavam autorizados nos prompts nativos; revisão cultural específica continua separada.

## Pendências

TASK-119 / Issue #35: produzir um modelo nativo fiel à direção selecionada, verificar corpo de 52 px, frame de 128×128, paleta, alpha e marcadores. Não repetir um resultado em alta resolução como se atendesse à grade nativa. As medidas da arma e o par de rotação precisam de arquivos verificáveis.

TASK-122 / Issue #38: revisão cultural dos detalhes desta nova versão e dos materiais finais; procedência/licença continuam pendentes. O relato de satisfação com o resultado não altera os fatos técnicos nem comprova direitos ou integração.

Nenhuma imagem foi promovida a `game/assets/`; nenhum código, colisão ou timing foi alterado. Nenhum teste de Godot/Android foi realizado para este lote. Novos clips dependem do modelo nativo validado.
