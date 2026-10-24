# Avanço das seis frentes — 24/10/2026

Esta entrega avança as seis frentes autorizadas antes do Unity. A [bancada local](../../preunity/README.md) permite avaliar os arquivos e interações. Não encerra a produção de todos os assets ou sua integração.

| Frente | Arquivos entregues | Próximo trabalho de produção |
|---|---|---|
| Modelo e rig | Modelo neutro transparente de Akane; hierarquia de 11 ossos | Recorte em peças, skinning, pivôs, pegada e sockets consistentes |
| Animações | 12 linhas do tempo interpoladas, cinco chaves por movimento, vinculadas às pranchas de referência | Arte animada final, foot locking, transições e ritmo do combate |
| Reações | Simulador de quatro respostas por tipo e momento do ataque | Clips dos inimigos, interrupções por dano/morte e validação no combate |
| Cenários/VFX | Nove PNGs: distante, médio e primeiro plano para cada bioma; prévia elétrica | Tiles, colisões, repetição das bordas, medidas e montagem das 21 salas |
| Habilidades | 25 nós clicáveis com pré-requisitos, detalhes e estados | Custos/efeitos, controles mobile, integração no save e UI da engine |
| SFX | 12 MP3s originais com manifest, prompts, origem e SHA-256 | Audição do piloto, variações, 30 cues restantes, edição e mixagem |

As pranchas originais permanecem preservadas. As novas camadas são estudos de produção a partir da direção existente; não substituem layouts aprovados. Todo o jogo, chefes e santuário continuam em 2D. Equipamentos personalizam cabo, lâmina e ponteira; a árvore desenvolve técnicas.

## Rota de áudio verificada

O catálogo e a especificação conectados do Segmind confirmaram [Sonilo Text to Audio](https://www.segmind.com/models/sonilo-text-to-audio): `sound_type=sfx`, duração de 1–180 segundos e saídas WAV/MP3/AAC/FLAC. A cotação consultada para SFX foi US$ 0,00225 por segundo: US$ 0,0045 para dois segundos, ou US$ 0,054 para 12 desses testes. É uma cotação da consulta, não um gasto realizado ou garantia de preço futuro. A geração Segmind não foi executada por indisponibilidade de saldo. A rota `sound-generation` listada no catálogo retornou slug inválido na consulta de especificação; não foi tratada como operacional.

Foi usada a rota já conectada Higgsfield/Mirelo Text to Audio, que cotou 0,5 crédito por geração de dois segundos. Os 12 jobs concluíram e os arquivos retornados foram preservados. Requisições rejeitadas por limite de frequência foram repetidas sequencialmente; jobs aceitos não foram reenviados. Não foi criado novo projeto externo. Não é necessário instalar outro plugin para avaliar esse piloto.

O [manifest dos 12 arquivos](../../assets/production_drafts/2026-10-24/sfx-pilot-v01/MANIFEST.json) registra formato real MP3, frames MPEG, frequência, canais, prompt, job e hash. A duração aproximada de 2,09 s deriva dos frames; não é medição de loudness. Aprovação auditiva, ausência de clipping, loops contínuos e uso comercial final não foram certificados. Não houve conversão para falsos mestres WAV.

## Evidência e limites

- Quatro testes Node passaram: interpolação/limites de tempo; comprimentos dos ossos em 12 clips; pré-requisitos de habilidades; respostas condicionadas ao ataque/janela. A verificação de sintaxe do módulo de interface passou.
- Dez novos PNGs íntegros, com dimensões, SHA-256 e alfa registrados nos respectivos `PROVENANCE_AND_QA.json`: nove camadas e um modelo neutro. Planos médios e frontais possuem transparência.
- Navegador: página carregou; composição da floresta inspecionada visualmente; Varredura Baixa bloqueada antes de Corte Ascendente e disponível após o desbloqueio demonstrativo; demonstração limpa ao final. Rebatida rejeitada contra golpe corpo a corpo e defesa precisa aceita. Biblioteca exibiu 12 cues e reprodução de `axe_swing_light` foi aceita pelo navegador. Isso não substitui audição crítica.
- Sem alterações no código de gameplay, save ou projeto de engine. Sem instalação, compilação Unity, Play Mode, APK, merge ou declaração de release/CI verde.

O plano anterior permanece como histórico; seu estado inicial de áudio foi superado por este registro e pelo catálogo atualizado de cues. A expansão sonora deve usar a identidade escolhida na audição do piloto, evitando produzir dezenas de variações ainda sem direção validada.
