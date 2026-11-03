# Rasta Quest — pacote web de continuidade e gates de entrega (03/11/2026)

**Branch:** `feat/web-gameplay-systems-20261103` · **PR:** #94 (draft, empilhado sobre #93)  
**Escopo:** execução automatizável de gameplay e distribuição de uma **prévia de revisão**.  
**Release comercial:** NO-GO. **Não houve merge em main, hospedagem externa ou build nativo.**

## O que já se consegue testar sem Unity

O código web implementa 21 salas sequenciais, cinco cauris físicos por sala, cinco cauris = +1 vida uma única vez naquela sala por run, câmera lateral horizontal de 5–8 larguras, inimigos, combate, três chefes provisórios e portais independentes do machado.

Incrementos nesta branch:
- **21 baús raros** ligados a equipamentos de quatro tipos: lâmina, cabo, botas, amuleto. Baús comuns restauram vida ou mana; peças raras ficam no perfil entre jornadas e podem ser equipadas no menu de pausa.
- **Mana/especiais:** K ou botão ESPECIAL consome mana e amplia dano/alcance. Defesa com Q ou botão DEFESA exige desbloqueio na árvore e consome mana para absorver o golpe.
- **Argolas de travessia:** E/ENTRAR próximo à argola enquanto Akane está no ar concede impulso. Os marcos dos ambientes são derivados da estrutura já definida no JSON canônico.
- **Chefes em duas fases:** ataque com janela visual de preparação e golpe acelerado na segunda fase. Arte e equilíbrio de boss ainda são protótipo.
- **Bênçãos temporárias automáticas** após portais (dano, mana e movimento). Não persistem após uma nova run; peças e habilidades persistem.
- **Perfil e recuperação:** álbum de 105 IDs únicos, essência vermelha, quatro atributos, equipamentos, habilidades, desbloqueio lógico de skins; save separado da run, restaurado a partir do checkpoint/entrada com vida, mana, baús, inimigos e cauris do progresso. Sem login nem sincronização entre dispositivos.
- **Santuário Ancestral 2D caminhável:** após a morte, Akane pode visitar o Salão dos Ancestrais, Forja, Raízes do Trovão, Fonte e Portão de Retorno. É um hub inicial, não arte final.
- **Raízes do Trovão v02:** 25 nós em Vigor, Técnicas, Movimento, Defesa e Tempestade. Topologia/nomenclatura do `SKILL_TREE_DESIGN.json` original do acervo, com custos/efeitos **temporários para testes**, ainda sem aprovação de balanceamento.
- **PWA:** manifest, ícones PNG 192/512, cache de módulos, 13 sprites e dados da campanha para uso offline depois de HTTPS/localhost e primeiro carregamento bem-sucedido; simulação real de desktop/mobile em Chromium.

**Não presentes/pendentes:** visuais finais de skins (há somente desbloqueio lógico), combate e boss final de produção, diálogos/áudio mixado, arte final, implementação Unity compilada, APK/AAB assinado, aplicativo Windows nativo, sincronização cloud, loja/monetização, tradução completa, revisão cultural e comercial.

## Como executar

Na raiz da branch:

```sh
node web/serve.mjs
# no mesmo computador, abra http://127.0.0.1:4173/
```

Controles: A/D ou setas mover; W/Espaço saltar; J ataque; K especial de mana; Q defesa após habilidade; E abrir baús, usar argolas no ar, entrar em portais/estações; Esc pausa; botões de toque e gamepad nos navegadores compatíveis.

Clique **Pausa/Equipar** para atributos/equipamentos e **Raízes do Trovão** para as 25 habilidades. Quando a jornada termina, pode voltar ao Santuário e interagir com as estações. Continuar após recarregar restaura o último snapshot (posição segura de checkpoint ou entrada, não frame exato). `Nova jornada` reseta apenas a run, não o álbum/equipamentos/habilidades.

## Gates automatizados

```sh
node web/verify.mjs
node --test web/engine.test.mjs web/progression.test.mjs web/pwa.test.mjs web/gameplay.test.mjs web/run-save.test.mjs web/skills-sanctuary.test.mjs web/campaign-autoplay.test.mjs
node web/browser-smoke.mjs  # requer Chrome ou Chromium instalado
```

Workflow `Web Preview` executa os testes e gera o artefato `rasta-quest-web-preview`, com as capturas `test-results/desktop-first-cowrie.png` e `test-results/mobile-controls.png` quando o smoke conclui. Pacote e logs devem ser verificados no **commit HEAD**, não em run antiga. Os testes automatizados verificam contratos, mas não substituem playtest humano, medição de FPS, verificação de direitos ou execução em Galaxy A13.

## GATES AINDA ABERTOS

1. **Preview HTTPS de branch (issue #90):** conectar hospedagem autorizada, diretório `web/`, sem build npm; confirmar URL com 200 em HTML, JSON, módulos, sprites e manifesto; smoke pela URL; não publicar em domínio de produção sem aprovação.
2. **QA completo (issue #91):** percurso das 21 salas em navegador/Android real e Windows, cinco cauris em cada, baús, save de run, 3 bosses, santuário, skill tree, toque, orientação paisagem, controle, travamentos, FPS e acessibilidade.
3. **Qualidade artística/cultural:** sprites definitivos, variedade real de inimigos, áudio, fontes e iconografia; revisão cultural especializada e verificação de licenças.
4. **Nativo:** Unity Editor e Android Build Support, build no Galaxy A13, Windows x64, requisitos de loja e segurança. CI de JavaScript não atesta compile C# nem Google Play readiness.
5. **Release:** só após evidência técnica, revisão humana das artes/cultura e aprovação explícita do proprietário.

## Governança e linha única

`main` (Godot) → PR #82 → #83 → #84 → #87 → #89 → #93 → #94. PR #85 é arquivamento parcial paralelo; não mesclar em cadeia sem auditoria de duplicação. Esta etapa não altera as 21 pranchas aprovadas, não usa imagens panorâmicas como sprites de runtime nem substitui Unity.

**Evidência ao concluir tarefa:** PR com SHA, check verde, artefato de teste, limitações e próximo gate. Nunca declarar uma entrega de loja ou funcionamento perfeito em aparelhos não testados.
