# Rasta Quest — Compatibilidade do save Godot → Unity

**Estado:** protocolo de migração prévio, **NÃO IMPLEMENTADO**. Fonte técnica: game/scripts/save/save_manager.gd na main dd12bb3.

- Esquema real atual do Godot: version 2, limite 1 MiB, campos schema_version, meta_shards, unlocks, settings, completion_flags.
- Configurações: screen_shake, reduced_flashes, vibration, music_volume, sfx_volume, touch_scale, locale.
- Persistência Godot usa user://rasta_quest_save.json, arquivo de backup .bak.json, estágio .tmp, validação, normalização e recuperação. O sandbox Unity com outro application ID **não** pode presumir acesso aos arquivos privados do Godot.
- Preservar o APK Godot e seus dados. Não sobrescrever nem excluir arquivos. Não adicionar exportação/importação silenciosa.
- Só propor importação **opt-in** após verificar mecanismo viável em Android, compatibilidade, privacidade e autorização; testar leitura v1/v2, JSON inválido, arquivo truncado, >1 MiB, unicode, booleanos, floats não finitos, arrays inválidos e backup danificado.
- Na futura implementação, usar validação estrita, escrita temporária, backup recuperável, rollback, hashes de fonte/artefato, sem colocar saves ou informações pessoais no Git.
- Rodar em aparelho real com instalação limpa, upgrade, reinício, background, vitória, morte e mudanças de opções.

O validador de fonte detecta divergência nas **chaves e versões registradas**, mas não realiza conversão, acesso ao sandbox, backup nem restauração reais. #81 e release continuam NO-GO.
