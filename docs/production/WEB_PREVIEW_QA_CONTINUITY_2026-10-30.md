# Rasta Quest — auditoria diferencial e roteiro de QA web
Data: 2026-10-30 | Checkpoint: RQ-CONTINUITY-2026-10-30 | Base técnica: PR #89, `64cb0a051ba1ee1e4e7bd5f51deda712040fffc2`

## Evidência revalidada no GitHub
- `main`: `dd12bb3d188686e5010395b690de9161949b8d7f`, sem delta ante o checkpoint.
- PRs #82 (`232867c`), #83 (`7190f76`), #84 (`6709ce3`), #85 (`91f850b`), #87 (`de62283`) e #89 (`64cb0a0`): abertos, draft, não mesclados; HEADs inalterados.
- Issues #88, #90, #91: abertas.
- CI do SHA #89: Web Preview run [40678097603](https://github.com/tupiniquimtechsolution-blip/RastaQuest/actions/runs/40678097603) **success**; Repository Health run [40678097608](https://github.com/tupiniquimtechsolution-blip/RastaQuest/actions/runs/40678097608) **success**. São CI de fonte/regras, não compilação Unity nem playthrough humano.
- O PR #82 avançou **dois commits** desde o SHA usado como base para o #83 (`f3e0cb0` → `232867c`); o compare retornou 23 arquivos alterados, incluindo C#, verificadores e configuração Unity. O risco de drift precisa ser resolvido antes de integrar a pilha; não assumir compatibilidade apenas pelo status mergeable do GitHub.
- O PR #85 segue paralelo à pilha e não deve ser integrado sem deduplicar o acervo contra #84.

## Linha única de trabalho atual
`main` (Godot baseline) → #82 (preparo Unity) → #83 (gates) → #84 (arte e 21 pranchas) → #87 (21 blockouts e 105 IDs) → #89 (preview Canvas/JS). #85 é branch paralela parcial. **Nenhum merge autorizado.**

## Verificações do protótipo já documentadas, não reproduzidas nesta sessão
- `web/README.md`: `node web/serve.mjs`, URL local `http://127.0.0.1:4173/`, sem npm.
- `web/verify.mjs`: verifica igualdade com o plano canônico, presença dos 13 PNGs e validação dos IDs.
- `web/engine.test.mjs`: seis testes de regras. O teste de campanha força `enemy.alive = false` e não demonstra a conclusão humana das salas.
- **Limite desta auditoria:** leitura autenticada de código e CI via conector; rede do container sem resolução de github.com, portanto sem checkout, servidor local, screenshot independente ou playtest manual. Sem URL pública de branch validada.

## Gates mensuráveis
### G1 — Smoke desktop local (pendente)
1. Em checkout do SHA #89: `node --check web/engine.mjs && node --check web/renderer.mjs && node --check web/main.mjs`.
2. `node web/verify.mjs`: deve terminar com validação 21 salas, 105 IDs, 13 PNGs.
3. `node --test web/engine.test.mjs`: 6 testes passando.
4. `node web/serve.mjs`; abrir `http://127.0.0.1:4173/`, verificar HTTP 200 de HTML, JSON, JS e sprites, console sem erro, teclado e HUD.
5. Registrar SO, navegador, versão, viewport, SHA e screenshots. **Não marcar como feito por CI antigo.**

### G1.1 — Preview temporário de branch (issue #90, pendente de hospedagem e autorização)
Usar apenas branch do PR #89/branch de QA; diretório estático `web`, sem build, npm ou domínio de produção. Confirmar URL e HTTP 200 para HTML, `data/rooms.json`, módulos JS e 13 PNGs, cache/cabeçalhos adequados; teste desktop e telefone. Não inventar URL, nem publicar produção.

### G2 — Primeira fatia completa (Floresta 01–07, pendente)
Percorrer manualmente as sete salas sem alterar estado por console/scripts; coletar cinco cauris por sala, conferir +1 vida uma única vez, checkpoint, respawn, gate de combate, portal, câmera, rota alta e chefe provisório. Registrar tempo por sala, passos de reprodução de defeitos, contagem, estado final e FPS quando mensurável.

### G3 — Campanha inteira (issue #91, pendente)
Repetir em Castelo 01–07 e Cavernas 01–07; validar 21/21 salas, 105/105 búzios, três guardiões e condição de vitória. Testar teclado e toque em **dispositivo real**, com navegador/viewport anotados; riscos de geometria, acessibilidade, performance, combate e persistência separam-se por issue reproduzível.

### G4–G7 — Não liberados
Metaprogressão permanente/skins (#88), revisão especializada de arte/cultura/licenças, editor Unity/Android, QA físico e release comercial: **NO-GO**. Não migrar saves nem promover estados sem autorização.

## Convenção de evidência em cada issue de bug
`SHA | sala | plataforma/navegador | viewport | pré-condição | passos | esperado | observado | captura/log | severidade | status de reprodução`.

## Decisões de preservação
Produto Rasta Quest; protagonista Akane Xangô; 21 pranchas originais em #84 permanecem como mapas condensados, não fundos finais; 5 conchas de cauri por sala; machado não abre portais; Unity 6.3 LTS é alvo, não runtime comprovado; web é protótipo e Godot baseline; chefes/Santuário 2D. Sem novas pranchas, merges, deploy de produção ou alterações de save.
