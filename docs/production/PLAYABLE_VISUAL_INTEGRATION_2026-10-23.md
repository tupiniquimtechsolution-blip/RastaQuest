# Integração visual jogável — 23/10/2026

Status: versão de revisão jogável. Os recursos nativos substituem os polígonos de desenvolvimento **no perfil Visual Review**; o perfil comercial continua sem promoção enquanto houver pendências da versão final. GREEN comercial: **NO-GO**.

Base: main `e83da3c58445acf1e847b7e75457400051b26058` (PR67). Rodrigo autorizou polimento, conexão de portal/efeitos e integração ao APK; a substituição comercial foi condicionada à ausência de pendências visuais finais. Esta autorização não é aceite de imagens que ainda não foram vistas, nem comprovação de direitos.

## O que mudou

- Quatro inimigos receberam 16 novas poses cada: idle2/move6/tell2/attack2/hurt2/death2. Há seis articulações diferentes de caminhada, sem duplicação de quadros para simular uma animação maior. A cadência acompanha a velocidade do ator; a qualidade final do movimento ainda requer revisão em jogo.
- Conjurador e Controller usam, cada um, uma textura mestre independente (besta72×32 e bastão24×112), com pega por quadro, inversão da direção e transformação rígida. O corpo novo foi gerado sem esses equipamentos. Encaixes foram corrigidos após inspeção das composições nativas. Espada/escudo do Chaser permanecem no rig anterior. A silhueta do Charger ganhou volume vertical, preservando o collider34×58; o encaixe perceptivo ainda precisa ser avaliado.
- O protagonista mantém os oito estados anteriores, quadro256×256/corpo104/render0,5. Sua corrida acompanha a velocidade real. As quatro poses específicas de portal agora acompanham a janela de entrada; dano, morte e respawn cancelam a apresentação. O corpo continua com fade discreto e a borda do portal fica estática quando flashes reduzidos estão ativos.
- Impacto, eletricidade entre alvos, área/abate e recompensa são acionados por eventos reais. Efeitos hostis acompanham a posição e o tamanho das formas de dano existentes; o contorno preciso de ameaça permanece. Animações não concedem dano, modificam raios, ativam colisões ou avançam salas. Os efeitos de impacto têm duração limitada; a exclusão/cancelamento do ataque remove sua apresentação hostil. Flashes reduzidos mantêm um quadro estático, e há limite de efeitos simultâneos.
- O catálogo aplica automaticamente protagonista, portal, cinco arquétipos, dois chefes e ambientes às cenas existentes. O Hub recebe o fundo próprio no menu real. O recorte jogável usa Floresta/Castelo/Cavernas, cenário com contraste reduzido, chão no contato640 e câmera de revisão y−154, limitada à largura real do chão. Não adiciona plataformas decorativas com colisões novas.

## Arquivos e versões

`assets/production_drafts/2026-10-23/playable-visual-v01/` preserva dez imagens-fonte: quatro estudos de corpo, suas quatro correções e duas armas isoladas. Prompts em `PROMPTS.json` e `CORRECTION_PROMPTS.json`; reconstrução em `build_polish.py`; fontes/exports e parâmetros em `MANIFEST.json`; paleta32 por ator, alpha binário e chão186 nos exports256px. O alfa intermediário do gerador foi explicitamente limiarizado em200 antes da redução BOX e registro nativo. Não se afirma autoria pixel a pixel do gerador ou preservação automática de anatomia.

`game/visual_review/` contém242 recursos nativos identificados e `catalog.json`, copiados com SHA256 e origem pelo `tools/build_visual_review_pack.py`. São exports individuais, não recortes de concept sheets canônicas. O diretório é exclusivo do perfil de revisão; nenhum concept sheet foi enviado a `game/assets/`. A classificação `commercial_approved=false` é conservada. O registro de procedência continua com direitos/cultura pendentes e não equivale a uma licença.

`game/scripts/art/` contém catálogo, camadas, efeitos e probe de integração. O adaptador do protagonista aceita o clip opcional de portal; o adaptador hostil aceita arma rígida por quadro. Os pontos de combate/sala apenas disparam apresentação, sem alterar valores ou autoridade de gameplay.

Verificadores dos pacotes PR66/67 passaram a consultar os commits históricos efetivamente capturados. As imagens antigas não foram recapturadas ou reclassificadas como evidência do novo código. O novo pacote tem capturas próprias e hashes dos seus inputs atuais.

## APK de revisão e isolamento comercial

Perfil `Android Visual Review`, feature `visual_review`, versão `1.0.0-visual.1`, código1000002, pacote `com.tupiniquimtechsolution.rastaquest.visualreview`, nome **Rasta Quest Visual**. ARMv7+ARM64, mínimo AndroidAPI24/alvo35; Android14/API34 está dentro do intervalo. Compatibilidade e desempenho físicos no GalaxyA13 continuam não medidos.

O aplicativo de revisão tem identificador próprio e não substitui a instalação comercial. Os três perfis anteriores excluem o payload `visual_review` e o probe; os manifests comerciais rejeitam esse diretório se aparecer por engano. O catálogo não habilita a arte candidata no perfil comercial. A chave de CI é debug temporária, sem assinatura de publicação ou autorização para loja.

O CI exporta também um PCK de revisão e executa o probe dentro dele, **sem acesso ao diretório de drafts e sem argumento para forçar o modo de revisão**. A feature do export precisa habilitar a atribuição automaticamente. O APK real é validado por metadados/ABIs/assinatura e por catálogo igual ao testado, remaps e texturas importadas presentes. APK e PCK recebem evidência vinculada ao commit/SHA256; nenhum resultado de desktop é apresentado como instalação Android.

## Verificação e limites

O probe verifica atribuição automática, ausência dos polígonos substituídos, Hub/biomas, todas as pegas/inversões dos dois equipamentos, rejeição de rig incompleto, nove padrões reais de ataque com dano, morte limitada, entrada no portal com interrupção, efeitos estáticos com flashes reduzidos, impacto/corrente/abate disparados por acertos reais e término dos efeitos. O pacote nativo tem verificação de cópia/hash/contratos; o novo lote tem verificação de cor/alpha/chão e52 capturas reais em1280×720/640×360 com PNG/input hashes.

Passaram localmente: novo probe em projeto e PCK exportado, regressões de ataques hostis, portal/arma caída, sprite/morte do jogador, combate e verificadores históricos PR65/66/67. A importação/exportação local inicialmente encontrou falhas de salvamento no diretório temporário do ambiente Windows. Usar um diretório temporário próprio permitiu gerar um PCK válido e passar seu runtime; avisos de editor/build-tools locais não são descritos como exportação Android limpa. O APK e o CI são verificados independentemente. Houve uma dependência circular de compilação do autoload na regressão com preload; foi removida antes da validação final.

## Pendências para promover o visual comercial

1. Rodrigo revisar esta versão identificada: movimento/pega/cabelo/anatomia, enquadramento e leitura nativa/reduzida. A aprovação da base anterior não é transferida às novas poses, armas e composição. Silhuetas sem rótulos e eventuais confusões ainda precisam de respostas humanas.
2. Instalar e jogar o **Rasta Quest Visual** no GalaxyA13: controles/oclusão, clareza de ataques/efeitos, proporções, repetição espelhada dos fundos, desempenho, pausa/retorno e entrada no portal. A tela do aparelho é a evidência pendente, não um marcador automatizado.
3. Resolver achados visuais observados e registrar aprovação da versão corrigida. A largura aparente do Charger versus collider e a naturalidade da repetição permanecem itens explícitos de revisão, não problemas declarados resolvidos por um teste de arquivos.
4. Completar revisão cultural por Rodrigo e comprovação de direitos/termos para as versões finais. Depois promover os recursos identificados ao perfil comercial em uma alteração própria, removendo a classificação de revisão somente com evidência. Assinatura comercial, loja e Beta/Gold permanecem gates separados.

Referências externas: ferramenta integrada ImageGen, referências canônicas e runtime/Pillow já existentes. Nenhum pacote estrutural ou arte externa foi adotado nesta etapa. Acabamento/áudio continua depois da conclusão visual.
