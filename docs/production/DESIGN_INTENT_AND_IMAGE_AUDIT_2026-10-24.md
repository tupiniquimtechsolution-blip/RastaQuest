# Intenção preservada e auditoria das pranchas

## Esclarecimento do usuário

Em 24/10/2026 o usuário reapresentou a mensagem anterior à interrupção e pediu para desconsiderar seus trechos sobre o andamento dos biomas, preservando as demais ideias. Portanto, frases históricas como “já fez um”, “outro em andamento” e “concluir o terceiro” não determinam o estado atual. A solicitação não descarta os biomas, não rejeita as novas nove pranchas e não autoriza redesenhar as salas anteriores.

## Direção preservada

**Revisão de técnicas e animações:** por orientação posterior do usuário, cabo, lâmina, ponteira e melhoria do machado ficam no menu de equipamentos. A [árvore v02](../../assets/production_drafts/2026-10-24/skill-tree-v02/README.md) usa Técnicas de Combate, com golpes especiais e respostas. Os [estudos de movimento](../../assets/production_drafts/2026-10-24/combat-motion-v01/README.md) e o [plano antes do Unity/áudio](PREUNITY_VISUAL_AUDIO_PLAN_2026-10-24.md) detalham a próxima produção. Toda arte nova é arquivada no GitHub; versões anteriores permanecem preservadas. O README visual apresenta o acervo depois da publicação das artes.

**Direção atual, esclarecida pelo usuário após a recuperação do acervo:** elaborar agora a árvore de habilidades como prancha visual na mesma direção artística dos menus. Manter **todo o jogo em 2D por enquanto, inclusive chefes e Santuário Ancestral**. A avaliação de 3D está adiada; os itens históricos abaixo não autorizam trabalho 3D nesta etapa. O pacote visual da árvore fica em `assets/production_drafts/2026-10-24/skill-tree-v01/` e não implica implementação no runtime.

1. As pranchas são mapas condensados e esboços de salas side-scrolling extensas. Na implementação, manter aparências, locais e sequência dos marcos, criando distância percorrível entre eles para dar a sensação de viajar e chegar a um destino. Não transformar toda a sala em um quadrado ou uma única tela, nem ampliar a fase esticando sprites.
2. Preparar posteriormente o **layout completo da árvore de habilidades no menu de pausa**. Preservar essa intenção como próxima frente de design; este registro não inventa nós, preços, equipamentos ou progressão, nem declara a árvore implementada. Conciliar seus estados com o menu e as regras já aprovadas quando esse trabalho começar.
3. Avaliar futuramente trechos em 3D para **lutas de chefes** e para o **Santuário Ancestral**, mantendo campanha e sala de aproximação ao chefe em 2D side-scrolling. A transição de câmera é uma possibilidade a estudar, não uma decisão de converter o jogo inteiro ou implementar 3D agora.
4. Estudar o impacto dessa hipótese em câmera, movimentação, combate, arte, colisões, desempenho mobile, controles e custo de produção antes de adotá-la. A referência a Hades expressa a experiência desejada para o santuário, sem fixar uma solução técnica.
5. Preservar a futura opção de acessibilidade de **não trocar para 3D nas lutas de chefe**, mantendo uma alternativa 2D. O usuário situou esse trabalho para mais adiante, com o jogo já comercializado; não se torna requisito de implementação imediata nem evidência de release atual.

O foco imediato deste registro é conservar as ideias e conferir os arquivos. A fala antiga sobre a sequência dos biomas não sobrepõe a auditoria atual. Completude das pranchas, aprovação artística e implementação jogável são estados diferentes.

## Resultado da conferência

**Atualização após os reenvios do usuário: 21/21 pranchas de salas arquivadas na branch do PR #84. Não falta nenhuma das sete salas de cada um dos três biomas.** O levantamento inicial encontrou 10/21; os anexos seguintes recuperaram as 11 restantes. O JSON conserva esse levantamento em `initial_snapshot` e registra a recuperação em `recovery_update`.

| Bioma | Pranchas confirmadas no GitHub | Não localizadas | Na main |
|---|---|---|---|
| Floresta Corrompida | 7/7: 01–07 | nenhuma | 0/7 |
| Castelo Fraturado | 7/7: 01–07 | nenhuma | 0/7 |
| Cavernas dos Ecos | 7/7: 01–07 | nenhuma | 0/7 |
| Total | 21/21 | nenhuma | 0/21 |

As 10 inicialmente confirmadas estão em `assets/production_drafts/2026-10-24/biome-continuation-v01/`, na branch `design/biome-continuation-castle06-caves07-20261024`, commit inicialmente auditado `dbe7148b974c07a07673cde9fe3dc823bbe1a59a` ([PR #84](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/84)). São nove pranchas novas e a sala 05 original enviada pelo usuário. As 11 salas recuperadas estão em [recovered-chat-originals-v01](../../assets/production_drafts/2026-10-24/recovered-chat-originals-v01/README.md), junto de 13 outras artes de personagens, identidade, telas, menus, lore, coletáveis e santuário. Os 25 anexos recebidos correspondem a 24 novos arquivos e um reenvio idêntico do Castelo 05, sem duplicar essa sala.

A sala 05 também está em `art/chat-originals-archive-20261024`, caminho `assets/production_drafts/chat-history-2026-10-24/castelo-fraturado-sala-05-original.png`. As duas cópias têm o mesmo Git blob SHA `cec6a68a7884ea0969b41885addf90a78f79d3f6`; contam como uma prancha, não duas. O manifesto dessa branch declara recuperação incompleta e lista Floresta 01–07/Castelo 01–04 como inacessíveis.

## Escopo e evidências

- Listagem atual de branches obtida pela conexão GitHub: 50 branches, todas examinadas por seu SHA exato com `git ls-tree -rz`, usando os objetos locais correspondentes. A busca cobriu 1.614 caminhos de imagens, incluindo sprites e duplicatas históricas, sem confundi-los com pranchas de salas.
- Árvores recursivas do GitHub consultadas sem truncamento para `main`, a branch do PR #84, `art/chat-originals-archive-20261024` e `imagens-novas`.
- Arquivos de nomes genéricos nas branches antigas foram reconciliados por hash: são duplicatas das bíblias visuais de personagem/mundos, catálogo de inimigos e prancha de animação já presentes na main. Não preenchem salas ausentes.
- `main`: `dd12bb3d188686e5010395b690de9161949b8d7f`. PR #82: aberto/draft/sem merge, head `f3e0cb0f91f8e41d5e6b089c1e6da230c9c227c2`. PR #83: aberto/draft/sem merge, head `7190f760f130c510eab448cec846714243eb6297`. PR #84: aberto/draft/sem merge no momento da consulta.
- [Inventário estruturado](BIOME_IMAGE_AUDIT_2026-10-24.json): uma linha por sala, caminhos, blob SHAs e lista dos 50 heads examinados. O commit desta auditoria apenas adiciona documentação; não muda as imagens auditadas.
- As imagens do PR #84 tiveram decodificação PNG, dimensões e hashes conferidos na entrega anterior. Esta conferência reconcilia sua presença no Git, não repete aprovação artística, teste de câmera ou runtime.

Não foi feita busca de todos os commits históricos ou branches apagadas. “Não localizada” não significa “nunca foi gerada” ou “perdida definitivamente”. A conversa referenciada retornou anteriormente marcadores de conteúdo sem anexos binários; referências textuais não comprovam upload dos arquivos.

## Próximo passo

Recuperação acompanhada na [Issue #86](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/86). As 11 salas foram recuperadas; o encerramento depende da conferência da árvore publicada no GitHub.

Com o acervo de salas completo, preservar as artes originais como referência para montagem das fases e uso visual/promocional indicado pelo usuário. Revisar as inconsistências históricas de textos e contagem ilustrada na especificação de implementação, sem alterar os originais. Prosseguir depois com o layout da árvore de habilidades no menu de pausa, conservando a avaliação de 2D/3D como trabalho futuro.

Nenhuma imagem ou sala foi redesenhada. As cópias dos anexos foram verificadas byte a byte. As ideias preservadas continuam registradas. Não houve merge, build Unity, Play Mode, publicação de release ou mudança de gameplay.
