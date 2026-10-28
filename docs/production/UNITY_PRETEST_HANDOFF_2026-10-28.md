# Unity: pronto para o primeiro teste de editor — 28/10/2026

Este documento registra o estado da **sala de revisão**, não o aceite comercial. A implementação continua no [PR #82, em rascunho](https://github.com/tupiniquimtechsolution-blip/RastaQuest/pull/82). O APK Godot entregue anteriormente não foi substituído.

## Adiantado sem o Unity Editor

- O analógico calcula o eixo pelo centro real do botão, respeita zona morta e gesto para cima com histerese. Toques são liberados ao pausar, perder foco e mudar a área segura da tela.
- A posição dos quatro controles passou a usar a borda inferior da área segura em ambas as orientações horizontais. O HUD conserva retrato, barra longa e sombra periférica; telas modais cobrem o jogo e consomem toques fora dos botões.
- Sala de derrota com reinício completo da tentativa: Floresta, vida cheia, dano e velocidade de ataque iniciais. Uma derrota cancela cura pendente. Pausa e suspensão preservam escolha e cronômetro de transição.
- Português e espanhol cobrem os textos visíveis desta sala de revisão. Idioma e redução da sombra persistem por preferências locais da versão de revisão. Persistência da campanha comercial segue pendente.
- Porta tem uma oferta, uma escolha e uma entrada por sala. Cura ocorre somente se essa escolha for selecionada. Outras melhorias não restauram vida. O portal agora percorre seu clip de revisão.
- Defesa com projéteis refletidos permanece ativa durante a breve imunidade após dano recebido. Danos inválidos não contaminam a vida.
- O probe nativo, **ainda não executado**, foi estendido para capturar entrada, pausa, ataque, defesa/parry, dano, escolha, destino com e sem cura, derrota e reinício. Seu relatório identifica versão/engine, falhas e capturas, e mantém aprovação física/comercial como pendente.

## Evidência executada

`python -B tools/sync_unity_review.py --check` confirma 274 PNGs byte a byte e GUIDs únicos. `python -B tools/check_unity_source.py` grava um relatório em `unity/Builds/SourceChecks/` com hash dos fontes, HEAD, estado do checkout, compilação/execução do núcleo C# e limite de verificação. O resultado local foi **PASS: 72 asserções C#**; não prova APIs, importação, input, renderização ou colisões reais do Unity. O CI do novo HEAD deverá repetir a parte de contratos de fonte.

## Ordem do primeiro teste real

1. Concluir [#80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80): instalação de Unity 6000.3.27f1 e Android Build Support com SDK/NDK/Java. O Hub está instalado; o editor foi impedido pela confirmação de administrador, e Rodrigo informou não ter acesso agora. Conta/licença ficam com o titular se o Unity solicitar.
2. Abrir `unity/` no editor, aguardar resolução de Input System/uGUI, preservar o `packages-lock.json` real, corrigir erros de importação/compilação e versionar a cena/configuração que o editor gerar. Não criar lock ou atestar importação por inspeção de fonte.
3. No menu **Rasta Quest → Preparar sala Unity**, iniciar Play Mode. Conferir o retrato cortado, os equipamentos em cada frame, controle em ambas as rotações, área segura, foco/pausa, corrida, salto duplo, parry/reflexão, escolha e cura, derrota/reinício, portal e diferenças visuais dos mundos. Registrar erros com captura e versão.
4. Construir o executável Windows de revisão. Executá-lo com `--rq-probe --rq-output=<pasta>` e conferir `NATIVE_REPORT.json` **junto das capturas reais**. Probe sintético em runtime não comprova toque físico, rotação do Galaxy A13, prazer visual ou integração comercial.
5. Construir APK de desenvolvimento Unity e avançar [#81](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81) no Galaxy A13. Conferir instalação, ABI, API 36, alinhamento 16 KB, controles, fluidez, leitura do HUD, rotação, desempenho e estabilidade. A [#50](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/50) mantém seu gate Android.
6. Substituir gradualmente os 274 sprites transitórios por animações e cenários ilustrados próprios, com procedência/direitos e revisão cultural da versão efetiva (#35–38). Repetir QA da versão exata antes de qualquer promoção comercial.

## Limites conhecidos

Sem o Editor, o código de componentes ainda pode falhar na compilação ou no comportamento nativo. O corte do retrato, posições de equipamento, raycasts dos controles, tamanho efetivo da área segura e capturas do probe exigem verificação visual real. A migração ainda não contém toda a campanha, chefes, saves, áudio, efeitos/URP, acessibilidade e ilustrações finais. **GREEN comercial: NO-GO.**
