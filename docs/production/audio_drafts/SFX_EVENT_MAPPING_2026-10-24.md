# SFX específicos — cobertura e eventos

Pedido: diferenciar Akane e inimigos andando/correndo, salto, dano, morte, ataques comuns e especiais, armas e ambientes com água/goteiras. O usuário gostou dos pilotos; os 12 originais permanecem intactos.

## Estado verificável

**84 cues catalogados; 16 arquivos gerados e 68 aguardando geração.** Quatro novos MP3s: Akane andando em pedra, madeira e terra; correndo em pedra. [Arquivos e procedência](../../../assets/production_drafts/2026-10-24/sfx-specific-v01/README.md). O catálogo JSON distingue arquivos reais de pedidos bloqueados; pendências não possuem botão de reprodução na bancada.

O lote preparado inicialmente tinha 60 pedidos adicionais, estimados em 47 créditos a partir das cotações de 0,5 crédito/2s e 2 créditos/8s. Quatro pedidos de 4s concluíram. Corrida em madeira recebeu rejeição explícita de frequência; corrida em terra e movimento de cavaleiro receberam rejeição por créditos insuficientes, sem job. O envio foi encerrado. A alternativa Zim foi consultada somente para capacidade/saldo; não houve geração nela. Sem compra, recarga, assinatura ou cobrança externa autorizada adicional. A estimativa não é auditoria de faturamento.

Doze cues adicionais de maça, lança, raízes/garras, movimento da fera e reação do chefe foram especificados após a interrupção, sem envio. O total do catálogo não significa total de gravações prontas. Novos inimigos e armas futuros exigirão ampliar a cobertura.

## Identidade e ligação futura

| Ação/fonte | Cues | Momento e regra |
|---|---|---|
| Akane andando/correndo | `akane_walk_*`, `akane_run_*` | Contato do pé, com material sob o personagem e intensidade/intervalo da velocidade. Não tocar por frame nem durante salto. Sequências de 4s precisam de recorte antes do uso por contato. |
| Cavaleiro andando/correndo | `knight_walk`, `knight_run` | Contato pesado com armadura; diferente das botas de Akane. |
| Arqueiro/arcanista andando/correndo | `enemy_light_walk`, `enemy_light_run` | Passo leve com couro/tecido; referência compartilhada inicial, variações por inimigo ainda necessárias. |
| Fera andando/correndo | `beast_walk`, `beast_run` | Patas/garras; não usar bota humana. |
| Akane saltando/pousando | `jump_takeoff`, `land_soft` | Impulso confirmado e contato de pouso; evitar repetição enquanto no ar. |
| Akane ferido/derrotado | `akane_hurt`, `akane_death` | Dor curta só após dano aceito; morte uma vez na transição para derrotado. Guarda não toca dor. |
| Cavaleiro, arqueiro, arcanista, fera e chefe de raízes feridos/mortos | `knight_hurt/death`, `archer_hurt/death`, `arcanist_hurt/death`, `beast_hurt/death`, `root_boss_hurt/death` | Separar impacto da arma da reação vocal/orgânica do alvo. Não acumular dor e morte no mesmo golpe letal; priorizar morte. Vocalizações sem palavras, sem imitar pessoa real. |
| Machado de Akane | `axe_swing_light/heavy/up`, `axe_sweep_low`, `hit_flesh/armor` | Swing mesmo se errar; contato só após acerto confirmado e conforme superfície. |
| Especiais/defesa de Akane | `guard_break`, `ancestral_chain`, `thunder_charge/wave`, `storm_burst`, `shield_raise/hit/end`, `parry_perfect`, `projectile_rebate`, `dash` | Camadas e marcadores de apresentação separados das regras de dano; não duplicar o trovão se o combo já o contém. |
| Espada | `sword_swing`, `sword_hit_body`, `sword_hit_stone`, `guard_impact` | Voo, acerto em corpo, parede e guarda distintos. Armadura pode compartilhar contato metálico como proposta inicial. |
| Arco/flecha | `archer_release`, `arrow_flight`, `arrow_impact` | Soltar corda, passagem e impacto separados. Sem impacto se a flecha não tocar. |
| Machado inimigo | `enemy_axe_swing`, `hit_flesh/armor`, `guard_impact` | Swing mais pesado; contato selecionado por material. |
| Cajado/magia inimiga | `arcanist_charge`, `staff_projectile`, `staff_impact` | Preparação, disparo e contato distintos; magia hostil diferente do trovão de Akane. |
| Maça e lança | `mace_swing/impact`, `spear_thrust/impact` | Peso contundente da maça distinto de estocada estreita da lança. |
| Garras e raízes | `beast_claw/impact`, `root_whip/impact` | Movimento orgânico, contato separado; não usar som de espada para todos. |
| Biomas e água | `forest_ambience`, `castle_ambience`, `cave_ambience`, `cave_drips`, `waterfall_loop`, `forge_loop`, `portal_loop` | Base de local mais fontes pontuais. Goteiras irregulares, ecos de caverna, vento do castelo, folhas da floresta. Laços precisam de edição e inspeção; nenhum é garantido seamless. |

## Retomada e aceite

1. Gerar primeiro dor/morte de Akane e dos quatro inimigos, depois chefe, armas/flechas, salto e goteiras. Os IDs prioritários estão no JSON; não reenviar os quatro jobs concluídos.
2. Ouvir e selecionar cada gravação. Produzir variações de dor, passos e impactos frequentes; os alvos de variantes não indicam arquivos já entregues.
3. Recortar contatos, ajustar início/cauda, conferir clicks/clipping, alinhar volumes e editar loops sem emendas. Preservar os originais.
4. Limitar vozes simultâneas e priorizar avisos de ataque, impacto importante e morte. Evitar sobreposição de múltiplos gritos idênticos. Ambiente deve permitir ouvir o combate.
5. Na engine, sons acompanham eventos confirmados; áudio não decide dano. Medir no celular, com fones e alto-falante. Sinais visuais continuam disponíveis sem som.

Não houve alteração em gameplay, engine, save, mixagem de produção ou build Unity nesta expansão.

## Verificação desta expansão

Catálogo conferido: 84 IDs únicos, 16 caminhos reais com SHA-256 correspondente aos manifests e 68 pendências sem arquivo/hash fictício. Os quatro MP3s novos possuem frames MPEG válidos, 44.100 Hz e aproximadamente 4,075 s calculados a partir dos frames. Sintaxe do módulo da bancada e diff sem erros. No navegador, a busca por Akane mostrou os quatro novos arquivos; reprodução de corrida em pedra foi aceita. Ao habilitar pendências e buscar “sentindo dano”, apareceram seis especificações sem botão de reprodução. Isso verifica interface e existência de arquivos, não qualidade auditiva final.
