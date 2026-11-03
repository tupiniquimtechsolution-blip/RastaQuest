# Rasta Quest — Web delivery checkpoint (03/11/2026)

Status: **PREVIEW / NO-GO comercial**. Fonte factual: PRs e Actions. Este arquivo
não declara publicação HTTPS, build Unity/Android/Windows, licença de arte,
aprovação cultural ou teste humano em dispositivo físico.

## Continuidade desde 30/10

- [#93](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/93):
  105 búzios únicos e perfil local, essência vermelha, upgrades, pausa, PWA e
  pacote de revisão. CI aprovado.
- [#95](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/95):
  snapshot e retomada de run com checkpoint seguro.
- [#96](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/96):
  especiais de mana, baús, três equipamentos raros e marcos da sala.
- [#97](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/97):
  HTML completo offline sem npm/Unity.
- [#98](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/98):
  árvore v02 de 25 nós, somente leitura, sem balanceamento inventado.
- [#99](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/99):
  exportação/importação manual e segura de perfil JSON.
- [#100](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/100):
  teste Chrome inicial; o gate dessa HEAD falhou por captura DOM imprecisa.
- [#101](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/101):
  teste CDP real no HTTP/HTML offline e mobile landscape touch.
  [Web CI aprovado](https://github.com/tupiniquimtechsolution-blip/RastaQuest/actions/runs/41696950090).
- [#102](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/102):
  cauri vetorial mais reconhecível, screenshots de QA e isolamento do teste
  móvel para exigir 0/5 → 1/5. [Web CI aprovado](https://github.com/tupiniquimtechsolution-blip/RastaQuest/actions/runs/41698215272).
- [#103](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/103):
  regression test **somente input normal** da campanha 21 salas / três chefes /
  105 conchas, em perfil de QA com atributos maximizados (não prova balanceamento
  de iniciante). [Web CI aprovado](https://github.com/tupiniquimtechsolution-blip/RastaQuest/actions/runs/41698953175).
- [#104](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/104):
  slot de skin de Akane e do machado, seleção no menu de pausa, persistência e
  alternativas gráficas provisórias. Conferir CI mais recente para resultado.

**Nota de integração:** #94 é experimento paralelo de baús/mana/chefes sobre
#93; #95→#96→#97... é cadeia posterior com interseção de funcionalidades.
Não mesclar #94 às cegas nem presumir ausência de conflitos. A cadeia acumulada
continua **draft e fora da main**. PRs anteriores #82→#83→#84→#87→#89 são
dependências do protótipo.

## Como testar sem Unity

1. Na branch mais nova, execute `node web/serve.mjs` e visite
   `http://127.0.0.1:4173/` no navegador desktop, **ou**
   execute `node web/build-standalone.mjs` e abra
   `web/dist/rasta-quest-offline.html` no Chrome/Edge desktop.
2. No GitHub Actions, o workflow **Web Preview** publica o artefato ZIP
   `rasta-quest-web-preview` com arquivos web, HTML offline, JSON de resultado
   de Chrome e screenshots desktop/mobile. O artefato é temporário (retenção 14d).
3. Em celular, preferir URL HTTPS e PWA após conectar conta de hospedagem.
   Abrir HTML `file://` em Android varia por navegador/gerenciador.

## Confirmado versus pendente

| Critério | Evidência | Limite |
|---|---|---|
| JS sem build/npm, sprites, rooms | GitHub Actions | Arte ainda provisória |
| 21 salas, 105 IDs, combate, coleta | testes + automação no PR #103 | Bot fortalecido ≠ teste humano |
| Chrome desktop e arquivo offline | teste CDP #101 | Não prova outros browsers |
| Controles mobile landscape | emulação CDP #102 | Não prova telefone físico |
| Screenshots QA | artefato Web Preview | Não aprovam qualidade final |
| Búzios cauri, skins | regra de profile + PR #104 | Visual das skins é provisório |
| PWA instalável offline | manifesto/service worker | Sem URL HTTPS pública validada |
| Unity/Android AAB/Windows nativo | não testado | instalar e testar fisicamente |

## Gates que ainda exigem ação humana

1. [#90](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/90):
   autorizar/conectar provedor de hospedagem e confirmar URL HTTPS de preview.
   Não publicar em domínio de produção sem autorização.
2. [#91](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/91):
   playtest humano 21 salas/3 bosses em PC e dispositivo Android real, captura
   de performance, toque, legibilidade, câmera, crashes, áudio e persistência.
3. Aprovação artística/cultural e direitos antes de qualquer release.
4. [#80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80):
   Unity Editor e módulos nativos em ambiente autorizado; QA Android/Windows,
   assinaturas e loja.
5. Revisar a cadeia de PRs e obter autorização explícita antes de merge da main,
   exposição de produção, mudanças de save irreversíveis ou release.

**Ponto de retomada:** revisar HEADs e CI atuais; corrigir testes que falharem;
confirmar bundle via Actions; habilitar preview HTTPS quando a conexão de
hospedagem existir; executar QA humano/dispositivo e revisar conteúdo antes de
escolher a estratégia de integração com a main. Não recriar as 21 pranchas.
