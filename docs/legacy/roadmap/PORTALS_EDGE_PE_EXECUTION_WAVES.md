# PORTAL'S EDGE: LAST STAND
## Ondas de Execução — Fichas Técnicas Completas (PE-000 a PE-016)

Cada ficha abaixo é autossuficiente: pode ser colada como issue, como prompt para o Codex, ou como item de backlog. Todas seguem o mesmo contrato (ver seção "Contrato de execução" no Documento Mestre v3.0).

Convenção de status ao reportar: `NOT_STARTED` → `IN_PROGRESS` → `REVIEW` → `ACCEPTED` ou `REJECTED` (com motivo).

---

## Restrição de custo zero (vale para todas as ondas abaixo)

Nenhuma ferramenta, engine, asset pago, plugin, certificado de assinatura de código, ou serviço de hospedagem/CI pago entra no projeto sem autorização explícita. O padrão é sempre gratuito/open-source/free-tier — isso não é preferência, é filtro obrigatório antes de qualquer escolha técnica.

Quando a melhor opção técnica for paga, a onda correspondente deve registrar isso como **decisão pendente de autorização**, nomeando a necessidade exata, a alternativa gratuita mais próxima e sua limitação, e o custo estimado da opção paga — nunca assumir a escolha paga por padrão.

Implicações já identificadas por onda:

| Onda | Ponto de custo potencial | Retificação |
|---|---|---|
| PE-000/PE-001 | CI/CD | GitHub Actions **free tier** apenas; monitorar limite de minutos gratuitos |
| PE-002 | Toolchain PS3 homebrew | Confirmado gratuito (comunidade, ex.: baseada em PSL1GHT) — **nenhum dev kit oficial Sony**, que é pago e não se aplica a homebrew |
| PE-003/PE-004 | Assets placeholder | Nunca usar assets pagos "temporariamente" — placeholders continuam sendo formas geométricas simples, como já definido |
| PE-008 (arte pesada) | Ferramentas de arte 2D | **LibreSprite** (fork livre do Aseprite) ou **Krita** em vez de Aseprite pago; **Blender** para qualquer 3D auxiliar |
| PE-008 (áudio) | Ferramentas de som/música | **Audacity** (edição), **LMMS** ou **Bosca Ceoil** (composição gratuita); efeitos via **freesound.org**, verificando licença de cada asset (CC0/CC-BY) |
| PE-015 | Polimento/VFX | Priorizar shaders e efeitos nativos do Godot antes de qualquer asset pago de loja |
| PE-016 | Distribuição | **itch.io** tem publicação gratuita; Steam cobra taxa de submissão (~US$100) — isso só entra em pauta na fase de distribuição, como decisão isolada e tardia, nunca como custo de desenvolvimento |

---

## PE-000 — Auditoria e Legado

**Objetivo:** preservar 100% do material de design original sem perder nada, e criar a estrutura de repositório vazia sobre a qual tudo será construído.

**Escopo permitido:** criação de diretórios, `docs/legacy/`, `README.md` de cada pasta.

**Não pode:** escrever qualquer código de gameplay ainda.

**Tarefas:**
1. Criar a árvore de diretórios completa (core, adapters, data, tools, tests, docs).
2. Mover todo o conteúdo do Planejamento 2.0 e documentos anteriores para `docs/legacy/`, com um índice (`docs/legacy/INDEX.md`) listando o que cada arquivo contém.
3. Criar `docs/adr/0001-arquitetura-core-agnostico.md` registrando a decisão de Core em C++ puro, separado de Godot/PS3.
4. Criar `docs/waves/` com um arquivo por onda (pode copiar as fichas deste documento).
5. Configurar CI mínimo (mesmo vazio, só validando que o repo builda).

**Entregáveis:**
- Repositório com árvore completa
- `docs/legacy/INDEX.md`
- ADR 0001

**Definition of Done:**
- [ ] Nenhum conteúdo de design foi perdido (checklist de comparação com os documentos originais)
- [ ] Estrutura de diretórios bate 100% com a seção 3 do Documento Mestre v3.0
- [ ] CI roda (mesmo que só faça "hello world" de build)

**Riscos:** nenhum técnico. Risco real é organizacional — pular esta etapa gera bagunça em todas as seguintes.

---

## PE-001 — Portable Core

**Objetivo:** construir o núcleo de gameplay em C++ puro, sem qualquer dependência de engine, com cobertura de testes.

**Escopo permitido:** `core/math/`, `core/entities/`, `core/stats/`, `core/rng/`, sistema de eventos básico.

**Não pode:** referenciar Godot, PS3 SDK, ou qualquer renderer/áudio real. Sem I/O de arquivo além do necessário para RNG seed.

**Tarefas:**
1. `core/math/`: Vector2, transformações, interpolação, easing básico.
2. `core/entities/`: `CombatEntity`, `Health`, `Stats`, `DamageReceiver`, `Hitbox`/`Hurtbox` (formas geométricas puras, sem renderização).
3. `core/rng/`: gerador determinístico seedável (essencial para o Run Simulator futuro — mesma seed = mesmo resultado, sempre).
4. `core/events/`: sistema de eventos simples (observer pattern) para `OnDeath`, `OnDamageTaken`, `OnStatusApplied`.
5. Testes unitários cobrindo: dano aplicado corretamente, morte disparando evento, RNG determinístico com mesma seed.

**Entregáveis:**
- Módulos compilando como biblioteca estática/dinâmica isolada
- Suite de testes com cobertura visível

**Definition of Done:**
- [ ] 100% dos módulos listados têm testes unitários passando
- [ ] Teste de arquitetura no CI: nenhum arquivo em `core/` contém `Node`, `Godot`, `libpad`, `SPU`, `RSX`
- [ ] Duas seeds RNG iguais produzem sequências idênticas (teste automatizado)

**Riscos:** baixo. É o módulo mais "engenharia pura" do projeto — o risco é subestimar o tempo de fazer certo aqui, já que erros nesta base se propagam para tudo depois.

---

## PE-002 — Prova Técnica PS3 (Gate Crítico)

**Objetivo:** responder, com evidência, se o alvo PS3 homebrew é viável antes de qualquer investimento em conteúdo.

**Escopo permitido:** `adapters/ps3/` isolado, prova de conceito mínima e descartável.

**Não pode:** depender do Core ainda estar completo — este teste pode (e deve) usar um triângulo colorido e um sprite placeholder, não o jogo real.

**Tarefas:**
1. Configurar toolchain homebrew PS3 escolhida (documentar qual, com link/versão, em ADR).
2. Gerar um PKG homebrew mínimo que instale em um console com CFW.
3. Renderizar um sprite estático na tela.
4. Ler input do DualShock 3 (ao menos 1 botão + analógico).
5. Tocar um som.
6. Mover o sprite com o analógico e detectar uma colisão simples com dano fake.
7. Medir FPS da cena mínima.

**Entregáveis:**
- PKG funcional testável em console real (ou emulador confiável, se disponível, mas console real é o teste de verdade)
- `docs/adr/0002-viabilidade-ps3.md` com veredito: **VIÁVEL** ou **PIVOTAR PARA STRETCH GOAL**

**Definition of Done (checklist binário — todos precisam passar):**
- [ ] PKG instala e roda
- [ ] Sprite renderiza
- [ ] Input responde
- [ ] Áudio toca
- [ ] Movimento funciona
- [ ] Colisão + dano fake funciona
- [ ] FPS medido e documentado

**Se qualquer item falhar de forma não resolvível em tempo razoável (definir limite, ex.: 3 semanas de tentativa):**
→ Documentar em ADR, mover PS3 para fase pós-lançamento PC, seguir para PE-003 sem culpa nem retrabalho (o Core continua 100% válido).

**Riscos:** este é o maior risco técnico do projeto inteiro. É por isso que ele vem antes de qualquer conteúdo — falhar aqui em 3 semanas é infinitamente melhor que descobrir na Onda 9 que PS3 nunca foi viável.

---

## PE-003 — Sandbox Godot (Arena Cinza)

**Objetivo:** provar que o combate é divertido antes de gastar qualquer arte real.

**Escopo permitido:** `adapters/godot/`, cena de teste sem cenário, capsulas/retângulos como placeholder visual.

**Não pode:** usar arte final, animações finais, ou qualquer conteúdo de dimensão específica.

**Tarefas:**
1. `GodotInput`, `GodotRenderer` mínimos implementando as interfaces `IInput`/`IRenderer` do Core.
2. Axel se move em 360° com velocidade constante (aceleração/desaceleração pequenas conforme seção 5 do Planejamento 2.0).
3. Dash funcional com i-frames.
4. Combo de ataque 1-2-3 com input buffering e janela de cancelamento.
5. Heavy attack com carga.
6. Um inimigo placeholder (cubo que persegue e bate) para ter algo para lutar.
7. Morte e respawn na arena.

**Entregáveis:**
- Cena jogável no editor Godot
- Vídeo curto do gameplay (para validação externa)

**Definition of Done:**
- [ ] Movimento, dash, combo e heavy funcionam sem bugs de cancelamento
- [ ] Ao menos 3 pessoas fora do time jogaram e descreveram o combate como "responsivo"/"divertido" (critério qualitativo, mas obrigatório — sem isso não seguimos)
- [ ] Nenhuma lógica de combate foi escrita dentro do Godot — tudo chama o Core

**Riscos:** risco de design, não técnico. Se o combate não for divertido aqui, com formas geométricas, arte não vai salvar depois. Esta é a onda mais importante para validar o "core loop".

---

## PE-004 — Primeiro Inimigo Completo (Exploder)

**Objetivo:** validar o pipeline completo de um inimigo: dado JSON → IA → combate → morte.

**Escopo permitido:** `core/ai/`, `data/enemies/enemy_exploder.json`, Enemy Director básico.

**Tarefas:**
1. Implementar `BehaviorTree` mínimo no Core (Selector, Condition, Action).
2. Criar comportamento `chaser_explode` conforme seção 8 do Documento Mestre v3.0.
3. Ler o inimigo inteiramente de `data/enemies/enemy_exploder.json` — nenhum stat hardcoded em C++.
4. Hitbox/hurtbox reais (não distância calculada).
5. Enemy Director básico: spawna 1 inimigo por vez a partir de um orçamento simples.

**Entregáveis:**
- Exploder funcional na arena da PE-003
- Schema JSON validado (`data/schema/enemy.schema.json`)

**Definition of Done:**
- [ ] Exploder persegue, ataca por contato, explode ao morrer, aplica dano em área
- [ ] Alterar `hp` ou `speed` no JSON muda o comportamento sem recompilar
- [ ] Nenhum stat do Exploder está hardcoded em C++

**Riscos:** baixo, mas é a onda que valida se o sistema data-driven realmente funciona na prática — trate como checkpoint de arquitetura, não só de conteúdo.

---

## PE-005 — Ranged, Runner, Poisoner

**Objetivo:** expandir o roster de inimigos reaproveitando a arquitetura da PE-004, provando que ela escala.

**Escopo permitido:** novos `ai_behavior` (`ranged_reposition`, `charger_stun_on_wall`, `poisoner_area`), novos JSONs em `data/enemies/`.

**Não pode:** duplicar código de IA — cada comportamento novo deve reusar nós de Behavior Tree já existentes sempre que possível.

**Tarefas:**
1. Atirador de Flechas: `ranged_reposition` — mantém distância, recua ao ser aproximado.
2. Corredor Selvagem: `charger_stun_on_wall` — dash contra o jogador, atordoa a si mesmo ao colidir com parede.
3. Poisoner: aplica status de veneno em área.
4. Ajustar o Enemy Director para orçamento com múltiplos tipos simultâneos (seção 8.1 do Documento Mestre — teto de burst simultâneo).

**Entregáveis:**
- 3 novos inimigos jogáveis na arena
- Enemy Director gerando combinações (ex.: 2 archers + 1 runner)

**Definition of Done:**
- [ ] Cada inimigo tem comportamento distinto e reconhecível
- [ ] Nenhum novo nó de Behavior Tree duplica lógica já existente
- [ ] Teto de burst simultâneo testado (nenhuma combinação gera dano "injusto" em teste automatizado simples)

**Riscos:** balanceamento é subjetivo nesta fase — não travar aqui buscando perfeição, o Balance Simulator (PE-007+) vai refinar isso com dados.

---

## PE-006 — Sistema de Upgrades e Sinergias

**Objetivo:** implementar o sistema de Afinidades Dimensionais (equivalente aos boons) com detecção real de sinergias.

**Escopo permitido:** `core/affinities/`, `core/upgrades/`, `data/affinities/`, `data/upgrades/`.

**Tarefas:**
1. Estrutura de fragmento (seção 7.4 do Documento Mestre): família, slot, raridade, efeito.
2. `SynergyEngine`: a cada fragmento coletado, recalcula quais regras de `data/affinities/synergies/*.json` estão satisfeitas.
3. Tela/fluxo de escolha de 3 opções ao fim de sala.
4. Sistema de raridade: Common, Uncommon, Rare, Epic, Corrupted, Legendary, Synergy.
5. Aplicar efeitos reais no combate (ex.: Attack → Burn precisa realmente aplicar status de queimadura via `StatusController`).

**Entregáveis:**
- Ao menos 15 fragmentos base e 5 regras de sinergia funcionais
- Fluxo de escolha completo e testável

**Definition of Done:**
- [ ] `SynergyEngine` detecta corretamente ao menos 5 sinergias diferentes em testes automatizados
- [ ] Efeitos de fragmentos alteram o combate de forma observável (não são só números decorativos)
- [ ] Adicionar um novo fragmento via JSON não exige mudança em C++ (exceto para efeitos genuinamente novos, que exigem novo `EffectHandler`)

**Riscos:** este é o sistema mais combinatório do jogo. Risco de explosão de complexidade — manter `EffectHandler` como uma lista finita e reaproveitável (burn, poison, stun, chain, teleport, shield, duplicate...) em vez de um efeito único por fragmento.

---

## PE-007 — Run Engine

**Objetivo:** implementar geração procedural controlada de runs completas.

**Escopo permitido:** `core/procedural/`, `core/rooms/`, `tools/run_simulator/`.

**Tarefas:**
1. `RoomGraphBuilder` conforme seção 9 do Documento Mestre: seleciona subconjunto de salas, garante grafo conexo, distribui tipos por profundidade.
2. Regras de validação: sem elite nas 2 primeiras salas, healing garantida antes de miniboss, etc.
3. `EncounterAssigner` ligando Enemy Director a cada sala do grafo.
4. `RewardAssigner` considerando profundidade e afinidades já coletadas.
5. Transições entre salas (visual/lógica) e sistema de portas.
6. `Run Simulator`: roda N seeds automaticamente e reporta grafos inválidos, se houver.

**Entregáveis:**
- Run completa jogável do início ao fim (mesmo em arena cinza) com múltiplas salas
- Relatório do Run Simulator para 1000 seeds

**Definition of Done:**
- [ ] Run Simulator roda 1000 seeds sem crash e sem grafo desconexo
- [ ] Todas as regras de distribuição (seção 9) são respeitadas em 100% das seeds testadas
- [ ] Uma run manual do início ao fim é completável sem bugs de transição

**Riscos:** bugs de grafo desconexo ou salas inacessíveis são fáceis de passar despercebidos manualmente — por isso o Run Simulator existe: teste em escala antes de teste humano.

---

## PE-008 — Vertical Slice (Refúgio + Ruínas Esquecidas)

**Objetivo:** primeira versão do jogo genuinamente jogável do início ao fim, com arte real.

**Escopo permitido:** todo o conteúdo listado abaixo, arte pesada liberada pela primeira vez.

**Tarefas:**
1. Refúgio funcional: NPCs (ao menos Dr. Felix e mais um), escolha de arma/equipamento, seleção de portal.
2. Dimensão Ruínas Esquecidas: 10–15 salas com as 6 camadas de ambiente (gameplay, foreground, midground, architecture, background, atmosphere/lighting/particles conforme seção 17 do Planejamento 2.0).
3. 4 inimigos (Exploder, Archer, Runner, Poisoner) totalmente integrados.
4. 1 modificador Elite aplicado a pelo menos um inimigo.
5. Boss: O Abominável, com as 3 fases descritas no Planejamento 2.0 §26.
6. 20–30 fragmentos/upgrades funcionais.
7. 3 armas completas (Marreta, Espada, Machado, por exemplo) com combos próprios.
8. Fluxo de morte → Refúgio → reação de NPC → nova run.

**Entregáveis:**
- Build jogável do início ao fim em PC
- Vídeo de gameplay completo de uma run

**Definition of Done:**
- [ ] Um jogador consegue completar uma run do Refúgio até derrotar (ou morrer para) o Abominável sem bugs bloqueantes
- [ ] As 6 camadas de ambiente estão presentes em pelo menos 80% das salas
- [ ] Telemetria básica (seção 12 do Documento Mestre) já está registrando eventos de morte e upgrades escolhidos

**Riscos:** onda de maior volume de trabalho de arte. Reusar pipeline entre salas é essencial para não estourar cronograma — nenhuma sala deve exigir "sistema novo", só conteúdo novo dentro do sistema já validado nas ondas anteriores.

---

## PE-009 — PS3 Vertical Slice

**Objetivo:** rodar o mesmo conteúdo da PE-008 no console real.

**Pré-requisito:** PE-002 deve ter tido veredito VIÁVEL. Se PIVOTAR, esta onda é adiada para depois do lançamento PC e o roadmap segue direto para PE-010.

**Escopo permitido:** `adapters/ps3/`, ajustes de performance (redução de partículas, resolução, shaders — nunca de gameplay).

**Tarefas:**
1. Portar renderização das 6 camadas de ambiente para o adapter PS3, com reduções conforme seção 38 do Planejamento 2.0.
2. Validar DualShock 3 com o mapeamento completo da tabela do Planejamento 2.0 §6.
3. Medir FPS em combate normal (meta: 60 FPS; fallback documentado: 30 FPS).
4. Gerar PKG final assinado para teste em console.

**Entregáveis:**
- Build PS3 jogável do início ao fim
- Relatório de performance (FPS médio/mínimo por dimensão)

**Definition of Done:**
- [ ] Vertical Slice completo roda no console sem crash
- [ ] 60 FPS em combate normal, ou fallback de 30 FPS explicitamente documentado e justificado
- [ ] Nenhuma regra de gameplay diverge entre PC e PS3 (mesmo Core, apenas renderização/performance diferem)

**Riscos:** performance é o risco central aqui — se 60 FPS não for atingível, decidir e documentar o fallback cedo, não deixar como "resolver depois".

---

## PE-010 — Dimensão: Floresta Corrompida

**Objetivo:** segunda dimensão jogável, provando que o pipeline de conteúdo (não só o de engenharia) escala.

**Tarefas:**
1. Tileset e camadas de ambiente próprios (árvores gigantes, raízes, fungos, névoa, bioluminescência).
2. Mecânica de raízes dinâmicas: bloqueiam, atacam, abrem atalhos (Planejamento 2.0 §19).
3. Família de inimigos própria da dimensão.
4. Boss: A Raiz-Mãe (controle de arena e raízes).
5. Hazards ambientais próprios.
6. Trilha sonora em camadas (seção 37 do Planejamento 2.0).

**Definition of Done:**
- [ ] Dimensão completável do início ao boss
- [ ] Mecânica de raízes dinâmicas funcional e testada
- [ ] Nenhum sistema novo de engenharia foi necessário — só conteúdo sobre o pipeline existente

**Riscos:** se esta onda exigir mudanças estruturais no Core, é sinal de que a arquitetura da PE-008 não generalizou bem — tratar como bandeira vermelha e revisar antes de seguir para PE-011.

---

## PE-011 — Dimensão: Cidade dos Autômatos

**Tarefas:**
1. Ambiente industrial (fábricas, linhas de montagem, data centers).
2. Hazards mecânicos: lasers, esteiras, portas automáticas, drones, torres, campos elétricos.
3. Família de inimigos própria (tecnológica).
4. Boss: Unidade ZERO (laser, drones, missiles, arena lockdown).

**Definition of Done:**
- [ ] Dimensão completável do início ao boss
- [ ] Hazards mecânicos interagem corretamente com o `DamageReceiver`/`StatusController` existentes

**Riscos:** hazards ambientais complexos (esteiras, portas automáticas) podem tentar reinventar física — mantenha-os como triggers simples sobre o sistema de colisão já existente.

---

## PE-012 — Dimensão: Deserto dos Ecos

**Tarefas:**
1. Ambiente monumental (dunas, ruínas enterradas, esqueletos gigantes).
2. Mecânica de tempestades temporárias alterando a arena (Planejamento 2.0 §21).
3. Família de inimigos própria.
4. Boss: O Eco (imita ataques de Axel — reaproveita o `ComboResolver` do próprio jogador, aplicado a uma IA).

**Definition of Done:**
- [ ] Dimensão completável do início ao boss
- [ ] Boss "O Eco" reutiliza dados de combo de Axel em vez de ter combos próprios hardcoded (valida reuso de sistema)

**Riscos:** o boss "O Eco" é o mais arriscado tecnicamente das 3 dimensões — se a IA não conseguir reusar o `ComboResolver` do jogador de forma limpa, simplificar para uma versão que "parece" imitar sem de fato compartilhar código, documentando a decisão.

---

## PE-013 — Meta Progression Completa

**Objetivo:** todos os NPCs do Refúgio com sistemas completos e narrativa reativa a variáveis de progresso.

**Tarefas:**
1. Implementar todas as variáveis narrativas da seção 33 do Planejamento 2.0 (`run_count`, `death_count`, `bosses_defeated`, etc.).
2. Sistema de condição de diálogo (`NPC_Dialogue_021` com `condition` — seção 33).
3. Todos os NPCs principais (Dr. Felix, Dentes de Ouro, Mara, Iris, Brick, Nox) com funções completas.
4. Árvore de progressão permanente com foco em novas opções, não só multiplicadores (seção 30 do Planejamento 2.0).
5. Missões/Registros/Contratos/Anomalias (seção 34).

**Definition of Done:**
- [ ] Ao menos 50 linhas de diálogo condicional funcionais e testadas
- [ ] Todos os 6 NPCs principais têm função jogável (não só placeholder visual)
- [ ] Progressão permanente desbloqueia conteúdo novo (arma, modelo, portal), não só números

**Riscos:** volume de conteúdo de escrita é alto — considerar o `dialogue_editor` (ferramenta interna) como pré-requisito real desta onda, não opcional.

---

## PE-014 — Final Game

**Tarefas:**
1. Boss final (a definir a partir da narrativa dos 3 atos, seção 32 do Planejamento 2.0).
2. Ending(s) — considerar variação baseada em `death_count`/`discoveries` acumulados.
3. New Game+ / Instabilidade Dimensional (modificadores de dificuldade, seção 49 do Planejamento 2.0).

**Definition of Done:**
- [ ] Jogo completável do Refúgio ao final e volta ao menu/New Game+
- [ ] Instabilidade Dimensional altera a run de forma mensurável (HP inimigo, velocidade, elites extras)

**Riscos:** ending com variação narrativa pode crescer sem limite — definir um teto explícito (ex.: 2-3 variações) antes de começar a escrever.

---

## PE-015 — Polimento

**Tarefas:**
1. VFX e SFX completos para todos os sistemas de combate (hit flash, hit pause, screen shake, partículas).
2. Feedback de rumble diferenciado por tipo de golpe (seção 36 do Planejamento 2.0).
3. Acessibilidade completa (seção 48): remapeamento, vibração on/off, screen shake slider, flash reduction, contraste, damage numbers, auto-aim, hold/toggle.
4. Otimização de performance em todas as plataformas.

**Definition of Done:**
- [ ] Checklist de acessibilidade 100% implementado e testável nas opções
- [ ] Nenhum combate "parece sem impacto" em teste de feedback externo

**Riscos:** polimento tende a virar poço sem fundo — definir escopo fechado antes de começar (lista finita de itens, não "melhorar até parecer bom").

---

## PE-016 — QA Multiplataforma

**Tarefas:**
1. Checklist de certificação interna para PC, Android/iOS, PS3.
2. Testes de save/load em todas as plataformas, incluindo migração de versão (seção 13 do Documento Mestre).
3. Testes de balanceamento final via Balance Simulator com dados reais de telemetria acumulada.
4. Playtest fechado.

**Definition of Done:**
- [ ] Checklist de certificação 100% completo em todas as plataformas-alvo
- [ ] Zero bugs bloqueantes conhecidos
- [ ] Relatório final do Balance Simulator sem armas/upgrades com taxa de escolha ou vitória anômala

**Riscos:** nenhum novo — esta é a onda de fechar o ciclo, não de abrir escopo novo.

---

## Resumo visual do caminho crítico

```
PE-000 → PE-001 → PE-002 (GATE PS3) ─┬─ VIÁVEL ──→ PE-003 → ... → PE-009 (PS3 slice) → PE-010...
                                       └─ PIVOTAR ─→ PE-003 → ... → PE-008 (sem PS3 slice) → PE-010...
                                                                                   (PS3 retomado como stretch goal pós-lançamento)
```

A decisão da PE-002 é o único ponto do roadmap que muda a forma do projeto inteiro — por isso ela vem tão cedo e tem checklist binário, não subjetivo.
