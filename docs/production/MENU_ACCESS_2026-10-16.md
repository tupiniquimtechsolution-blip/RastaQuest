# Interface acessível e localização — Agenor #11

O Refúgio agora oferece Configurações e Créditos/licenças. A pausa permite abrir/fechar Configurações sem retomar o combate; Continuar retoma. Os diálogos têm camada própria, controles de fechamento e processamento durante pausa.

O catálogo CSV existente agora gera dois recursos gettext UTF-8 versionados, registrados no projeto. tools/build_translations.py --check detecta divergência entre CSV e recursos. Foram conectados24 textos de menus, configurações, tutorial e controles. Isso não declara traduções finais de todos os títulos/descrições de salas, upgrades e narrativa.

O tutorial está conectado à cena real de run. Na primeira execução ele pausa o perigo, mostra três etapas, persiste tutorial_complete e libera a partida ao concluir. Remover a cena restaura o estado de pausa anterior. A janela de pausa não interrompe o tutorial.

A preferência de tamanho agora redimensiona e reposiciona os botões de toque, preservando margens e separação. Pausar/perder foco/ir para background libera ações seguradas para evitar movimento ou ataque presos. Volume e idioma usam o serviço de save/settings já existente.

Créditos expõe os avisos obtidos do próprio motor via Engine.get_license_text/get_copyright_info/get_license_info. Não há atribuição inventada a artistas nem aceite/licença presumido para assets finais; fontes/provas dos assets e dependências Android ainda precisam constar do inventário de release.

## Evidências técnicas

menu_access_integration.gd usa as cenas reais: abre/fecha configurações no Refúgio e na pausa; troca PT-BR/inglês; verifica texto dinâmico, persistência e volume/mute dos barramentos; confere contenção do painel em três proporções lógicas; abre avisos do motor; conclui tutorial na run; escala controles e verifica liberação de input ao pausar/perder foco. É teste de integração/layout lógico, sem simular aceite visual ou ergonomia física.

Os13 scripts de teste e a verificação dos24 textos são executados junto às regressões do projeto. Save dos testes locais é isolado no workspace. Nenhum asset artístico foi promovido, áudio final criado ou decisão comercial tomada. O APK continua usando arte provisória até a entrega e integração dos sprites finais.

Próximos gates: leitura e dois polegares em Android, revisão de layout/acabamento, tradução de conteúdo restante, áudio final/licenças e aceite de jogador novo. Gold NO-GO.
