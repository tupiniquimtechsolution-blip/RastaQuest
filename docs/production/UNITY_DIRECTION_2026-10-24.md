# Entrega de preparação Unity — 24/10/2026

## Resultado verificável

- Direção recebida de Rodrigo: Unity e ilustração 2D detalhada, com identidade própria. [Decisão](../adr/0003-unity-illustrated-direction.md).
- [Pesquisa técnica](../product/COMBAT_ART_REFERENCE_STUDY_2026-10-24.md): fontes primárias, limites da informação pública, leitura das quatro referências, regras e backlog próprios.
- [Estudo visual original](../../assets/production_drafts/2026-10-24/illustrated-direction-v01/forest-art-target-v01.png), prompt e procedência; imagem não aprovada individualmente e não usada como cenário jogável.
- [Projeto Unity de revisão](../../unity/README.md): fontes do núcleo C#, componentes de movimento/combate/IA/input, HUD com retrato e barra, sombras periféricas, portal com três escolhas e alternância de ambiente, importador, construtor de cena/build e probe nativo ainda não executados.
- 274 PNGs transitórios copiados sem operação de pixels; manifest de hashes e verificador de sincronismo.
- 21 asserções do núcleo C# passaram no compilador .NET Framework local; espelhadas em CI de contratos de fonte. Não são testes de Unity/Play Mode.

## Instalação e bloqueio concreto

Unity Hub **3.22.4.65535** instalado pelo winget oficial. O instalador MSIX teve hash SHA-256 verificado pelo gerenciador: `386ee4338b6740aee00e7747fe6430d07ad7de38574d7a47878dbdde5697ebc3`.

O editor escolhido é **6000.3.27f1**. O Hub iniciou download do editor e componentes Android. A instalação do editor retornou **The Windows elevation prompt was cancelled or timed out**. Uma segunda tentativa após selecionar pasta do usuário repetiu a falha. Não afirmar que todos os módulos foram baixados ou instalados. Em resposta à necessidade da confirmação do Windows, Rodrigo informou: **Não tenho acesso de administrador agora**.

Portanto: editor, importação real, resolução/lock de pacotes, compilação de componentes Unity, execução, capturas nativas, build Windows e APK Android estão **PENDENTES**. Licença/conta não foram declaradas ativas. O teste C# puro passou independentemente desse bloqueio. Não houve mudança no aplicativo instalado no celular.

## Arquivos e riscos

`unity/` contém o protótipo separado; `tools/sync_unity_review.py` verifica a cópia e gera o bridge; `.github/workflows/unity-source.yml` valida apenas contratos. Canon, ADR, README e estado do projeto registram o novo alvo, preservando o Godot entregue e o histórico anterior.

Riscos a resolver ao executar o editor: importação/configuração nativa, APIs e lock exato de pacotes, alinhamento de equipamentos, animações, colisões, UI em diferentes proporções, input multitouch, transição/cura e desempenho. O protótipo ainda não possui paridade da campanha, saves, chefes, áudio, acessibilidade e toda a localização do Godot. As artes atuais continuam transitórias. URP/luzes/sombras dinâmicas e novos ativos ilustrados não foram implementados por mera mudança de motor.

## Próximo gate

[Issue #80 — instalação/importação/build](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/80) depende do acesso de administrador. Depois, [Issue #81 — prova da primeira sala e HUD no A13](https://github.com/tupiniquimtechsolution-blip/RastaQuest/issues/81). As issues #35–38 continuam abertas para arte/cultura e #50 mantém o gate Android API 36/alinhamento 16 KB. Registro do PR e CI fica na conversa e no checkpoint de entrega; o rascunho não é integrado enquanto o código Unity não puder ser validado.

**GREEN comercial: NO-GO.** Aprovação da direção não é aceite dos ativos, da migração ou da versão final.
