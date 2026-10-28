# Rasta Quest — 21 salas horizontais (27/10/2026)

Status: proposta de blockout, sem edição de arte nem implementação na engine. Base visual: PR #84 e suas 21 pranchas já arquivadas. Este pacote não recria imagens.

## Regras

- Cada mapa ilustrado é uma síntese da sala; o gameplay deve ocupar de 5 a 8 larguras da câmera de jogo, sem esticar a arte original.
- Preservar a ordem de marcos, introduzir caminhada entre encontros e manter uma rota alternativa que reencontra a principal.
- A geometria exige módulos próprios de plataforma, chão, ponte, argola, escada, porta, esconderijo e arena. Colisão e telegráfos não vêm embutidos na prancha.
- Usar cinco conchas de cauri por sala, com IDs B1 a B5 e recompensa de uma vida ao completar os cinco; as conchas dos chefes ficam antes do bloqueio de arena.
- Inventário-base: 21 salas, 105 conchas, três salas de chefe (07 de cada mundo). A coleção permanente para skins é separada da recompensa de vidas por run. Evitar farm infinito; política exata de reentrada exige decisão de balanceamento.
- Recompensa temporária de portal, vida/mana, essência vermelha, materiais permanentes e skins não são o mesmo sistema.
- O jogo continua 2D inclusive no Santuário e nas lutas de chefes; estudo de 3D permanece posterior.
- O registro JSON contém posições aproximadas em larguras de câmera, NÃO coordenadas aprovadas no mundo Unity.

## Gates

| Etapa | Trabalho | Evidência para aceitar |
| --- | --- | --- |
| L0 | Inventário 21 imagens e 105 IDs | PNGs encontrados e sem alterações |
| L1 | Floresta 01 | 6 telas reais de percurso, câmera, combate, 5 búzios, desvio e saída |
| L2 | Kit modular reutilizável | Colisão separada, terrenos, plataformas, argolas, portais, baús e checkpoints |
| L3 | Floresta 02–07 | Boss 07 e travessia para Castelo, playtest mobile |
| L4 | Castelo 01–07 | Correntes, elevadores, armadilhas e boss 07 sem saltos cegos |
| L5 | Cavernas 01–07 | Fendas, pulsos, elites e chefe final com duas fases |
| L6 | Santuário, save e árvore v02 de 25 nós | Integração após 3 biomas, mantendo equipamento separado |
| L7 | Release e mobile QA | APK Unity, Galaxy A13, API36, 16KB, arte/cultura/licenças |

## Limites

Nenhuma cena Unity foi criada; sem build/editor, dados salvos alterados ou APK. O bloqueio #80 e a paridade #81 continuam. Este documento complementa BIOME_CONTINUATION_2026-10-24.md, não a substitui. Aprovações finais exigem medições do personagem, revisão de colisões, mobile e direitos culturais. Não integrar PR #82/#83/#84 ou main automaticamente.
