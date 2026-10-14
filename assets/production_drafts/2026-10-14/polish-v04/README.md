# Correção de direção: fidelidade ao modelo detalhado original

Data: 2026-10-14. TASK-119 / Issue #35. Estado: **estudo visual para revisão; não é export final**.

Rodrigo rejeitou explicitamente a reconstrução `../native-python-v01/`: “assim está muito feio”, “quero que o resultado final seja igual aquele primeiro modelo que anexei no github” e “assim todo quadrado não da”. Sua referência a Super Mario Bros indica exigência de acabamento comercial polido; não autoriza trocar a identidade do guerreiro por Mario, proporções chibi ou formas genéricas.

O rascunho Python permanece preservado como evidência técnica, com `OWNER_REVIEW.json` e aceite visual **rejected**. Passar nas medidas não cumpriu a fidelidade artística. Não produzir clips nem integrar aquele desenho.

## Referência utilizada e resultado

Referência detalhada identificada no histórico: `../../2026-10-10/model-v03/reference-uploaded-idle.png`, cópia idêntica de `Nova passta/Nova pasta/idle` da branch `imagens-novas`, commit `27acb4fe8b07111fb7150bb244a8e03288564fa7`. A referência foi inspecionada antes da edição e permanece intacta. A direção v03 anteriormente aprovada também é preservada; a nova crítica não aprova automaticamente este estudo.

`protagonist-original-style-study-v04.png` foi produzido pelo ImageGen integrado usando essa referência direta. `PROMPT.txt` preserva a solicitação integral. A edição busca recuperar rosto/perfil, volumes do braço/torso, dreadlocks curvos, roupa, botas, sombreamento de materiais e o machado detalhado. A inspeção visual confirmou recuperação desses elementos em relação ao rascunho geométrico; semelhança exata e aceite artístico continuam com Rodrigo.

A escolha anterior de Python não comprovou qualidade do processo usado. Nesta correção foi utilizado o ImageGen para a aparência; não houve nova redução automática ou quantização da referência, nem geração de outro boneco geométrico para satisfazer medidas.

## Verificações e limitações

O novo arquivo tem **1254×1254**, **171.072 cores RGBA visíveis**, alpha intermediário e SHA-256 `f08aff2e8f1cc1933b46d4ee2fb425617d123cc44848ee9a72d6482016305651`. O gate existente para 128×128 / 32 cores rejeita tamanho, paleta e alpha; resultado arquivado em `TECHNICAL_GATE.json`. A cópia de trabalho foi comparada ao arquivo gerado por hash.

O pedido desta rodada foi uma correção visual, explicitamente classificada como estudo no prompt. O gerador não entregou sprite nativo verificável. Não afirmar que o detalhe observado nessa imagem equivale a arte nativa de 52 px ou que já está pronto para animação, Godot ou Android. O contraste entre qualidade desejada e detalhe disponível na grade precisa ser resolvido em uma entrega nativa que preserve o desenho; não relaxar métricas silenciosamente nem alegar qualidade por contagem de cores.

O arquivo preserva detalhes da referência, incluindo adornos já existentes; nenhum novo aceite cultural/marketing/direitos é inferido. Revisão cultural específica, procedência/termos e QA continuam pendentes.

Próximos gates: Rodrigo avaliar a fidelidade desta correção; reconstrução nativa polida que mantenha a identidade e compare resultados reais no tamanho de jogo; só então travar modelo/paleta e criar clips. A medida antes aprovada de corpo52/frame128 continua no contrato; eventual mudança de resolução/escala deve ser apresentada e aprovada explicitamente. Nenhum arquivo foi promovido a `game/assets/`; nenhuma mudança de gameplay.
