# Pacote C — Conteúdo, narrativa e localização Unity (rascunho)

**Data:** 2026-10-24. **Estado:** especificação fora do runtime, sem integração, gravações, arte ou validação humana.

Os microtextos do arquivo [unity_content_v01.json](content_drafts/unity_content_v01.json) cobrem o Santuário, Floresta Corrompida, Castelo Fraturado, Cavernas dos Ecos e conflito final, com base no arquivo existente game/data/narrative/lore.json. Eles são **propostas**, não história final aprovada. Não foram adicionados personagens, divindades, símbolos religiosos ou missões não previstos.

O catálogo em PT-BR, espanhol e inglês usa chaves estáveis e valida placeholders para vida fracionária. A integração com UI depende de importação Unity e revisão na HUD real. As três escolhas provisórias são vinculadas aos recursos Godot reais: restoration (heal), quick_hands (cooldown_reduction), heavy_axe (damage); cura só por escolha explícita. Os eventos de áudio apenas nomeiam oportunidades de sonorização; nenhum arquivo sonoro, licença ou mix foi criado.

O script tools/validate_unity_content_pack.py consulta o catálogo de upgrades e o gerenciador de saves Godot para detectar divergências; testes negativos comprovam a capacidade de rejeitar strings/IDs/esquemas incoerentes. Nenhum sistema de jogo, save, áudio ou idioma foi migrado nesta etapa.

**Pendências:** roteiro/localização revisados por pessoas; integração dos textos à UI; gravação/licenças de áudio; balanceamento, acessibilidade e QA no Galaxy A13; revisão cultural #38.
