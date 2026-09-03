# Tupiniquim — Claude Code Project Baseline

Projeto: `RastaQuest`

Estas instruções são persistentes e complementam requisitos específicos do projeto. A fonte central da empresa é `tupiniquimtechsolution-blip/Tupiniquim_AI_Dev_Studio`, pasta `docs/AI_TOOLBOX/`.

## Fluxo obrigatório
- Investigue o estado real do repositório antes de editar; não invente arquivos, dependências, testes ou infraestrutura.
- Respeite planejamento, arquitetura e critérios de aceite já existentes.
- Limite mudanças ao escopo solicitado. Não adicione funcionalidades “porque seria legal”.
- Antes de excluir arquivos, alterar schema/dados reais, fazer migração irreversível, force-push, publicar externamente ou instalar dependência estrutural, peça aprovação.
- Após mudanças: execute os checks disponíveis (lint, typecheck, testes, build e verificações de segurança) e registre evidências.

## Baseline de segurança
- Nunca exponha ou versione secrets, tokens, cookies, senhas ou chaves privilegiadas.
- Autenticação e autorização sensíveis devem ser verificadas no servidor; esconder rota no frontend não é controle de acesso.
- Valide entradas e considere XSS, CSRF, SQL/command injection, SSRF, path traversal e abuso conforme a stack.
- Aplique rate limiting a login, recuperação, formulários públicos, webhooks e endpoints caros.
- Não vaze stack trace, segredo ou dado pessoal em produção/logs.
- Revise CORS, cookies, HTTPS, headers, firewall/WAF/CDN, portas expostas e variáveis de produção.
- Mantenha rollback e backup verificáveis quando houver banco ou deploy crítico.
- Pentest com Strix ou ferramenta equivalente somente em sistemas próprios/autorizados.

## Toolbox da empresa
Use somente quando houver fit técnico:
- UI/UX: `nextlevelbuilder/ui-ux-pro-max-skill`
- Prompts: `nidhinjs/prompt-master`
- Pesquisa/web/social: `Panniantong/Agent-Reach`
- Pentest autorizado: `usestrix/strix`
- Software agent-native/CLI: `HKUDS/CLI-Anything`
- Agentes/RAG: `Shubhamsaboo/awesome-llm-apps`
- Instagram comment-to-DM: `diwenne/openreply`
- TTS local: `kyutai-labs/pocket-tts`
- Mídia generativa: `Anil-matcha/Open-Generative-AI`
- Inferência Kimi experimental em C: `FareedKhan-dev/kimi-k3-in-c`

Referências externas não são dependências automáticas. Antes de adotar, verifique licença, compatibilidade, atividade, segurança e necessidade real.

## Entrega
Toda implementação/revisão deve terminar com: arquivos alterados, verificações executadas, riscos restantes, referências externas utilizadas e próximo passo.
Converta achados relevantes em GitHub Issues pequenas, verificáveis e priorizadas.
