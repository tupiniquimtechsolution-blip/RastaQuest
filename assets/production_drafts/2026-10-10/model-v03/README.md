# Protagonista v03 — TASK-119 / Issue #35

Data: 2026-10-10. Classificação: AUTHORING STUDY. Revisão visual, paleta, revisão cultural desta versão, licença e exportação nativa pendentes. Não é um sprite final ou um modelo aprovado.

## Resultado

Uma nova proposta neutra foi produzida com o ImageGen integrado, usando a imagem detalhada `Nova passta/Nova pasta/idle` enviada por Rodrigo e a character bible canônica como referências. A primeira tentativa praticamente conservou o detalhamento original; a segunda agrupou mais os volumes e retirou o colar. O rosto, braço, botas, dreadlocks e machado ficaram mais próximos da referência detalhada do que os estudos geométricos pequenos do lote.

O objetivo completo ainda não foi atingido: a ferramenta não entregou o arquivo nativo 128×128, paleta de até 32 cores e alpha binário solicitados. O novo candidato tem 1254×1254, 105.111 cores visíveis e alpha parcial. Não houve redução automática, quantização, desenho com Pillow ou promoção a `game/assets/`. O corpo de 52 px, pés em y=90, contagem/envelope dos clusters de cabelo e medidas rígidas da arma não podem ser declarados atendidos neste arquivo.

## Arquivos

- `protagonist-neutral-study-v03.png`: segunda tentativa, proposta visual atual.
- `protagonist-neutral-attempt-01.png`: primeira tentativa, preservada como evidência da correção.
- `reference-uploaded-idle.png`: cópia idêntica da referência detalhada enviada, originalmente sem extensão.
- `reference-portal-study.png`: cópia idêntica de `Nova passta/Nova pasta/player_portal_enter_02.png`, para comparar a perda de identidade. O manifesto da sequência declara autoria com Pillow e classifica como estudo; não presumir o mesmo processo em outros arquivos.
- `PROMPT.txt` / `PROMPT_REFINEMENT.txt`: textos integrais das duas solicitações ao ImageGen integrado, com papéis dos inputs e requisitos.
- `TECHNICAL_GATE.json`: SHA-256, base, procedência, resultados técnicos e pendências.
- `VISUAL_REVIEW.html`: comparação local com fundos claro/escuro/quadriculado e miniaturas. Muda apenas a exibição no navegador, sem criar ou modificar imagens.

Base da branch: `22dce25b5812427d9a15f06595dd087801a640a8`. Referências do lote: `27acb4fe8b07111fb7150bb244a8e03288564fa7`, branch `imagens-novas`. SHA-256 das cópias em `TECHNICAL_GATE.json`; a character bible permanece no caminho canônico `assets/concepts/characters/protagonist/rq-protagonist-character-bible-v01.png`.

## Verificação técnica e limites da revisão

Executado `tools/art_asset_gate.py` com frame esperado 128×128 e limite de 32 cores. Rejeição esperada registrada: `frame_size_mismatch`, `palette_exceeds_limit`, `partial_alpha_requires_cleanup`. A existência de alguma transparência não significa que as bordas estejam limpas: o alpha bbox se estende por quase toda a imagem.

Na inspeção visual, a segunda tentativa conserva massas mais volumosas, remove o colar e mantém a pose neutra. A roupa/torso ainda sugerem algum volume de três quartos, a arma conserva ornamentação e as mechas precisam ser resolvidas em clusters na grade. A imagem isolada não demonstra continuidade entre animações, leitura em movimento, encaixe de colisão ou prova em Android. Paleta/forma não foram aceitas por Rodrigo nesta entrega.

## Próximos gates

1. Rodrigo revisa a direção visual apresentada: rosto/corpo/roupa, massa dos dreadlocks, silhueta da arma e detalhes culturais desta nova versão. Essa seleção não equivale a aceite do export técnico.
2. Produzir um modelo neutro nativo na grade 128×128 com corpo de 52 px, largura e marcadores da spec. Preservar anatomia em clusters em vez de reduzir a um boneco geométrico. A ferramenta integrada não satisfez esse gate nas duas tentativas; será necessária uma entrega de pixel art nativa verificável.
3. Registrar paleta exata, pés/origem, grip e centro da cabeça da arma; conferir simetria, rigidez, alpha 0/255 e comparação na sala do jogo.
4. Só após o modelo visual/export passar, iniciar os dez clips, integrar separadamente e testar movimento/mobile. Os gates de Forest, Chaser e revisão cultural seguem abertos nas issues #36–#38.

A escala aprovada anteriormente por Rodrigo continua registrada na spec e na revisão v02 do PR #45. Não se atribui essa aprovação a estas novas imagens. Não há nova alegação de licença, aprovação humana ou liberação cultural. Não foram incorporados arquivos de `PortalAscendant` nem o PDF antigo.

## Estado de entrega

TASK-119 e Issue #35 permanecem em andamento. Este PR documenta a proposta e a limitação real da geração; não fecha o gate de modelo nativo. As duas imagens foram geradas por ferramenta, não desenhadas manualmente. Referências externas: nenhuma nova; foram utilizadas as referências e contratos existentes do projeto. Nenhum código de gameplay ou geometria de colisão foi alterado.
