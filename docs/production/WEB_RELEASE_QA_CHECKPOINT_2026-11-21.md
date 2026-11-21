# Rasta Quest — checkpoint de QA web e distribuição (21/11/2026)

## Estado verificado e princípio de evidência

- `main` ainda aponta para `dd12bb3d188686e5010395b690de9161949b8d7f` (Godot); **não existe merge da cadeia web**.
- A cadeia web atual é #89 → #93 → #95 → #96 → #97 → #98 → #99 → #100 → #101 → #102 → #103 → #104 → #105; #94 é uma trilha paralela e **não deve ser mesclada cegamente**.
- A branch de QA e correção #105 depende de #104; os PRs anteriores por sua vez dependem do acervo #84 e blockouts #87.
- O jogo tem 21 salas de blockout, 7 por bioma, 105 cauris de colecionável (5 por sala), 3 confrontos finais técnicos, contador de vidas e status de campanha.
- O teste input-only de 21 salas do PR #103 valida transições sem teleporte ou manipulação da vida dos inimigos, mas **não é playtest humano**, medição de FPS ou revisão de design.
- PR #104 já adicionou seleção e aplicação visual provisória das skins. O design final, revisão cultural e direitos permanecem bloqueados.
- #105 corrige dois problemas materiais: o primeiro acesso PWA podia deixar sprites fora do cache (service worker ainda não controlava a página) e dano não fatal não obrigava atualização do salvamento da run.

## Caminho imediato para jogar sem Unity

**Desktop, offline e sem instalador:** baixar o artefato `rasta-quest-web-preview` do último workflow **Web Preview** aprovado no PR #105, extrair o ZIP e abrir `dist/rasta-quest-offline.html` no navegador. É um HTML autocontido — não depende de Node ou servidor local.

**Navegador via localhost:** clonar a branch exata e executar `node web/serve.mjs` na raiz, abrindo `http://127.0.0.1:4173/` (não é URL pública).

**Android e Windows instalável PWA:** requer URL HTTPS servindo a pasta `web/` e navegador compatível. O build não substitui um APK/AAB ou instalador nativo. A hospedagem de preview exige configuração de conta/domínio e aprovação. Sem evidência de URL pública ou teste físico, não marcar o gate como concluído.

## Gates automatizados

```sh
node web/verify.mjs
node --test web/*.test.mjs
node web/build-standalone.mjs
node web/browser-smoke.mjs
```

O GitHub Actions `.github/workflows/web-preview.yml` executa contratos específicos, geração de HTML standalone, smoke Chromium em HTTP e `file://`, viewport touch emulado e agora checagem de **fetch offline real** pelo Service Worker com rede desativada. O artefato ZIP é anexado ao run e tem retenção de 14 dias; para baixar no futuro deve-se usar um run novo.

Se o browser smoke falhar, investigar a causa — nunca substituir falha por `continue-on-error`, nem chamar de aprovado. Revalidar os dois workflows de QA no SHA exato do PR antes de relatar status.

## Matriz factual

| Destino | O que pode ser testado | O que não está homologado |
| --- | --- | --- |
| Chrome/Chromium desktop automatizado | HTTP, single-file offline, teclado, primeiro búzio, UI, controles de toque emulados, 21 salas input-only e SW offline | Jogo equilibrado, acessibilidade completa, outros navegadores |
| Windows desktop real | HTML offline ou HTTPS/PWA após distribuição/servidor | App nativo assinado, máquinas-alvo, GPU/driver/FPS reais |
| Android real | HTTPS/PWA após deploy, ou tentativa de arquivo HTML local conforme browser | APK/AAB Unity, Galaxy A13, gesto multi-toque real, estabilidade física |
| Unity/Godot | Referências/código preservados; Unity alvo de migração | Import, compilação Play Mode, dispositivos, loja |
| Comercial | Documentação prévia e QA parcial | Arte final, licenças, cultura, qualidade, políticas, builds nativas; **NO-GO** |

## Próximo checkpoint

1. Verificar que todos os checks do PR #105 estão verdes no seu último HEAD e que artefato existe.
2. Caso não haja credencial de host ligada, **não inventar URL**; usar HTML offline para testes próprios e manter #90 aberto.
3. Testes em Android/Windows físicos, QA humano das 21 salas, performance, culturas/direitos e Unity só podem ser marcados depois de evidência verificável (issues #90/#91/#80/#81 etc.).
4. Manter árvore de PRs e `main` intactas até autorização e reconciliação segura das dependências.
