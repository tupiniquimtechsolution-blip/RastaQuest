# Bancada de criação 2D

Prévia executável das seis frentes de pré-produção, independente de Unity e sem alterar o protótipo Godot ou saves do jogo.

Na raiz do repositório, com Python 3 instalado:

```powershell
python -m http.server 8768 --bind 127.0.0.1
```

Abra http://127.0.0.1:8768/preunity/lab/ no navegador. Não abra o HTML diretamente: a bancada carrega arquivos JSON locais pelo servidor. Encerre o servidor com Ctrl+C. Não precisa instalar pacotes.

| Frente | O que experimentar | Limite atual |
|---|---|---|
| Modelo e movimentos | 12 linhas do tempo, reprodução, pose e movimento no lugar | Esqueleto estrutural de 11 ossos, sem arte vinculada; modelo neutro separado |
| Reações | Defesa precisa, rebatida, escudo e esquiva contra tipos de ataque | Simulação isolada; não implementa regras no jogo |
| Cenários e VFX | Três biomas, nove camadas, travessia e prévia elétrica | Sem tiles, colisões, bordas repetíveis ou salas montadas |
| Habilidades | 25 nós, detalhes, pré-requisitos e desbloqueio demonstrativo | Custos indefinidos; localStorage separado do save |
| Áudio | 16 MP3s originais, busca e filtro por família; pendências opcionais | Catálogo de 84 cues; 68 aguardando geração. Sem aprovação auditiva, edição ou mixagem final |
| Andamento | Produzido e restante em cada frente | Protótipo não equivale a integração na engine |

Os 1.200 ms das linhas do tempo são unidades de demonstração, não balanceamento de golpes. Os estudos visuais existentes são referências, não sprites finais. O reset limpa apenas a demonstração de habilidades; não propõe respec no jogo. Efeitos reduzidos começam ativados.

Verificações automatizadas, com Node instalado:

```powershell
node --test preunity/lab/engine.test.mjs
node --check preunity/lab/lab.mjs
```

[Registro da entrega e pendências](../docs/production/PREUNITY_EXECUTION_2026-10-24.md).

[Cobertura sonora: personagens, armas, dano/morte e ambientes](../docs/production/audio_drafts/SFX_EVENT_MAPPING_2026-10-24.md).
