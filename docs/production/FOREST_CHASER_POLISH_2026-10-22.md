# Floresta e Chaser — polimento v02

Base: main d576cd0581204a205c2e0a2f0c5aa2e0abb7cfd5 (PR64/65 integrados). Escopo autorizado: completar o próximo pacote de polimento e sua prova técnica. Não representa conclusão de todos os cenários/inimigos nem aprovação do novo modelo por Rodrigo.

## Entrega e arquivos

`assets/production_drafts/2026-10-22/forest-chaser-polish/` preserva duas novas fontes geradas com a ferramenta integrada ImageGen, prompts exatos, reconstrução reproduzível, manifest com hashes, verificador e prévias. A correção localizada da fonte corporal retirou escudos indesejados das duas poses de ataque. A fonte de terreno continua sendo a imagem independente produzida no PR65; nenhuma prancha canônica foi recortada para virar sprite de gameplay.

O Chaser tem 16 poses corporais 256×256: idle2, move6, tell2, attack2, hurt2, death2. Todas usam a mesma redução0,44, origem128/128 e limite inferior dos pés186; renderização0,5, corpo em pé de aproximadamente116 pixels de fonte/58 unidades de mundo e colisão34×58 preservada. Fragmentos desconectados menores que8pixels foram removidos; a contagem por quadro consta do manifest. Não se trata de interpolação de placeholders ou duplicação de uma pose para fingir mais movimentos.

Espada56×16 e escudo32×52 são duas texturas fixas, com paleta24 compartilhada com o corpo e alpha binário. O presenter opcional associa posições e rotações por quadro sem redesenhar ou redimensionar esses objetos. A inversão acompanha explicitamente o corpo; trocar o pacote corporal limpa as antigas posições das mãos. Dados inválidos são rejeitados antes de alterar um rig válido. Ataques e colisões continuam sob autoridade do gameplay; o ataque real mantém tell250ms, active160ms e recovery300ms. A morte decorativa dura320ms e cancela dano/progresso uma única vez.

O kit de terreno possui16 peças32×32: três superfícies, três preenchimentos, extremidades superiores, laterais, base, dois cantos inferiores, bloco isolado e dois cantos internos. Amostras locais da fonte preservam raízes/pedras maiores; faixas de borda compartilhadas permitem combinar variantes. Silhuetas e raízes inferiores são edições nativas explícitas. Igualdade de pixels nas junções não comprova por si só naturalidade artística ou cobertura de todos os mapas futuros. As raízes abaixo da colisão são decoração, com até16pixels de fonte de altura.

`game/tests/forest_polish_fixture.gd` e `forest_review_parallax.gd` compõem uma sala separada. Fundo0,25, árvores0,65, terreno1,0 e primeiro plano1,08 acompanham a câmera horizontalmente. O fundo fica preso à altura da tela para não abrir lacuna no salto. Painéis alternadamente espelhados oferecem bordas contíguas; sua periodicidade/reflexão permanece visível e identificada. O primeiro plano começa abaixo dos pés, evitando encobrir o corredor de combate. O chão e as duas plataformas originais mantêm os contatos640/576/512. Uma extensão de piso até2560 existe somente nesta prova de travessia.

## Evidências e verificações

- `forest_polish_integration.gd`: todas as16poses e as duas direções usam as mesmas texturas; pacote inválido preserva o rig; substituição do corpo descarta posições antigas; fases reais causam dano; morte cancela orçamento e abre portal; quatro extremidades de plataformas têm contato alinhado; caminhada/salto percorrem2180pixels sem quebra no piso; deslocamento real da câmera confirma velocidades das camadas e cobertura em cinco posições.
- Regressões: Forest/Chaser anterior, portal/arma caída, ataques hostis, morte do protagonista e densidade de sprites passaram localmente. O novo teste integra Godot CI com timeout45s e rejeição explícita de mensagens de erro. Android/estrutura/Gold dependem dos checks do novo HEAD; não se presumem concluídos pelo teste local.
- `tools/render_forest_polish_review.gd`:31capturas reais em Godot4.5.1/OpenGL3.3/Intel UHD, incluindo cinco posições em1280×720 e640×360,16poses inspecionadas, ataque nos dois sentidos e tell/active/morte reais. As poses controladas estão marcadas separadamente no relatório. A captura de morte espera de fato a segunda pose e pausa a cena antes da remoção limitada; não confunde desaparecimento com morte visível.
- `verify_polish.py`: hashes/dimensões/fontes,24cores/alpha0ou255, pés186, limites da arma transformada dentro do quadro, junções de todas as variantes, captura/estado/fonte e ausência de aceite/promocão indevidos. `VERIFICATION.json` registra o resultado.
- As12capturas anteriores permanecem intactas. Seu verificador consulta os textos do commit c8791b4abc2b8e7db649956380bae1df8375c0f0, que efetivamente as originou, em vez de atribuí-las ao presenter atual. É necessário que esse objeto Git esteja disponível para verificar a evidência histórica.

As prévias GIF são composições de fonte com peças rígidas, identificadas como SOURCE MOTION. Os PNGs em `room-review/` são renderizações reais; nenhuma dessas duas evidências é teste em aparelho físico. O enquadramento y-154, extensão de piso e limites0..2560 continuam sendo propostas exclusivas da sala de prova. Não foram aplicados à câmera comercial.

## Riscos e próximos gates

O polimento de continuidade geométrica dos equipamentos, movimentos adicionais, kit retangular e profundidade horizontal está implementado nesta versão. A avaliação de fluidez, detalhes de armadura/capa, luz/contraste, repetição espelhada e encaixes de mãos ainda exige revisão visual da versão identificada; testes numéricos não concedem MODEL_LOCK/PALETTE_LOCK. O kit não promete cobrir encostas, autotile de todos os biomas ou geração procedural futura. Retângulos de perigo de combate continuam provisórios.

Os recursos de arte comerciais continuam sem atribuição; fixtures e fontes externas a game/assets não entram no APK/AAB. Próximos gates: revisar esta versão e o enquadramento; registrar procedência/direitos e revisão cultural final; promover somente exports revisados de modo documentado; testar APK real e legibilidade/desempenho no Galaxy A13; completar demais cenários/inimigos/bosses; depois acabamento/áudio. Chaves, assinatura, loja e aceite humano permanecem pendentes. GREEN comercial continua NO-GO.

Referências externas de código: nenhuma biblioteca ou código externo novo. Ferramenta de arte: ImageGen integrada, sem CLI/APIkey; prompts/fontes/derivados estão preservados no pacote. A busca por padrões de credenciais e os resultados do PR ficam registrados no checkpoint de execução e no Agenor, com as limitações do scanner.
