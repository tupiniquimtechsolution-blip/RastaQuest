# Pacote B — Ilustração e interface: contratos de produção Unity

**Data:** 2026-10-24. **Estado:** especificação verificável, **sem sprite/rig/tile exportado nesta etapa**. Link: [PRODUCTION_CONTRACT.json](../../assets/production_drafts/2026-10-24/unity-illustrated-production/PRODUCTION_CONTRACT.json).

## Direção vigente
Nova arte **2D ilustrada e detalhada**, identidade original, contraste legível no Galaxy A13. A anterior pixel art e seus 274 PNGs são **referência funcional/transição**, não arte comercial. Nunca recortar personagens de uma pintura com fundo/iluminação já compostos como se fossem sprites. Manter personagem humano de pele escura, dreadlocks atados, faixa vermelho/amarelo/verde, calças verdes, botas castanhas, machado duplo simétrico e eletricidade ciano contida. Consultar [ADR 0003](../adr/0003-unity-illustrated-direction.md) e [proveniência do estudo](../../assets/production_drafts/2026-10-24/illustrated-direction-v01/PROVENANCE.json). Nenhuma estética de outra franquia é recurso de produção.

## Sequência de entrega visual
1. **Personagem #35:** ilustrar vista lateral neutra, vistas adicionais suficientes para consistência, modelo de rosto/cabelo, mão/grip, camadas corpo/dreadlocks/machado; teste de silhueta monocromático. A escala em cena, tamanhos definitivos, pivôs e paleta continuam a ser aprovados **sobre renders e screenshots reais**. Planejar idle, run, jump, fall, três golpes, golpe aéreo, guard, parry, hurt, death, lightning, portal, sem assumir que o motor anima isso.
2. **HUD #81:** preparar layout de retrato e barra horizontal **de vida real**, pausa, analógico e três botões com áreas seguras, toque simultâneo, rótulos PT/ES e modo de efeitos reduzidos. Não adicionar mana, vidas, moedas ou estatísticas não implementadas. Testar legibilidade a 1280×720, 640×360 e A13 paisagem nos dois sentidos.
3. **Floresta #36:** exportar céu e copa distante, ruínas no midground, terreno passível de colisão em camada separada e foreground sem oclusão da faixa de combate; pintar tiles com bordas de colisão determinísticas; a métrica Godot 32×32 não trava automaticamente a densidade artística Unity.
4. **Chaser/Ranged #37:** modelos lado a lado no tamanho de combate; separar arma, escudo/projétil, aviso de ataque e corpo; testar aviso em cinza, telegraph timing real e contraste contra eletricidade azul antes dos outros papéis.
5. **Castelo/Cavernas:** após a Floresta validada, revisar contrastes e variações próprias; efeitos de fissura não devem substituir todos os materiais por magenta. Hub e chefes permanecem entregáveis futuros.

## Formatos e aceites
- Fonte original editável em camadas e export PNG transparente por pose, com hash SHA-256, autor/ferramenta/data, licença/termos e proveniência por recurso. Nada disso foi gerado automaticamente apenas por adicionar o contrato.
- Marco/anchor: pé esquerdo/direito, empunhadura, centro do machado, posição de olhos, volumes de dreadlocks e máscara de colisão **separada** da figura. Momento de dano da lógica governa a animação, nunca o contrário.
- Arquivos da mesma pose: `<actor>_<clip>_<frame>.png`; manter um atlas ou rig apenas após importação real. Não misturar pixel sampling da transição com antialias natural da nova ilustração.
- Antes de promoção: visual humano comparado lado a lado, valores de escala/pivô congelados, direitos resolvidos, revisão cultural #38 e smartphone real. O script [validate_unity_art_contract.py](../../tools/validate_unity_art_contract.py) só prova que esta **especificação** é internamente coerente.

## Status dos gates
#35 personagem: PENDENTE · #36 Floresta: PENDENTE · #37 Chaser/Ranged: PENDENTE · #38 revisão cultural: PENDENTE · #81 render/touch real: PENDENTE.

**Sem aprovação implícita e sem importação automática do conceito para runtime.**
