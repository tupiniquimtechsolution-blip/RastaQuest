# Originais recuperados do chat — 24/10/2026

## Acervo preservado

25 imagens fornecidas diretamente pelo usuário em três mensagens consecutivas. São **24 PNGs novos arquivados** e **1 reenvio idêntico** ao Castelo 05 já existente. Todas as cópias têm bytes e SHA-256 iguais aos anexos; não houve recorte, redimensionamento, remoção de fundo, recompressão, geração ou substituição de artes.

O usuário confirmou que o conjunto inclui o ícone do jogo, arte de tela inicial/capa, carregamento, menu principal, lore, coletáveis, equipamentos, personagens, santuário e salas, e que será utilizado como material visual e promocional. O catálogo mantém essas finalidades separadas das pranchas de fase.

Os nomes organizados abaixo são nomes de arquivo para o acervo; o manifesto conserva os nomes recebidos do clipboard. Datas e nomes de geração originais são desconhecidos. Reenvio pelo usuário não equivale a integração no runtime ou a verificação de direitos de produção.

## Identidade, telas e materiais promocionais

| Categoria | Arquivo |
|---|---|
| Capa / arte de tela inicial | [capa-rasta-quest.png](branding/capa-rasta-quest.png) |
| Ícone do jogo | [icone-rasta-quest.png](branding/icone-rasta-quest.png) |
| Carregamento / atualização | [carregamento-atualizacao.png](ui/carregamento-atualizacao.png) |
| Menu principal | [menu-principal.png](ui/menu-principal.png) |
| Menu de equipamentos, atributos e poderes da run | [equipamentos-atributos-poderes-run.png](ui/equipamentos-atributos-poderes-run.png) |
| Coletáveis — referência inicial | [coletaveis-v01.png](systems/coletaveis-v01.png) |
| Coletáveis, equipamentos e progressão | [coletaveis-e-progressao-v02.png](systems/coletaveis-e-progressao-v02.png) |
| Skins de personagem e machado | [skins-premium.png](systems/skins-premium.png) |
| Lore / origem de Akane Xangô | [lore-akane-xango.png](world/lore-akane-xango.png) |
| Santuário Ancestral | [santuario-ancestral.png](world/santuario-ancestral.png) |
| Akane — prancha de poses/animações | [akane-xango-animation-sheet.png](characters/akane-xango-animation-sheet.png) |
| Cavaleiro — prancha de poses/animações | [cavaleiro-corrompido-animation-sheet.png](enemies/cavaleiro-corrompido-animation-sheet.png) |
| Arcanista — prancha de poses/animações | [arcanista-animation-sheet.png](enemies/arcanista-animation-sheet.png) |

As barras de progresso, números, tempos e atributos desenhados nas telas são exemplos de interface. Seu arquivamento não comprova atualização de pacotes, balanceamento implementado ou funcionalidade existente. As pranchas de poses não são declaradas sprites recortados, atlas animáveis ou rigs prontos.

## Salas recuperadas

| Bioma | Sala | Arquivo |
|---|---|---|
| Floresta | 01 | [Original identificado pelo usuário](biomes/floresta/sala-01-original.png) |
| Floresta | 02 | [Ponte das Raízes Profanadas](biomes/floresta/sala-02-ponte-das-raizes-profanadas.png) |
| Floresta | 03 | [Viveiro dos Xamãs Corrompidos](biomes/floresta/sala-03-viveiro-dos-xamas-corrompidos.png) |
| Floresta | 04 | [Cascata dos Ecos de Pedra](biomes/floresta/sala-04-cascata-dos-ecos-de-pedra.png) |
| Floresta | 05 | [Clareira do Julgamento de Ogum](biomes/floresta/sala-05-clareira-do-julgamento-de-ogum.png) |
| Floresta | 06 | [Coração da Árvore Profanada](biomes/floresta/sala-06-coracao-da-arvore-profanada.png) |
| Floresta | 07 | [Trono da Raiz Julgadora](biomes/floresta/sala-07-trono-da-raiz-julgadora.png) |
| Castelo | 01 | [Portão das Muralhas Quebradas](biomes/castelo/sala-01-portao-das-muralhas-quebradas.png) |
| Castelo | 02 | [Galeria das Correntes Partidas](biomes/castelo/sala-02-galeria-das-correntes-partidas.png) |
| Castelo | 03 | [Salão dos Arcos Caídos](biomes/castelo/sala-03-salao-dos-arcos-caidos.png) |
| Castelo | 04 | [Torre do Sino Rachado](biomes/castelo/sala-04-torre-do-sino-rachado.png) |
| Castelo | 05 | [Forja do Ferro Sagrado — cópia já existente](../biome-continuation-v01/reference-castelo-sala05.png) |

A sala 01 da Floresta não tem número ou nome próprio impresso no título; sua identificação como sala 01 foi fornecida expressamente pelo usuário. O arquivo é preservado assim, sem inventar título ou redesenhar a prancha.

Castelo 06–07 e Cavernas 01–07 continuam no [pacote de continuação](../biome-continuation-v01/README.md). Em conjunto, os dois pacotes contêm **21/21 pranchas de salas: 7 por bioma**. Não falta nenhuma imagem de sala desse conjunto. Isso não afirma que todas as imagens de qualquer histórico anterior foram recuperadas.

## Regras e contexto

- [MANIFEST.json](MANIFEST.json) registra os 25 anexos, finalidade, nome recebido, dimensões, modo de imagem, bytes, SHA-256, Git blob SHA e destino. A duplicata da sala 05 aponta para o arquivo já existente e não aumenta a contagem de salas.
- [historical-context-verbatim.txt](historical-context-verbatim.txt) preserva os bytes do texto colado pelo usuário, incluindo o pedido de enviar todas as imagens ao GitHub. Declarações de assistentes ali citadas são histórico, não evidência automática de upload, aprovação ou geração concluída.
- Algumas pranchas históricas ilustram mais de cinco conchas, numeram búzios entre salas ou usam textos de vida máxima. Foram preservadas sem alteração. Para implementação prevalece a regra atual: **cinco búzios reais por sala concedem uma vida extra**, com coleção global separada. Equipamentos/melhorias permanentes e buffs de run permanecem distintos.
- Não se alteram salas já aprovadas com base em propostas ou nomes históricos conflitantes no texto. As ideias de salas extensas, árvore de habilidades no menu de pausa e futura avaliação 2D/3D continuam no [registro de intenção](../../../../docs/production/DESIGN_INTENT_AND_IMAGE_AUDIT_2026-10-24.md).
- A completude acima é do acervo de pranchas, não da implementação dos biomas. Não houve mudança de código, gameplay, build Unity, merge ou release. Materiais estão em branch de trabalho do PR #84, sem integração automática na main.
