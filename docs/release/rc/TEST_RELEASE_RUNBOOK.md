# Release de teste: regressão e APK verificável

Data: 2026-10-14. Perfil: Android debug / arm64, Godot 4.5.1, versão 1.0.0-rc.1 e esquema de save 2. A entrega executa a base jogável graybox da main; estudos de arte fora de `game/` não são promovidos. Gold continua NO-GO, conforme os critérios canônicos.

## O que precisa ficar verde

1. Repository Health.
2. Godot Project CI: import, boot e os onze testes existentes, incluindo validação de save malformado e recuperação de previous-good.
3. Gold Preflight: a regressão completa, proteção de chaves e manutenção da decisão NO-GO.
4. Android Technical RC: export e verificação do APK real antes do upload.

Abrir o PR de preparação dispara os workflows existentes; não há criação de tag, publicação em loja ou assinatura de produção. Os checkouts de PR continuam usando o commit de merge de teste do GitHub. Godot, Gold e Android conferem `git rev-parse HEAD == GITHUB_SHA`; os logs e o manifesto identificam o código efetivamente executado, que pode diferir do SHA da branch do PR.

## Pacote para testar

O artifact `rasta-quest-1.0.0-rc.1-debug` inclui:

- APK;
- `SHA256SUMS.txt`, com nome relativo do arquivo;
- `TEST_RELEASE_MANIFEST.json`, com commit de origem, run/attempt, versão, pacote, ABI, permissões reais, tamanho e hash;
- saída do apksigner e badging do AAPT2.

A verificação compara pacote/versão/ABI/permissões ao manifesto RC, testa integridade ZIP e confirma que a assinatura usa o certificado debug gerado naquele job. Divergências falham a pipeline; não são aceitas silenciosamente. O APK não é editado após assinatura. Chaves privadas permanecem temporárias no runner e não entram nos artifacts.

Logs Godot e Gold são artifacts separados, preservados inclusive quando testes falham. A retenção pedida é de 30 dias, sujeita à política do repositório; consultar `expires_at` no artifact real. A referência histórica ao APK de 6 de outubro continua nos manifestos RC/Gold e não descreve o novo pacote. Seu prazo anteriormente informado terminava em 13/10/2026.

## Execução no aparelho

Baixar o artifact do run verde, descompactar e conferir o SHA-256 do APK contra o manifesto. Registrar build/run/hash antes de instalar em aparelho de teste Android compatível. Executar ANDROID_DEVICE_ACCEPTANCE.md e PLAYTEST_PROTOCOL.md: controles com dois polegares, partida pelos três biomas/boss, morte/retorno, save/configurações, reinício e background/resume; medir FPS/temperatura e registrar falhas.

O certificado debug muda entre runs. Um APK instalado com outro certificado pode impedir upgrade; essa rodada não comprova upgrade/migração em dispositivo. Não remover automaticamente uma instalação ou seus saves para contornar o conflito. Upgrade aceito exige um candidato com certificado consistente e evidência própria.

## Limites de aceite

CI verde e assinatura debug verificada permitem a rodada técnica de testes, mas não fecham desempenho em hardware, três jogadores externos, vinte runs Beta, game feel, produção artística/áudio, revisão cultural, direitos, material de loja ou assinatura de produção. Não alterar o Gold para GO nem afirmar que a versão 1.0 está liberada.

Referências das ferramentas: [Android apksigner](https://developer.android.com/tools/apksigner), [AAPT2 dump/badging](https://developer.android.com/tools/aapt2), [actions/checkout — checkout de PR](https://github.com/actions/checkout). Nenhuma dependência adicional é instalada no projeto por esta mudança.
