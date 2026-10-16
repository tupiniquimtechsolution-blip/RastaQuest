# Validação do formato comercial Android — Agenor #9/#14 / Issue #50

O APK universal de teste continua no preset Android Debug, min24/target35. Dois presets adicionais usam o template Gradle oficial do Godot4.5.1, min24/target36, ARMv7+ARM64 e bibliotecas nativas sem compressão: Android Store Validation APK e Android Store Validation AAB. A versão do jogo/appID/save e o suporte Android mínimo não mudam.

A política Google Play consultada em16/10/2026 exige target36 para novos apps mobile desde31/08/2026. O override do Godot acima do target padrão35 gera aviso de compatibilidade ainda não homologada; export bem-sucedido não substitui testes de comportamento/aparelho. O motor permanece fixado em4.5.1.

## Evidência automatizada exigida

1. Export Gradle do APK de validação com certificado debug efêmero.
2. Assinatura, certificado, pacote/versão, SDK, permissões, ABIs e hash conferidos no APK.
3. Inspeção de TODAS as bibliotecas ARM64: ELF LOAD com alinhamento16KB e congruência de offset/endereço; libs sem compressão precisam também de offset ZIP16KB. O critério ELF16KB não é aplicado a ARM32.
4. Export real do AAB, bundletool1.18.2 validate, assinatura JAR verificada e certificado comparado ao debug do job, manifesto XML extraído e comparado ao contrato.
5. Gerar APK universal a partir desse AAB com bundletool e repetir verificações de assinatura/pacote/SDK/ABI/ELF/ZIP.
6. Preservar artefatos e manifestos ligados à fonte exata e ao run. O bundletool tem versão fixa e seu hash é registrado.

O verificador de páginas distingue inspeção estática de teste em ambiente16KB; sempre registra runtime_16k=not-tested e store_approval=pending. A assinatura JAR/Android desta etapa é debug: production_signing=false e Gold NO-GO.

## Preparação e limites

O workflow extrai android_source.zip do mesmo pacote oficial de templates4.5.1, sem versionar o Gradle gerado. AAB/APK de validação são gerados somente no runner e não são publicados na loja. Nenhuma chave comercial foi criada, pedida ou versionada.

Próximos gates: execução16KB e teste de ciclo de vida/instalação no Galaxy A13 e matriz, chave de produção sob controle do titular, validação de atualização, arte/áudio/licenças/revisão cultural finais e aprovação do candidato/loja. Não promover o certificado efêmero ou esse AAB debug para release comercial.

Referências: [política de target API](https://support.google.com/googleplay/android-developer/answer/11926878?hl=en), [Android16KB](https://developer.android.com/guide/practices/page-sizes), [exportador Android Godot4.5](https://docs.godotengine.org/en/4.5/classes/class_editorexportplatformandroid.html), [bundletool1.18.2](https://github.com/google/bundletool/releases/tag/1.18.2).
