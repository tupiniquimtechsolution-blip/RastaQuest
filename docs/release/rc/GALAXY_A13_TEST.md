# APK de teste universal — Galaxy A13

Data: 16/10/2026. Rodrigo informou que o APK anterior retorna incompatibilidade ao instalar no Galaxy A13, modelo digitado `SM-A1325M/DS`, One UI6.1, Android14, Knox3.10/API37. A identificação Samsung documentada próxima é SM-A135M; o modelo exato e a lista de ABIs do aparelho não foram medidos, portanto não são corrigidos por suposição.

## Diagnóstico fundamentado

O APK anterior (`ac49d23fa8ea65b2cbd2092c434b90290f1e69c6df2bc71d5bd6e8c27e332f60`) contém somente `arm64-v8a`, mínimo Android API24 e target35. O requisito mínimo não exclui Android14/API34. Sem o código do instalador ou `ro.product.cpu.abilist`, a causa não está comprovada; incompatibilidade de ABI é uma hipótese que a nova configuração aborda.

Um processador de 64 bits não prova que o Android instalado aceite apps ARM64. A variante universal evita depender dessa suposição e contém `armeabi-v7a` e `arm64-v8a`. A versão API37 do Knox é independente da API34 do Android14. O target35 do app não significa que o mínimo seja Android15.

## Configuração e verificação

- Preset `Android Debug`: ARMv7 e ARM64 ativados; x86 desativado.
- Renderer GL Compatibility existente preservado.
- Pacote `com.tupiniquimtechsolution.rastaquest`, versão1.0.0-rc.1, versionCode1000001 e save schema2 preservados.
- Nome para a nova entrega: `rasta-quest-1.0.0-rc.1-universal-debug.apk`.
- Manifesto de contrato: mínimo24, target35, alvo de teste Android14/API34; conferir valores reais no APK antes do upload.
- O verificador exige ambas as bibliotecas `libgodot_android.so` e headers ELF de ARM32/machine40 e ARM64/machine183, além de assinatura/certificado, pacote/versão, permissões e hash.
- O smoke de preparação RC verifica que o preset possui as duas arquiteturas. Testes adicionais rejeitam falta/troca de biblioteca e intervalo Android que exclua API34.

## Reteste necessário

Usar o APK com `universal` no nome. Registrar se instala e se abre; depois verificar controles, save, background/resume e desempenho no aparelho. A existência das duas ABIs e o passe de CI não comprovam instalação ou FPS nesse Samsung.

Se a mensagem de incompatibilidade continuar, obter o texto completo/captura da falha e confirmar o modelo em Sobre o telefone. Com ADB já autorizado e disponível, os dados úteis são `getprop ro.product.cpu.abilist`, `getprop ro.build.version.sdk` e o código retornado por `adb install -r`. Não presumir esse código sem executar a instalação. Não alterar Knox, não fazer root e não desinstalar uma versão/saves automaticamente.

Assinatura debug permanece efêmera; conflito com uma instalação de outro certificado requer diagnóstico separado. Produção artística, revisão cultural/direitos, testes físicos e distribuição final continuam pendentes; Gold NO-GO preservado.

Referências oficiais: [Godot4.5: ABIs ARMv7/ARMv8](https://docs.godotengine.org/en/4.5/tutorials/export/exporting_for_android.html#optimizing-the-file-size), [Android14 / SDK34](https://developer.android.com/about/versions/14/setup-sdk), [Samsung: SM-A135M e Android14](https://doc.samsungmobile.com/SM-A135M/022574220404/eng.html).
