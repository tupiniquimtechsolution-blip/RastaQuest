# Continuação visual dos biomas — v01

Pranchas de pré-produção geradas em 24/10/2026. São propostas visuais para revisão; não são fases implementadas, sprites exportados ou arte final aprovada.

## Referência recuperada

O usuário anexou a última prancha: **Bioma 2, sala 05 — Forja do Ferro Sagrado**. A cópia `reference-castelo-sala05.png` é referência, não uma nova versão da sala. Não foram redesenhadas Floresta 01–07 ou Castelo 01–05.

As novas imagens foram geradas com `image_gen`, usando essa prancha como referência visual direta: logo, ilustração detalhada, molduras pretas e douradas, legenda à esquerda, mapa condensado central e recompensas à direita. Cavernas preserva a apresentação e propõe pedra escura, cristais turquesa/violeta e instabilidade elétrica.

## Ordem e arquivos

| Arquivo | Sala | Extensão inicial de blockout |
|---|---|---|
| [castelo-06.png](castelo-06.png) | Galeria da Última Vigília | 6 telas |
| [castelo-07.png](castelo-07.png) | Câmara do Castelo Fraturado, chefe | 5 telas |
| [cavernas-01.png](cavernas-01.png) | Boca dos Ecos | 6 telas |
| [cavernas-02.png](cavernas-02.png) | Galerias Ressonantes | 7 telas |
| [cavernas-03.png](cavernas-03.png) | Travessia das Fendas | 7 telas |
| [cavernas-04.png](cavernas-04.png) | Câmara das Correntes | 8 telas |
| [cavernas-05.png](cavernas-05.png) | Núcleo Instável | 8 telas |
| [cavernas-06.png](cavernas-06.png) | Limiar do Último Eco | 8 telas |
| [cavernas-07.png](cavernas-07.png) | Arena do Último Eco, chefe final | 6 telas |

## Contrato de leitura

- O mapa condensado representa uma travessia side-scrolling extensa. As distâncias reais exigem blockout e teste de câmera; o desenho não é uma única tela jogável.
- Akane Xangô mantém a aparência da referência. Chefes, nomes novos e reskins de inimigos são propostas, não substituições de decisões anteriores.
- Cinco búzios reais por sala equivalem a uma vida. B1–B5 na cena e no esquema representam os mesmos cinco objetos; ícones na legenda ou quadro de recompensa não acrescentam colecionáveis.
- Equipamentos, materiais e melhorias permanentes são distintos de bênçãos temporárias de run. A referência diz que o portal concede buff nesta sala; qualquer duração “nesta run” nas novas pranchas é apenas um limite máximo de temporariedade e não aprova estender o efeito além da sala. A duração específica continua a regra existente até definição explícita.
- Os cinco búzios das salas de chefe ficam antes do portão. Um chefe na sala 07 de cada bioma.
- Nenhuma passagem ilustrada com ganchos torna uma habilidade nova obrigatória. A legenda é herdada; acesso real deve funcionar com os movimentos já disponíveis.
- A ilustração principal e o pequeno esquema são guias de composição. Coerência exata de colisão, saltos, rotas e posições entre ambos exige revisão no blockout. Não foram testadas.

## Procedência e verificação

Referência fornecida diretamente pelo usuário nesta conversa. Geração e eventuais correções usam a ferramenta de imagens; sem edição raster por scripts. Os arquivos originais gerados permanecem preservados fora deste pacote. `SHA256SUMS.txt` identifica os arquivos selecionados.

Verificação visual de composição, identificação das salas e contagem B1–B5; verificação de arquivos por hash e diff. Textos pequenos e detalhes ilustrativos ainda precisam de revisão editorial e de acessibilidade antes de produção. Não é uma declaração de aprovação artística/cultural.

Correções selecionadas: marcador B3 duplicado no esquema do Castelo 07; inclusão de B2 na cena de Cavernas 03 e B5 na cena de Cavernas 07; textos de recompensa corrigidos para vida extra em Cavernas 02/03/04/05/07; rodapés de Cavernas 04/05/07 corrigidos para o bioma atual. As versões anteriores geradas não integram este pacote.

Limitação editorial conhecida: algumas legendas preservam o nome de exemplo “guarda de forja” da referência; ele não fixa a identidade do elite das cavernas. A classificação funcional de elite prevalece até revisão dos rótulos de produção.

Verificações locais executadas: 10 PNGs íntegros (9 novos + 1 referência), todos 1672×941, hashes distintos, cópias do ZIP verificadas por hash; 8 testes existentes do guard de evidência comercial passaram. Esses testes são sintéticos e não validam arte, Unity ou release. Evidência dos arquivos em `PROVENANCE_AND_QA.json` e `SHA256SUMS.txt`.

Não houve compilação Unity, Play Mode, APK, teste físico, merge ou release. Não há mudança de código, save, equipamentos ou balanceamento. Árvore de habilidades e transições 2D/3D continuam fora desta etapa.

Especificação complementar: [BIOME_CONTINUATION_2026-10-24.md](../../../../docs/production/BIOME_CONTINUATION_2026-10-24.md).
