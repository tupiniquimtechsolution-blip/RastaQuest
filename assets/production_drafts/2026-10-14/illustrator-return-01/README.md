# Retorno do ilustrador — 2026-10-14

Rodrigo forneceu três PNGs e pediu sua publicação no GitHub. Foram copiados sem alteração, em pasta separada dos estudos anteriores. Os nomes recebidos e hashes estão em `MANIFEST.json`; as cópias foram comparadas às origens por SHA-256.

| Arquivo organizado | Nome recebido |
|---|---|
| `protagonist-revised-study.png` | `Imagem do ChatGPT 14 de out. de 2026, 08_55_52-1.png` |
| `axe-carried-study.png` | `Imagem do ChatGPT 14 de out. de 2026, 08_55_59-2.png` |
| `axe-vertical-study.png` | `Imagem do ChatGPT 14 de out. de 2026, 08_56_14-3.png` |

Os três PNGs somam **1.994.039 bytes**. Nenhuma imagem foi editada, redimensionada, quantizada ou substituída. A inspeção visual das imagens fornecidas identifica protagonista revisado e dois estudos isolados do machado; não demonstra rotação rígida do mesmo desenho.

## Verificação de export

Todos os arquivos têm **1254×1254**, alpha intermediário e mais de 32 cores visíveis. O verificador existente (`tools/art_asset_gate.py`, frame128×128 e limite32) rejeita os três por dimensão, paleta e alpha. `TECHNICAL_GATE.json` preserva os resultados; `MANIFEST.json` distingue cores RGB/RGBA, registra níveis de alpha, bboxes e procedência informada.

Classificação: **estudos de produção fornecidos pelo usuário; export nativo pendente**. Publicar os arquivos não registra aceite artístico, cultural ou de direitos. A segunda orientação permanece um estudo, sem nomear o arquivo como rotação90 aprovada. Não foi fornecida fonte editável ou evidência de ferramenta/versão/termos do ilustrador neste lote.

Próximos gates: revisão do visual e consistência da arma; entrega nativa polida conforme o contrato do protagonista; marcadores e par de rotação verificáveis; modelo/paleta; revisão cultural/procedência; clips e QA Godot/Android. Nenhum asset foi promovido a `game/assets/`, e nenhum código ou gameplay foi alterado. O candidato Python anteriormente rejeitado permanece rejeitado e preservado.
