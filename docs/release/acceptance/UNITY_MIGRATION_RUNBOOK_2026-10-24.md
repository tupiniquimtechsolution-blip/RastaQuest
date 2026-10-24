# Pacote D — Roteiro de QA/homologação da migração para Unity

**Data:** 2026-10-24. **Estado:** roteiro + validador de plano; não houve Editor, Play Mode, build, assinatura, dispositivo nem aceite de arte nesta rodada. Fonte de dados: [UNITY_MIGRATION_EVIDENCE_PENDING.json](UNITY_MIGRATION_EVIDENCE_PENDING.json).

## Antes de abrir o Editor
1. Confirmar commit de trabalho, PR #82 (base Godot), PR #83 (pacotes pré-Unity) e árvore sem mudanças locais não rastreadas.
2. Executar verificação de integridade de 274 PNGs, contratos de assets, traduções, pacote de migração e regras C# puras.
3. Coletar versões pinadas de Unity, Input System, uGUI; comparar com a matriz de paridade em docs/production/UNITY_PARITY_GATE_2026-10-24.md.
4. Registrar explicitamente que as checklists preenchem o **plano**, não comprovam runtime.

## Gate #80 — instalação/importação/compilação
1. No Windows com permissão administrativa, terminar Unity Hub e Editor 6000.3.27f1, Android Build Support/SDK/NDK/OpenJDK. Titular autentica/licencia pelo Hub. Não versionar contas, chaves ou tokens.
2. Abrir a pasta unity/ pelo Hub, anotar resolved Package-lock/Editor.log; executar menu **Rasta Quest → Preparar sala Unity**.
3. Sem erros de compilação, inspecionar a sala em Play; criar build Windows, anotar logs e SHA-256; depois gerar APK Android de desenvolvimento com ferramentas reais.
4. Nunca usar hashes do pacote Godot como evidência de runtime Unity.

## Gate #81 — Android físico e interação
- Instalar **o hash exato** do APK de desenvolvimento no Galaxy A13. Documentar versão Android, resolução, modelo, carga e estado térmico.
- Registrar esquerda/centro/direita no analógico, salto por gesto acima, ataque+defesa simultâneos, parry, reflexão e contato com paredes sem loops.
- Repetir pausa/retomada, perda/ganho de foco, multitouch com dedos ainda pressionados, ambos os lados em paisagem, safe area e HUD com vida fracionária (4.5/5).
- Eliminar quatro inimigos, provar recompensa tripla, cura apenas se selecionada e portal único. Comparar movimento, salto, fase de machado, animação e câmera com a13.3.
- Registrar imagens e logs **capturados pelo aplicativo nativo**, não por concept/mockup. Confirmar desempenho sustentado, memória, estabilidade e queda térmica.
- Verificar APK real: minSdk 25, targetSdk 36, ARMv7/ARM64, GLES3 e alinhamento ELF/ZIP 16 KB. Usar tools/verify_android_native_pages.py quando o pacote produzido tiver formato suportado; completar teste de instalação em ambiente 16 KB, AAB/splits quando necessário.
- Não concluir pelo próprio script de plano: evidência precisa de revisão humana e status atualizado na issue.

## Arte e produção
#35–#38 exigem sprites/camadas reais, legenda de proveniência, direito de uso e consulta cultural registrada. Relacionar screenshots do build nativo ao hash exato do asset e do commit. A arte ilustrada conceitual não satisfaz direitos/cultura nem está integrada ao jogo.

## Gold / publicação
- Comparar o protótipo Unity com toda a campanha/saves/áudio do Godot: hoje não há paridade. Não publicar, assinar release, remover o Godot ou declarar Gold GO.
- Este plano exige estados individuais PENDING/BLOCKED; o validador de esquema até poderia checar campos preenchidos em registros futuros, mas **não autentica a veracidade das evidências** e deliberadamente não autoriza GO.
- O controle Gold original continua em docs/release/acceptance/COMMERCIAL_EVIDENCE_GUIDE.md e tools/validate_commercial_evidence.py, que têm autoridade sobre a homologação formal.

## Execução do validador
```sh
python -B tools/validate_unity_migration_evidence.py
python -B -m unittest discover -s tools -p test_validate_unity_migration_evidence.py -v
```
