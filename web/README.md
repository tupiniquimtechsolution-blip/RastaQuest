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

## Progresso local e instalação em outros dispositivos (PR #93)

A partir desta branch, o protótipo registra **um perfil local versionado** no navegador:
descobertas de búzios únicos (até 105), essência vermelha de inimigos e melhorias
permanentes de vida, dano e corrida. O menu **Pausa / Equipar** (ou Escape) compra
melhorias. O álbum reconhece 105/105 e registra skins de Akane/machado como
desbloqueadas; **a aplicação gráfica das skins ainda não está implementada**.

O perfil é exclusivo do navegador, não sincroniza contas/dispositivos e pode sumir
se os dados do site forem apagados. A jornada/run corrente ainda reinicia ao
recarregar ou fechar a página. As vidas extras continuam limitadas a uma vez por
sala na run, e o álbum reconhece cada ID uma única vez entre runs.

O projeto inclui `manifest.webmanifest` e `sw.js`, permitindo uso offline
**depois de uma primeira visita completa via HTTPS/localhost**, desde que o
navegador permita armazenamento e service workers. Os sprites são guardados
conforme usados. O ícone SVG é provisório. Instalação como aplicativo pode variar
por navegador; **não é um APK, AAB ou executável Windows nativo**.

Para testar no Windows ou Android, abra uma URL HTTPS da preview no Edge/Chrome
e use o menu de instalação/adicionar à tela inicial, quando disponível.
O jogo requer orientação paisagem para melhor ergonomia. Ainda faltam testes
em aparelhos físicos, cobertura de navegadores e ícones PNG finais.

### Hospedar preview web de branch — ação manual necessária

A pasta estática de publicação é **`web/`**; não precisa de build ou npm.
No Cloudflare Pages ou host similar, conecte a branch aprovada, defina
diretório de saída `web`, e use um endereço **temporário de preview**.
Não há URL pública validada neste PR; a publicação requer credenciais,
configuração de domínio e aprovação para colocar a arte provisória online.
Não configure domínio de produção nem autorize pagamentos/publicação comercial.

Verificações:
```sh
node web/verify.mjs
node --test web/engine.test.mjs web/progression.test.mjs web/pwa.test.mjs
node --check web/main.mjs
node --check web/sw.js
```

**Próximos gates:** executar smoke real em navegador HTTPS, confirmar instalação
PWA no Android e no Windows, testar atualização/limpeza do cache, 21 salas e
bosses sem teleporte, conferir persistência e acessibilidade touch. Compilação
Unity/Android permanece em outra trilha de QA.

## Baús, equipamentos, especiais e marcos de cenário (branch após #95)

- **J** ataca normalmente; **K** usa um golpe elétrico de maior alcance e dano,
  gastando 1 unidade de mana (até 3 no protótipo). Controles de toque incluem ESPECIAL.
- **E** junto a um baú abre a recompensa uma vez na run. Baús comuns recuperam
  vida ou mana; baús raros exigem alcançar uma plataforma alta e registram
  equipamentos **permanentes** no perfil. A coleta do baú é restaurada pelo
  save da run; não pode ser aberta duas vezes após recarregar.
- O protótipo de equipamento oferece Cabo de Carvalho Consagrado (manejo),
  Metal da Lança de Ogum (dano) e Botas do Vento de Iansã (velocidade).
  As peças são **propostas de produção**, não ativos finais; requerem revisão
  narrativa, cultural, visual, balanceamento e aceite comercial.
- **Pausa / Equipar** lista as peças encontradas e permite equipar as disponíveis.
  Itens já desbloqueados ficam no perfil local do navegador e sobrevivem à
  morte/reinício da run.
- Os nomes dos **marcos já presentes no catálogo de salas** agora aparecem
  nas passagens horizontais; são sinalização temporária para evitar percursos
  genéricos. Não equivalem à geometria final das 21 pranchas aprovadas.
- O botão "Continuar jornada" usa o snapshot de run na mesma máquina, no
  checkpoint ou entrada segura da sala, com HP, mana, vidas, pickups e inimigos
  derrotados. Não é sincronização entre plataformas/contas. Recomeçar apaga
  somente o snapshot da run, não o progresso permanente.

A versão web continua experimental: os baús são representações técnicas,
sem efeitos de áudio/partículas finais. Não existe publicação HTTPS de preview,
homologação em aparelho, ou validação Unity nesta entrega.
