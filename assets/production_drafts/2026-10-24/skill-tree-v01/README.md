# Árvore de habilidades — Raízes do Trovão

> Versão anterior preservada. A referência atual é a [v02](../skill-tree-v02/README.md), com Técnicas de Combate no lugar do ramo de melhoria do machado. Equipamentos continuam na aba própria.

Prancha visual do menu de pausa de Rasta Quest, criada a pedido do usuário em 24/10/2026. Mantém a direção ilustrada de Akane Xangô, o metal dourado sobre pedra escura, os detalhes rasta e os efeitos de trovão azuis dos menus originais. É uma proposta visual completa de navegação e progressão, sem implementação no Unity/Godot.

## Composição

- [Tela da árvore no menu de pausa](skill-tree-pause-menu.png).
- [Prancha de detalhe dos cinco ramos](skill-tree-branches.png).

Na tela de pausa, a progressão sobe da raiz para o topo; na prancha de detalhe, a lista é lida de I a V, de cima para baixo. São duas vistas das mesmas 25 habilidades, não 50 habilidades diferentes.

- Aba **Habilidades** no menu de pausa, junto de Equipamentos, Coleção e Opções.
- Akane e indicação de melhorias permanentes à esquerda.
- Árvore central com cinco ramos e cinco habilidades por ramo: **25 habilidades**, mais um emblema estrutural de Raiz Ancestral, que não é uma habilidade comprável adicional.
- Painel de detalhes à direita, com ícone, descrição, pré-requisito, custo em essência e ação de desbloqueio.
- Estados desbloqueado, disponível, bloqueado e foco de seleção. Usar também check, sinal de mais, cadeado e contorno, sem depender exclusivamente da cor.
- Navegação por controle e proposta de toque: selecionar nó por toque, consultar descrição, confirmar pelo botão visível e voltar. Arrastar/ampliar a árvore se necessário em telas menores; isso é intenção de interação, não funcionalidade já entregue.

## Ramos propostos

| Ramo | Sequência de habilidades |
|---|---|
| Vigor Ancestral | Raízes Vivas → Fôlego Ancestral → Corpo Firme → Coração da Terra → Vigor Pleno |
| Machado Sagrado | Empunhadura → Corte Firme → Ritmo de Combate → Golpe do Trovão → Maestria do Machado |
| Movimento do Guerreiro | Passo Leve → Salto Preciso → Avanço Ágil → Travessia Fluida → Liberdade de Movimento |
| Defesa e Equilíbrio | Guarda Firme → Defesa Precisa → Escudo do Trovão → Retorno de Energia → Guardião do Equilíbrio |
| Poder da Tempestade | Centelha → Elo Elétrico → Onda do Trovão → Fúria da Tempestade → Maestria Ancestral |

Os nomes e as conexões são propostas novas de design visual, inspiradas no material recuperado. Não representam aprovação de efeitos, custos, atributos ou novas mecânicas de combate. [SKILL_TREE_DESIGN.json](SKILL_TREE_DESIGN.json) enumera os 25 nós, níveis e dependências de maneira inequívoca para a próxima etapa.

## Progressão e leitura

A árvore representa desbloqueios permanentes de Akane. Equipamentos permanecem na sua aba e bênçãos temporárias continuam em Poderes da run. Não consumir búzios como moeda da árvore: cinco búzios reais por sala continuam concedendo uma vida extra. A essência vermelha já estabelecida é apenas a moeda conceitual proposta; custos e equilíbrio ficam **a definir**.

O exemplo selecionado é Escudo do Trovão, com Defesa Precisa como pré-requisito. A prancha não fixa dano, porcentagens, níveis de jogador ou preços. Nenhum sistema de reset, respec, loja ou nova moeda foi adicionado.

## Referências diretas

- [Menu de equipamentos, atributos e poderes da run](../recovered-chat-originals-v01/ui/equipamentos-atributos-poderes-run.png).
- [Lore de Akane Xangô e progressão de poderes](../recovered-chat-originals-v01/world/lore-akane-xango.png).

Os originais continuam intactos. A nova geração usa `image_gen.imagegen` e é salva separadamente; o prompt, referências e hashes acompanham o pacote.

## Direção atual e limites

**Tudo em 2D por enquanto**, incluindo salas, chefes e Santuário Ancestral. A avaliação de transições para 3D está adiada por instrução do usuário. A ilustração do cenário de fundo segue as referências e não muda a dimensão da jogabilidade.

Entregue nesta etapa: desenho da interface, proposta dos ramos, estados e organização de detalhes. Próxima etapa: revisão visual e montagem da interface em engine, com decisões de efeito/custo, legibilidade mobile, navegação e persistência. Não declarar a árvore interativa, navegável no jogo ou integrada ao save a partir desta prancha.

Revisão artística/cultural, direitos, tipografia pequena e acessibilidade ainda precisam ser concluídos para produção. Não houve merge, compilação Unity, Play Mode, APK ou release.
