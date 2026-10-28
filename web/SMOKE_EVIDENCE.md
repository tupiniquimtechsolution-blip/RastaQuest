# Smoke no navegador — 2026-10-28

Ambiente: prévia estática local em `http://127.0.0.1:4173/`, aberta no navegador integrado do Codex. Essa URL é **local**, não um deploy público.

| Verificação | Resultado |
| --- | --- |
| Carregar HTML, JSON, JS e 13 PNGs | Tela inicial e sprites renderizados; sem erros ou avisos no console do navegador |
| Iniciar jogo | Overlay fecha e a sala `forest-01` aparece com HUD e rota de 21 etapas |
| Mover por teclado | Tecla D deslocou o personagem para a direita |
| Coletar búzio | Primeiro búzio alterou o HUD para `BÚZIOS 1/5` e `TOTAL 1/105` |
| Layout móvel | Em 390×844, canvas, HUD, rota e cinco controles de toque aparecem sem corte horizontal |
| Ajuda | Diálogo abre e fecha; instruções de teclado/toque e aviso de arte provisória aparecem |

Os testes de simulação cobrem regras de combate, checkpoint, portais e final. O smoke visual confirmou a primeira sala e a interface móvel; não substitui um playtest humano completo das 21 salas.
