# Rasta Quest — protótipo web 2D

Prévia jogável no navegador para validar a sequência de 21 salas sem instalar Unity. O código usa apenas módulos JavaScript, Canvas e arquivos estáticos, sem `npm` ou serviços externos.

## Testar agora

Na raiz do repositório, execute:

```sh
node web/serve.mjs
```

Abra `http://127.0.0.1:4173/` no navegador. Se a porta estiver ocupada, execute `node web/serve.mjs 4174` e abra a porta correspondente. O jogo deve ser aberto pelo servidor local; abrir `index.html` diretamente como `file://` impede o carregamento do JSON em alguns navegadores.

Use **A/D** ou **setas** para mover, **W**, **seta para cima** ou **Espaço** para saltar, **J/K** para atacar e **E/Enter** para atravessar o portal aberto. Os botões na tela permitem jogar com toque. O botão **Recomeçar** reinicia a jornada.

## O que está jogável

- 21 salas sequenciais, sete por bioma, com largura de cinco a oito telas e câmera lateral;
- chão, blocos e plataformas altas com colisão, além de rota principal e acesso lateral a búzios elevados;
- inimigos patrulhando, ataque corpo a corpo, dano, vidas, respawn e checkpoint por sala;
- cinco búzios físicos por sala com os 105 IDs do plano; completar os cinco concede uma vida extra somente uma vez naquela sala e não reaparece ao morrer;
- entrada, saída condicionada ao combate, três salas com guardião e vitória ao concluir a sala final;
- HUD de vida, vidas, búzios, sala, rota e instruções para teclado e toque.

As posições de `web/data/rooms.json` espelham `docs/production/room_blockouts/ROOM_BLOCKOUTS_V1.json`, que continua sendo a fonte canônica. As coordenadas do plano eram estimativas em larguras de câmera. A geometria de colisão e os encontros deste protótipo foram criados para o teste web; não aprovam o layout final do Unity. `node web/verify.mjs` confirma a igualdade dos dados e a presença dos sprites. `node --test web/engine.test.mjs` cobre as regras principais.

## Arte e limites

Os 13 PNGs individuais em `web/assets/` vêm do catálogo `game/visual_review/catalog.json`; veja [ASSET_PROVENANCE.md](ASSET_PROVENANCE.md). São recursos provisórios de revisão, com aceite comercial, direitos e revisão cultural pendentes. As 21 pranchas de sala continuam preservadas como referência. Nenhuma foi usada como fundo pronto; os nove estudos de parallax também não foram repetidos como tiles. O cenário jogável usa formas e colisões próprias, com tiles individuais de revisão no topo das plataformas.

Esta versão web é um protótipo de jogabilidade e **não equivale a uma compilação Unity** nem substitui `game/` (Godot) ou `unity/`.

## Preview estático

A pasta `web/` pode ser servida por qualquer hospedagem estática. Em Cloudflare Pages, uma configuração futura de **branch preview** pode apontar o diretório de saída para `web` e não precisa de comando de build. Esta tarefa não configurou nem publicou Pages porque não há integração/credencial Cloudflare disponível nesta sessão. Qualquer URL pública deve ser verificada após o deploy antes de ser divulgada. Publicação de produção e merge na `main` continuam sujeitos a aprovação.

## Próximos gates

Validar sensação dos controles e leitura das salas em desktop e celular; substituir o guardião provisório da floresta; ajustar colisão e arte final após revisão visual/cultural/direitos; executar testes nativos Unity quando houver ambiente apropriado. Os gates web não afirmam que esses gates nativos passaram.
