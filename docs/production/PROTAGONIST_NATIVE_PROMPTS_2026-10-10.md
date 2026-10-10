# Rasta Quest — prompts para o modelo nativo do protagonista
Data: 2026-10-10. TASK-119 / Issue #35. Base: direção visual v03 aprovada por Rodrigo.

Use os prompts na ordem abaixo. Anexe a imagem protagonist-neutral-study-v03.png ao ilustrador; somente escrever o nome do arquivo não disponibiliza a referência. A referência aprovada tem SHA-256 152940d341a63fa65b64c8043675b4c63bfd5a19021e4f109c12fc0352279edd. Sua aprovação visual não transforma o PNG 1254×1254 em um sprite nativo.

## 1 — Modelo neutro nativo

Atue como pixel artist de produção para um action-platformer 2D. EXECUTE AGORA a criação de um único modelo neutro nativo do protagonista de Rasta Quest. Entregue a imagem e os arquivos solicitados; não responda apenas que adotou o contrato.

REFERÊNCIA
A imagem anexada protagonist-neutral-study-v03.png é a direção visual aprovada por Rodrigo. Reconstrua essa aparência na grade de produção, preservando rosto, volume corporal, roupa, dreadlocks e silhueta do machado. A referência é um estudo ilustrado; não recorte ou reduza automaticamente a imagem para obter o sprite.

PERSONAGEM E POSE
Homem negro de pele escura, físico atlético compacto, rosto legível e postura confiante. Perfil lateral voltado à direita, pose neutra com pés apoiados. Dreadlocks grossos presos atrás da cabeça; faixa vermelho/amarelo/verde acima dos olhos. Roupa clara sem mangas, correia marrom diagonal, tecido vermelho na cintura, calça verde e botas marrons, conforme a referência. Machado de duas lâminas simétricas segurado naturalmente na altura da cintura, com cabeça da arma visível e separada do corpo. Sem colar, brincos, contas, novas marcas corporais ou eletricidade.

CONSTRUÇÃO
Desenhe volumes com grupos de pixels deliberados: rosto reconhecível, tórax sólido, braços e mãos com massa, botas legíveis e mechas curvas espessas. A simplificação deve preservar a identidade. Evite membros de palito, círculos de articulação, dreadlocks em leque triangular ou aparência de manequim.

CONTRATO NATIVO
- PNG realmente 128×128 pixels; um pixel desenhado equivale a um pixel do arquivo.
- Corpo em repouso com 52 px de altura e até 32 px de largura, excluindo cabelo e arma.
- Origem de integração (64,64); contato das solas em y=90.
- Seis clusters principais de dreadlocks, envelope de estudo 18×20 px em repouso. São massas visuais, não a quantidade real de fios.
- Machado: cabo de estudo 48 px e cabeça simétrica com envelope de estudo 32×18 px. Documente a orientação desse envelope e os marcadores; preserve proporções rígidas.
- Até 32 cores RGB visíveis, alpha somente 0 ou 255, fundo transparente real.
- Sem antialiasing, blur, gradientes, sombras externas, molduras, textos, guias ou paleta desenhada no PNG.

PALETA
Proponha uma paleta com códigos HEX, preservando os materiais da referência. A spec oferece como ponto de partida: pele #24150F/#4B2C20/#754631; cabelo #151310/#302A22; faixa #C8392B/#E8BD42/#39854B; calça #21432D/#397044; couro/cabo #35251C/#795237; aço #455660/#9BAEB6. Inclua os tons necessários de tecido claro e reutilize cores quando a leitura permitir. Esta é uma proposta; não declare paleta final aprovada.

ENTREGA
1. player_neutral_model_01.png, único personagem completo.
2. Fonte editável em camadas, se sua ferramenta oferecer: corpo/roupa, cabelo e arma.
3. Relatório externo com tamanho real, paleta HEX, origem, limites do corpo/cabelo/arma, contatos dos pés, posição da mão no cabo e centro visual da cabeça da arma.
4. Identificação da ferramenta/autoria e limitações reais.

Se sua ferramenta não consegue exportar 128×128 de verdade, informe a limitação. Uma saída maior deve ser identificada como ESTUDO, nunca como sprite final, ainda que pareça pixel art. Não invente medições ou arquivos editáveis. Não produza animações nesta etapa.

## 2 — Machado isolado e consistência com o modelo

Atue como pixel artist de produção. EXECUTE AGORA o estudo nativo do machado duplo usado pelo protagonista de Rasta Quest, para conferir sua geometria antes das animações.

INPUTS
Use a imagem v03 aprovada como referência visual e o modelo neutro produzido na etapa anterior como referência de encaixe. Preserve o mesmo machado; não crie uma nova arma ou modifique sua identidade.

DESENHO
Duas lâminas simétricas e reconhecíveis, aço prateado com leitura clara, núcleo dourado simplificado e cabo marrom reto. Preserve o volume e a silhueta aprovados, agrupando ornamentos em poucos pixels. Não acrescente símbolos religiosos, escrita, runas, joias, eletricidade ou novos adornos.

MEDIDAS E ENCAIXE
- Trabalhe na mesma densidade: um pixel de arte = um pixel do arquivo.
- Cabo de estudo com 48 px; cabeça simétrica com envelope de estudo 32×18 px.
- Registre os eixos usados para medir a cabeça, o ponto de pega e o centro visual da cabeça. Não apresente esse centro como centro físico de massa.
- Mostre a orientação do modelo neutro e uma rotação de 90° em arquivos separados, preservando as mesmas medidas. Limpe bordas de pixel após a rotação; não escale a arma para caber.
- Verifique que a mão encontra o cabo e que a cabeça da arma fica separada do corpo.
- Se as medidas de estudo exigirem mudar a silhueta aprovada, documente o conflito e a correção proposta antes de tratar o resultado como definitivo.

EXPORTAÇÃO
Entregue weapon_double_axe_neutral_01.png e weapon_double_axe_rotation_90_01.png, cada um em canvas transparente 128×128. Use a mesma paleta proposta para o personagem; o conjunto corpo/arma deve respeitar até 32 cores visíveis. Alpha somente 0/255; sem suavização, brilho difuso, cenário, texto ou marcações dentro das imagens.

Entregue os marcadores e dimensões num relatório externo. Não gere folha técnica no lugar dos dois arquivos isolados, não altere colisões ou hitboxes do jogo e não inicie ataques animados. Informe limitações de exportação nativa em vez de chamar uma ilustração ampliada de arquivo final.

## 3 — Validação e relatório de correções

Atue como revisor técnico de pixel art. INSPECIONE AGORA os arquivos reais entregues nas etapas anteriores, comparando o modelo com a imagem v03 aprovada por Rodrigo. Não gere uma nova arte durante esta revisão.

VALIDAÇÃO DE ARQUIVOS
Verifique por leitura do arquivo, não pelo nome ou aparência:
- dimensões PNG 128×128;
- quantidade de cores RGB dos pixels visíveis, com limite de 32 para o conjunto personagem/arma;
- alpha somente 0 e 255, com fundo transparente real;
- ausência de pixels soltos, halos e bordas semitransparentes;
- integridade dos arquivos e SHA-256, se houver ferramenta para calcular.

VALIDAÇÃO DO MODELO
Confira corpo 52 px, largura até 32 px excluindo cabelo/arma, origem (64,64), solas em y=90 e alinhamento da pose neutra. Compare rosto, volume corporal, roupa, botas, massa dos dreadlocks e machado com a direção aprovada. Confira os seis clusters de cabelo e o envelope de estudo 18×20; registre a medição e qualquer desvio.

Confira cabo 48 px, cabeça de estudo 32×18 com eixos documentados, simetria, ponto de pega, centro visual da cabeça e consistência da rotação. Sinalize interseções artificiais entre mão, cabo, corpo e lâminas. Não confunda marcadores visuais com geometria física do jogo.

LEITURA VISUAL
Apresente prévias separadas do PNG de produção: escala 1× e ampliação 4× com nearest-neighbor, em fundos claro e escuro. Identifique essas prévias como visualizações. Elas não demonstram integração, movimento ou teste em aparelho Android.

RELATÓRIO
Entregue uma tabela Critério / Medição ou evidência / PASS, FAIL ou NÃO VERIFICADO. Liste correções por prioridade e indique quais arquivos precisam de ajuste.

Rodrigo aprovou a direção visual v03. Registre isso corretamente, mas não atribua automaticamente esse aceite ao novo export. Licença, revisão cultural específica, marketing e QA Android possuem registros próprios. Não declare testes, autorização ou autoria que não possam ser comprovados.

Se todos os critérios técnicos passarem, classifique como CANDIDATO NATIVO VALIDADO TECNICAMENTE. Se algum falhar, classifique como ESTUDO ou EXPORT REPROVADO e detalhe o motivo. Não mova arquivos para game/assets, não altere gameplay e não autorize animações ou publicação por conta própria.
