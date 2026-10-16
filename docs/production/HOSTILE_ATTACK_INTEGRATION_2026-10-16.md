# Ataques hostis reais — Issue #51 / Agenor #8

O framework existente calculava intenção e emitia avisos, mas não executava dano hostil nas cenas. O chefe final também não possuía Hurtbox para receber os golpes do jogador.

EnemyBase, StormWarden e RiftSovereign agora criam uma execução por ataque, com preparação, fase ativa, recuperação e cancelamento ao morrer/remover a fonte. Uma consulta física ao Hurtbox do jogador aplica o dano, respeitando Health/invulnerabilidade e um acerto por alvo/ataque. A Hurtbox do RiftSovereign usa a geometria corporal existente.

Perfis técnicos iniciais, sujeitos a balanceamento e teste humano:

| Papel/padrão | Execução |
|---|---|
| Chaser | golpe frontal de alcance limitado |
| Ranged | projétil420px/s, vida máxima1,8s, bloqueado por cenário |
| Charger | preparação e avanço650px/s durante0,35s; golpe frontal |
| Controller | área anunciada na posição capturada do alvo, alcance máximo300px |
| Exploder | explosão local e morte da fonte após a janela ativa |
| Storm/Rift slam | área local110px de raio |
| Chain/Portal burst | três projéteis em leque |
| Fracture storm | três áreas anunciadas ao redor da posição capturada do alvo |

O limite compartilhado por contêiner de encontro é quatro ataques simultâneos, dos quais até dois de alta ameaça. A reserva começa antes do aviso e só é liberada ao terminar/cancelar. Morte e remoção da fonte eliminam também projéteis/áreas pendentes, impedindo dano atrasado. Os números são parâmetros iniciais implementados, sem aceite de diversão/dificuldade.

Os contornos de preparação/ataque são geometria de depuração para validar o tempo real. Não são sprites finais nem corrigem a apresentação provisória do APK. Nenhum concept foi promovido ao runtime.

## Verificação

O teste hostile_attack_integration.gd instancia as cenas reais de jogador/inimigos/chefes: cinco arquétipos causam dano; esquiva evita golpe; projétil para em parede; morte durante preparação/voo cancela dano e libera reserva; o terceiro ataque de alta ameaça espera; cinco fases de chefe atingem o jogador; golpe do jogador atinge a Hurtbox final. Invulnerabilidade é exercida pelo componente existente e permanece nos testes de combate.

Os workflows Godot e Gold incluem o novo teste junto às regressões existentes. O ambiente local usa Godot portátil oficial4.5.1 com APPDATA isolado sob o workspace, sem testar contra saves pessoais. A importação local pode avisar sobre configuração Android/edição segura do editor; isso não deve ser contado como export Android ou teste físico. O export final continua sendo verificado no CI.

## Integração artística e próximos gates

A remoção ao morrer continua imediata após cancelar ataque e emitir a derrota. Quando clips de morte finais existirem, deverão ser exibidos por uma apresentação desacoplada, com colisão/dano desativados e duração limitada; a progressão não deve depender indefinidamente do fim da animação. Não inventar um clip ausente nem estender a janela de dano para encaixar uma animação.

Sprites, animações/telegraphs finais, áudio, balanceamento, sobreposição de ataques e leitura/controles/desempenho em Android permanecem nas tarefas Agenor #3–#6/#10–#12. Gold NO-GO.
