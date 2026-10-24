# Continuação dos biomas — 24/10/2026

> Atualização posterior nesta mesma tarefa: o usuário anexou a prancha da sala 05 (Forja do Ferro Sagrado). A partir dela foram produzidas nove pranchas novas, em [biome-continuation-v01](../../assets/production_drafts/2026-10-24/biome-continuation-v01/README.md). As menções abaixo à ausência de imagens e à arte pendente registram o estado da investigação inicial e foram superadas por essa recuperação. As imagens novas são propostas visuais para revisão, não aprovação final ou implementação.

Estado: proposta de detalhamento de level design; não é prancha aprovada, implementação ou validação de runtime.

## Ponto de retomada e preservação

Fonte: solicitação direta do usuário nesta tarefa e conversa “Retomada do projeto RastaQuest” (6adc9836-f174-83e8-97c4-382b33f33ec9).
Preservar Floresta Corrompida 01–07 e Castelo Fraturado 01–05, informados pelo usuário como já desenhados. Não recriar uma prancha geral.
Este documento acrescenta somente Castelo 06–07 e Cavernas 01–07, nessa ordem.
Akane Xangô permanece protagonista conforme a instrução atual; nenhuma alteração de aparência.
A prancha é um mapa condensado de uma sala side-scrolling extensa, nunca uma arena quadrada como dimensão total da fase.
Árvore de habilidades no menu de pausa e avaliação de transições 2D/3D ficam para depois da conclusão dos três biomas.

## Evidência e limites

- PR #82: aberto, draft, sem merge; head f3e0cb0f91f8e41d5e6b089c1e6da230c9c227c2.
- PR #83: aberto, draft, sem merge; head 7190f760f130c510eab448cec846714243eb6297; base na branch do #82.
- Metadados consultados via GitHub nesta tarefa. Sucesso de CI citado nas descrições anteriores não foi revalidado aqui e não comprova compilação Unity ou release.
- Árvore recursiva do head #83 consultada sem truncamento. Não foram localizadas pranchas numeradas correspondentes ao chat. O read_thread retornou texto e marcadores de referência, sem anexos de imagem; sources/ está vazio nesta cópia.
- Existem estudos de ambiente e capturas de protótipo no disco. Não foram tratados como substitutos das pranchas aprovadas.
- Há alterações locais de Unity em andamento no checkout comercial. Nenhuma foi modificada ou incluída por esta continuação.
- GAME_CANON.md, seção 10, confirma floresta/castelo/cavernas. Sua exigência histórica de um chefe final não documenta ainda o contrato atual de um chefe por bioma. A instrução atual de sete salas e chefe na 7ª rege esta proposta; o cânone anterior permanece intacto.
- Comprimentos, nomes de salas novas, distribuição de encontros e padrões abaixo são propostas desta continuação. Não são decisões recuperadas do chat.

## Regras comuns das nove salas

1. Exatamente cinco búzios reais, como conchas reconhecíveis, por sala; cinco equivalem a uma vida. Não trocar por moedas, pontos ou cinco ícones sem objetos coletáveis.
2. As posições indicadas abaixo contam cinco objetos distintos. Búzio já coletado não reaparece por retorno à área para permitir vida infinita. Persistência, consumo e saldo entre salas ainda precisam ser conciliados com o sistema aprovado; este documento não inventa essas regras.
3. Cada bioma tem sete salas, com chefe na 7ª. Não renumerar ou alterar salas anteriores.
4. Extensão em “telas” significa largura útil da câmera jogável. É uma meta inicial para blockout, a calibrar com velocidade e câmera reais. Preservar sequência e distâncias entre marcos; não esticar sprites para ampliar o cenário.
5. Plataformas e desvios retornam à rota principal; saída à direita em regra, verticalidade localizada e sem exigir habilidades ainda indisponíveis.
6. Colecionáveis, equipamentos permanentes e buffs temporários de run recebem categorias e apresentação distintas. Não transformar um buff em desbloqueio permanente nem inventar novos equipamentos obrigatórios.
7. Arena de chefe é um trecho da sala extensa. Preparação, caminhada e resolução também ocupam espaço. Manter proposta em 2D nesta etapa.
8. Sinalização visual legível em celular, chão destacado do fundo e dano anunciado. Som complementa os sinais visuais.
9. As cinco conchas devem ser marcadas B1–B5 na documentação e contabilizadas individualmente na implementação. Nenhuma exige sofrer dano ou vencer o chefe para completar a vida antes da luta.

## CF-06 — Castelo Fraturado — sala 06: Galeria da Última Vigília

- Extensão inicial: 6 telas de largura, sujeita a blockout.
- Percurso condensado: Entrada da sala 05 → galeria longa → ponte fraturada → antecâmara → porta da sala 07.
- Continuidade visual: A arquitetura e os materiais devem ser amostrados da prancha aprovada da sala 05 quando recuperada; nenhuma nova identidade de castelo é aprovada aqui.
- Encontros: Cavaleiro isolado apresenta o trecho; arqueiro/mago ocupa patamar; charger atravessa ponte com área de recuo; último confronto combina dois arquétipos em piso amplo.
- B1–B5, nesta ordem: Nicho de entrada; desvio sob a galeria; patamar após o arqueiro; margem segura depois da ponte; antecâmara antes da porta.
- Travessia e segurança: A ponte tem pontos de espera e sinais visíveis antes de qualquer armadilha. Não exigir habilidade permanente ainda não obtida.
- Coleção e recompensa: Sem novo equipamento obrigatório. Colecionável de história em desvio que retorna à galeria; buff, se concedido pelo fluxo existente, termina com a run.

## CF-07 — Castelo Fraturado — sala 07: Câmara do Castelo Fraturado

- Extensão inicial: 5 telas de largura, sujeita a blockout.
- Percurso condensado: Vestíbulo seguro → aproximação longa ao trono → arena lateral ampla → corredor de saída → acesso às cavernas.
- Continuidade visual: Reutilizar linguagem visual das salas 01–05. Título e aparência do chefe dependem das decisões anteriores, ainda sem imagem recuperada.
- Encontros: Chefe do bioma na 7ª sala. Proposta de padrões: golpe frontal com preparação; investida com recuperação; fraturas de chão alternadas na segunda fase. Não inventar identidade religiosa ou substituir chefe previamente aprovado.
- B1–B5, nesta ordem: Vestíbulo; nicho anterior ao portão; plataforma baixa antes da arena; patamar junto à aproximação; pedestal anterior ao gatilho do chefe.
- Travessia e segurança: Os cinco búzios são acessíveis antes do bloqueio da arena. Todo ataque deixa uma zona segura alcançável com movimentos básicos. Sem dano obrigatório na transição.
- Coleção e recompensa: Recompensa pós-chefe usa o fluxo existente; nenhuma recompensa é declarada permanente sem regra explícita. A passagem só libera após a vitória.

## CE-01 — Cavernas dos Ecos — sala 01: Boca dos Ecos

- Extensão inicial: 6 telas de largura, sujeita a blockout.
- Percurso condensado: Saída do castelo → túnel de descida lateral → primeira câmara → passagem mineral → saída.
- Continuidade visual: Pedra escura, camadas de profundidade e luz mineral contida; orientação horizontal contínua. Paleta é proposta, não aprovação visual.
- Encontros: Chaser isolado, depois ranged em patamar baixo. Introduzir pulso elétrico ambiental isolado, anunciado antes de ativar.
- B1–B5, nesta ordem: Entrada; reentrância baixa; plataforma de observação; margem segura após o pulso; nicho antes da saída.
- Travessia e segurança: Trecho inicial sem combate para ler o ambiente. Pulso não combina com projétil no primeiro contato.
- Coleção e recompensa: Fragmento narrativo opcional; nenhuma habilidade nova exigida.

## CE-02 — Cavernas dos Ecos — sala 02: Galerias Ressonantes

- Extensão inicial: 7 telas de largura, sujeita a blockout.
- Percurso condensado: Túnel → corredor de cristais → desvio superior curto → reencontro da rota → saída.
- Continuidade visual: Repetir módulos da sala 01 e variar agrupamentos minerais; o mapa condensado mostra conexões, não comprime a distância jogável.
- Encontros: Ranged protege corredor; chaser ocupa trecho seguinte. Um controller introduz área temporariamente insegura em câmara ampla.
- B1–B5, nesta ordem: Recuo inicial; base dos cristais; patamar do desvio; retorno do desvio; plataforma depois do controller.
- Travessia e segurança: Área perigosa sinalizada por forma, animação e contraste, não apenas cor ou som. Desvio retorna sem salto de precisão obrigatório.
- Coleção e recompensa: Colecionável no desvio; eventual buff usa duração de run e apresentação distinta de equipamento.

## CE-03 — Cavernas dos Ecos — sala 03: Travessia das Fendas

- Extensão inicial: 7 telas de largura, sujeita a blockout.
- Percurso condensado: Margem inicial → sequência de pontes → ilha segura → túnel inferior → saída.
- Continuidade visual: Fendas elétricas em segundo plano e sob pontes; manter piso e inimigos legíveis.
- Encontros: Charger em pista comprida; ranged aparece após ilha de descanso. Não sobrepor primeira investida com ativação da ponte.
- B1–B5, nesta ordem: Margem inicial; nicho entre pontes; ilha central; recuo do túnel inferior; margem de saída.
- Travessia e segurança: Ciclos de fenda têm espera segura. Câmara acompanha a direção e mostra aterrissagem antes do salto.
- Coleção e recompensa: Exploração recompensa observação; não retirar equipamento permanente em queda ou morte.

## CE-04 — Cavernas dos Ecos — sala 04: Câmara das Correntes

- Extensão inicial: 8 telas de largura, sujeita a blockout.
- Percurso condensado: Túnel → câmara ampla de controle de área → corredor de respiro → patamares → saída.
- Continuidade visual: Veios minerais conduzem o olhar à saída; elementos suspensos não ocultam telegraphs.
- Encontros: Controller seguido de chaser; depois ranged em segundo confronto. Controle de área deve deixar corredor livre.
- B1–B5, nesta ordem: Nicho do túnel; borda anterior à câmara; plataforma lateral segura; corredor de respiro; patamar antes da saída.
- Travessia e segurança: Não permitir que duas áreas bloqueiem simultaneamente a largura transitável. Reposicionamento possível sem sofrer dano.
- Coleção e recompensa: Relato opcional sobre instabilidade dimensional. Nenhuma nova árvore de habilidades nesta etapa.

## CE-05 — Cavernas dos Ecos — sala 05: Núcleo Instável

- Extensão inicial: 8 telas de largura, sujeita a blockout.
- Percurso condensado: Entrada → máquinas/rocha fraturada → câmara de combate → desvio de observação → saída.
- Continuidade visual: Aumentar intensidade da instabilidade sem cobrir colisões ou criar nova direção artística.
- Encontros: Combinação de controller e ranged; charger em encontro separado. Elite usa arquétipo já existente, sem exigir nova IA.
- B1–B5, nesta ordem: Entrada; abrigo antes do núcleo; patamar da câmara; desvio de observação; margem após último confronto.
- Travessia e segurança: Pulso ambiental e ataque de elite não podem fechar todas as rotas. Intervalo visível para cruzar o núcleo.
- Coleção e recompensa: Recompensa de run, se prevista no sistema existente; equipamentos e coleção persistente mantêm indicação separada.

## CE-06 — Cavernas dos Ecos — sala 06: Limiar do Último Eco

- Extensão inicial: 8 telas de largura, sujeita a blockout.
- Percurso condensado: Galeria longa → dois encontros espaçados → passagem calma → antecâmara final → porta.
- Continuidade visual: Recombinar módulos anteriores e anunciar o destino à distância; preservar sensação de caminhada até o chefe.
- Encontros: Primeiro encontro: chaser + ranged. Segundo: controller + charger, em área ampla. Sem introduzir nova mecânica na véspera do chefe.
- B1–B5, nesta ordem: Recuo de entrada; patamar após encontro 1; passagem lateral entre encontros; abrigo após encontro 2; antecâmara.
- Travessia e segurança: Respiro antes do portão. Nenhum búzio fica atrás de passagem de sentido único que o jogador não possa antecipar.
- Coleção e recompensa: Colecionável opcional na passagem lateral; buff temporário não substitui recompensa permanente.

## CE-07 — Cavernas dos Ecos — sala 07: Arena do Último Eco

- Extensão inicial: 6 telas de largura, sujeita a blockout.
- Percurso condensado: Antecâmara → caminhada de aproximação → arena horizontal final → área de resolução da run.
- Continuidade visual: A identidade final e o nome do chefe precisam ser conciliados com o cânone e aprovações anteriores. Não declarar O Abominável ou Rift Sovereign como escolha nova definitiva.
- Encontros: Chefe final na 7ª sala; proposta: golpe de proximidade, faixa elétrica anunciada e erupções alternadas. Segunda fase combina padrões já apresentados, com janelas de punição.
- B1–B5, nesta ordem: Entrada da antecâmara; nicho lateral; patamar de aproximação; margem inferior segura; pedestal antes do gatilho da arena.
- Travessia e segurança: Cinco búzios disponíveis antes da luta. Limites visíveis; sem projéteis fora da câmera ou dano inevitável; vitória encerra a run pelo fluxo existente.
- Coleção e recompensa: Resultado da run distingue coleção/equipamento persistente dos buffs encerrados. Sem migração de save ou implementação presumida.

## Critérios de revisão e sequência de produção

- Recuperar as pranchas do chat, em especial Castelo 05 e uma prancha com legenda completa, antes de gerar arte que alegue continuidade exata.
- Conferir nomes, chefe e conexões com o material recuperado; ajustar apenas as salas novas se houver conflito.
- Produzir primeiro Castelo 06 e depois 07; em seguida Cavernas 01 a 07, sem prancha de recomeço e sem redesenho da floresta.
- Cada nova prancha deve mostrar entrada, saída, caminho principal, desvios, cinco conchas, encontros, armadilhas e régua de extensão jogável; conservar a legenda e estética das referências.
- Este documento não autoriza dizer que os três biomas estão visualmente concluídos. Arte: pendente das referências; blockout e runtime: não executados.
- Verificação desta entrega: nove salas novas, IDs únicos e ordem CF-06, CF-07, CE-01…CE-07; cinco posições de búzios por sala; chefe em CF-07/CE-07; nenhum arquivo anterior alterado.
- Não houve build, instalação, Play Mode, APK, merge ou release. Não há dependência nova.
- Referências: [PR #82](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/82), [PR #83](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/83), [cânone no head auditado](https://github.com/tupiniquimtechsolution-blip/RastaQuest/blob/7190f760f130c510eab448cec846714243eb6297/docs/product/GAME_CANON.md).
