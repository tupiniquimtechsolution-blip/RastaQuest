# Akane Xangô — estudos de movimento 2D

Quatro pranchas novas, **12 estudos de movimento e 60 poses-chave ilustradas**. A aparência segue a prancha de Akane enviada pelo usuário, mantendo roupa, dreadlocks e machado duplo. O objetivo é orientar animações mais expressivas, com preparação, ação e recuperação distintas.

## Técnicas de combate

![Técnicas](poses-attacks.png)

Corte Ascendente, Varredura Baixa e Quebra de Guarda: três silhuetas e trajetórias distintas. Quebra de Guarda é proposta condicionada às regras futuras; a prancha não torna todo escudo ou chefe automaticamente vulnerável.

## Defesas e respostas

![Defesas](poses-defenses.png)

Defesa Precisa contra golpe de cavaleiro, Rebatida Precisa contra projétil refletível e Escudo do Trovão como defesa frontal. Nem todo projétil precisa ser refletível; dano de área e armadilhas não viram ataques aparáveis. A habilidade é permanente, a duração de um escudo ativo é finita e ainda precisa de regra.

## Mobilidade

![Mobilidade](poses-mobility.png)

Avanço Ágil, Salto Preciso e Esquiva de Investida. A esquiva usa distância na pista 2D, não desvio em profundidade; brilho de dash não comprova invulnerabilidade. O salto mostrado é um estudo de um ciclo; não remove o salto adicional já previsto nas fontes existentes nem aprova novas regras de salto.

## Trovão e sequências

![Trovão](poses-storm.png)

Onda do Trovão, Fúria da Tempestade e Sequência Ancestral. A sequência une cortes e finalização; o VFX deve apoiar a leitura do corpo, não esconder contato, mãos e recuperação.

## Como transformar em animação de jogo

Cada linha é lida K1 → K5: preparação, impulso, contato/ação, continuidade e recuperação. **Não são cinco frames finais de uma animação nem um atlas exportável.** Não recortar e reproduzir automaticamente essas miniaturas: escala, pivô, mãos, arma, transições e intervalos precisam de construção controlada. Detalhes de pegada e orientação da lâmina nas poses ilustradas ainda precisam de conferência no model sheet/rig definitivo.

1. Revisar silhuetas e trajetória da arma com o modelo aprovado.
2. Construir rig 2D ou quadros desenhados de forma consistente; separar corpo, machado, cabelo, tecido e efeitos.
3. Produzir quadros intermediários, contato de pés, pivôs e encaixes de mãos/arma; testar as duas direções e eventual espelhamento.
4. Montar animatics e definir ritmo, início/fim e transições para ataque, defesa, dano, morte, queda e pouso. Só então fixar duração/FPS.
5. Exportar e conferir quadros/rigs e VFX separados, com nomes de clips estáveis.
6. Integrar na engine e validar cancelamentos, leitura mobile, efeitos sonoros e desempenho.

[MOTION_CATALOG.json](MOTION_CATALOG.json) liga cada estudo à sua linha e às habilidades da v02. Alguns estudos podem ser reutilizados por mais de um nó; melhorias passivas não exigem movimento exclusivo. Custos, dano, cooldown e invulnerabilidade permanecem indefinidos.

As fontes C# de combate existentes têm preparação, fase ativa e recuperação e registram alvos atingidos. Marcadores de animação devem sincronizar apresentação/VFX/SFX, **não substituir a autoridade do combate nem criar hits duplicados**. Nenhum desses novos movimentos foi conectado ao runtime nesta entrega.

[Plano antes do Unity e áudio](../../../../docs/production/PREUNITY_VISUAL_AUDIO_PLAN_2026-10-24.md). Pranchas e prompts serão mantidos no GitHub; versões anteriores não foram sobrescritas. Não houve geração de áudio, build Unity, Play Mode, APK, merge ou release.
