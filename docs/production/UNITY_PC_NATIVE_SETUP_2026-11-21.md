# Unity 6.3 — primeiro teste nativo no PC Windows

**Checkpoint:** 21/11/2026 · **Branch:** `tools/unity-windows-native-gate-20261121` · **Base:** PR #82.  
**Status:** execução local **pendente**; o script e os contratos de fonte não constituem prova de importação/build. **Release: NO-GO**.

## 1. O que já existe

O projeto `unity/` da branch contém uma **sala técnica de revisão**, não as 21 salas da campanha web. Possui `RastaQuest.Editor.ReviewBuild.Prepare`, `.Windows`, `.Android`, e `NativeReviewProbe` para capturas e relatório de runtime. O alvo é **Unity Editor 6000.3.27f1**; `ProjectVersion.txt` e `Packages/manifest.json` fixam a versão e Input System/uGUI. Os 274 PNG de Resources são revisão transitória e ainda exigem aceite de arte, direitos e cultura.

O bloqueio antigo da issue [#80](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80) era elevação de privilégios no Windows. O proprietário informou que **o computador atual pode instalar e testar**. Isso elimina a restrição declarada, mas não é evidência de que o Editor já tenha sido instalado.

## 2. Instalação do Editor e dos módulos

1. No PC Windows, instalar [Unity Hub oficial](https://unity.com/download), abrir o Hub e ativar a licença na **conta do proprietário**. Não compartilhar login, senhas ou chaves de licença no repositório/chat.
2. Na área **Installs**, instalar **exatamente 6000.3.27f1** ([release oficial](https://unity.com/releases/editor/whats-new/6000.3.27f1)). Se a versão não estiver listada no Hub, buscá-la no Unity Download Archive.
3. Na mesma instalação, selecionar **Android Build Support** e os submódulos **Android SDK & NDK Tools** e **OpenJDK**. Para Windows, o Editor já consegue o build de revisão padrão; instalar Windows Build Support/IL2CPP adicional quando necessário à estratégia de build final.
4. Verificar requisitos do Windows/GPU/disco conforme [Unity 6.3 requisitos oficiais](https://docs.unity.com/en-us/engine/6000.3/manual/get-started/install-and-upgrade/getting-started-installing-unity/system-requirements). Evitar SDK/NDK instalados manualmente de versões incompatíveis: preferir os módulos do Hub.
5. Instalar Git for Windows para clonar o repositório, se ainda não estiver disponível. Python 3 é opcional para os checks de fonte; o executor PowerShell usa apenas recursos do Windows/Unity instalados.

**Não abrir a raiz do repositório como projeto Unity.** O diretório correto do Editor é `RastaQuest\unity`.

## 3. Checkout seguro (nova pasta, sem substituir versões existentes)

No PowerShell:

```powershell
git clone --branch tools/unity-windows-native-gate-20261121 https://github.com/tupiniquimtechsolution-blip/RastaQuest.git RastaQuest-Unity-Review
cd RastaQuest-Unity-Review
powershell.exe -NoProfile -File .\tools\unity_native_gate_windows.ps1 -CheckOnly
```

Se o Editor está em outra pasta, passar `-UnityExe "D:\Unity\6000.3.27f1\Editor\Unity.exe"`. `-CheckOnly` verifica caminhos, Editor solicitado e módulos Android; **não abre Editor, não ativa licença e não comprova compilação**. Se o PowerShell bloquear scripts locais, seguir a política da organização, sem alterar permanentemente a política de execução.

Antes da importação, conferir (se Python instalado):

```powershell
py -3 -B tools\sync_unity_review.py --check
py -3 -B tools\check_unity_source_contracts.py
```

## 4. Importação e Play Mode

1. Unity Hub → **Add project from disk** → escolher `RastaQuest-Unity-Review\unity`.
2. Usar **6000.3.27f1**, resolver os pacotes e aguardar a importação; anotar e corrigir qualquer erro da Console. Não criar um `packages-lock.json` fictício. O Editor produzirá o real quando cabível.
3. No Unity, menu **Rasta Quest → Preparar sala Unity**. Abrir `Assets/Scenes/UnityReview.unity`, pressionar Play.
4. Conferir movimento A/D, salto duplo, J ataque, K defesa/parry, Chaser/Ranged, retrato/barra, sombra periférica, portal, três escolhas, cura explícita, derrota/reinício, idioma PT/ES e pausa. Comparar com a matriz [UNITY_PARITY_GATE_2026-10-24.md](UNITY_PARITY_GATE_2026-10-24.md).
5. **Fechar o Unity Editor** antes do executor batchmode: não abrir simultaneamente o mesmo projeto em duas instâncias.

## 5. Gerar os dois builds e o probe Windows

```powershell
powershell.exe -NoProfile -File .\tools\unity_native_gate_windows.ps1 -RunProbe
```

Para validar primeiro só a preparação e o Windows:

```powershell
powershell.exe -NoProfile -File .\tools\unity_native_gate_windows.ps1 -PrepareOnly
powershell.exe -NoProfile -File .\tools\unity_native_gate_windows.ps1 -SkipAndroid -RunProbe
```

**O que o executor faz automaticamente:** descobre o Unity.exe (ou recebe `-UnityExe`), confere versão da pasta e módulos, roda os métodos do Editor em processos batchmode separados com `-buildTarget` explícito, verifica códigos de saída e marcadores de sucesso dos logs, valida presença de `.exe` e `.apk`, calcula SHA-256 e grava relatório JSON. Com `-RunProbe`, abre o **Windows player com gráficos**, aguarda `NATIVE_REPORT.json` e valida ao menos oito capturas reais de cenas. Isso comprova um teste sintético de componentes em player nativo, **não** controles físicos Android, sensação de jogabilidade ou release.

Arquivos gerados, fora do controle de versão:

- `unity/Builds/Windows/RastaQuestUnityReview.exe` (+ pasta `_Data`).
- `unity/Builds/Android/rasta-quest-unity-review.apk` (desenvolvimento).
- `unity/Builds/NativeGate/<data-UTC>/NATIVE_GATE_REPORT.json`, logs e `NativeProbe/NATIVE_REPORT.json` com PNGs.
- `unity/Assets/Scenes/UnityReview.unity` e `Packages/packages-lock.json`, quando de fato gerados pelo Editor, devem ser **avaliados em diff antes de versionar**.

Se falhar, o relatório registra `status: FAIL` e o log por etapa; não marcar #80 como concluída até que importação real e builds passem. Se a máquina estiver sem módulos Android, é possível executar `-SkipAndroid -RunProbe` sem afirmar que o APK passou.

## 6. Android real e auditoria do APK

No dispositivo Galaxy A13 (ou outro Android), habilitar Depuração USB e autorizar o computador no aparelho. Depois de o build existir, executar:

```powershell
adb devices
adb install -r .\unity\Builds\Android\rasta-quest-unity-review.apk
```

Exigir prova de API/ABI, SDK, rotação, multitouch, pausas, quedas de FPS e temperatura. **Não instalar no celular por execução remota sem sua autorização.** Para checar estaticamente bibliotecas ARM64 e alinhamento de páginas, executar com Python:

```powershell
py -3 -B tools\verify_android_native_pages.py .\unity\Builds\Android\rasta-quest-unity-review.apk --output .\unity\Builds\NativeGate\android-pages.json
```

O resultado desse verificador de ELF/APK **não comprova compatibilidade num dispositivo de 16 KB**; confirmar por teste físico, ferramentas Android e Play Console quando aplicável. Não usar `tools/verify_android_test_apk.py` para Unity — aquele script exige bibliotecas específicas do APK **Godot** e pressupõe dados de CI do Godot.

## 7. Ponto de parada e aceite

**Gate #80 pode ser validado tecnicamente quando:** editor/version/modules presentes; importação sem erro; logs de Prepare/Windows/Android com marcadores e exit code 0; binários e hashes; execução de player nativo com relatório de probe e capturas (quando solicitado).

**Gate #81 só passa quando:** um jogador testa a build Unity **exata** no aparelho real, com captura de tela/vídeo e evidência de controls/rotação/estabilidade. O projeto ainda não implementa toda a campanha, Santuário, colecionáveis, árvore, assets finais, bosses e áudio no Unity. O web funciona como referência, não substitui essas entregas.

**Governança:** trabalhar em PR dependente do #82, sem merge na `main`, sem versionar `Library/`, `Temp/`, logs privados, APK, certificações de assinatura ou credenciais. Não declarar GOLD comercial com base neste gate.

**Referências:** [Unity 6.3 requisitos](https://docs.unity.com/en-us/engine/6000.3/manual/get-started/install-and-upgrade/getting-started-installing-unity/system-requirements) · [Unity build CLI](https://docs.unity.com/en-us/engine/6000.3/manual/building-and-publishing/build-command-line) · [SDK/NDK/JDK Unity 6.3](https://docs.unity.com/ko-kr/engine/6000.3/manual/platform-specific/android/getting-started/sdksetup/install-dependencies).
