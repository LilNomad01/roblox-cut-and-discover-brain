# Como duas ou mais IAs usam o MESMO BRAIN pelo GitHub

## O que funciona de verdade

O GitHub funciona como **base documental versionada**; cada IA autorizada pode consultar e atualizar os mesmos arquivos. O histórico fica auditável e mudanças são propagadas assim que a outra IA faz `pull`/`fetch`.

**Não é memória automática nem chat entre IAs.** As IAs não acompanham commits continuamente sem uma integração/agendamento próprio, e não compartilham instantaneamente estados internos. Para sincronização confiável, **cada IA deve ler no começo e escrever ao fim** de sua sessão, ou o agente deve ser configurado para acionar o GitHub nesses gatilhos.

## Acesso necessário

1. O repositório `LilNomad01/roblox-cut-and-discover-brain` já existe. **Foi observado como público em 2026-11-09**; recomenda-se mudar para privado se a colaboração e o conteúdo forem internos.
2. Convidar colaborador/amigo com permissão adequada (idealmente `Write`, sem Admin por padrão).
3. Cada IA precisa de sua própria ferramenta/conector GitHub autenticado na conta autorizada ou de trabalhar localmente via Git.
4. Nunca compartilhar tokens/chaves em chat ou no BRAIN. Concessão explícita de acesso por conta.

## Protocolo obrigatório: início

1. Identificar `repository`, `branch` e último commit no GitHub.
2. Ler `AGENTS.md`, `brain/00_START_HERE.md`, `brain/02_ESTADO_REAL_E_VERSOES.md`, `brain/status.json` e últimas entradas de `handoffs/LOG.md`.
3. Ler docs específicos da tarefa e qualquer issue/PR relacionada.
4. Confirmar baseline `.rbxl`/commit **real do Roblox** e diferença entre estado anterior e atual.
5. Não adotar fatos “Ready” como testados em Play sem evidência.

## Protocolo obrigatório: fim

1. Registrar arquivos mudados e commit de código/asset do jogo, build, screenshots ou logs de teste.
2. Atualizar documentação afetada, `tasks/BACKLOG.md`, `brain/status.json` e `handoffs/LOG.md`.
3. Abrir PR e pedir revisão para mudanças de arquitetura/estado; alterações pequenas podem ir direto ao `main` se combinadas.
4. Nunca sobrescrever mudanças da outra IA sem `fetch`/merge; usar `sha` ao atualizar arquivos por API.
5. Marcar o trabalho `IMPLEMENTADO_NAO_PLAYTESTADO` quando só se inspecionou ou alterou código.

## Como usar com ChatGPT

No chat conectado ao GitHub, pedir: **“Leia o repositório `owner/roblox-cut-and-discover-brain`, sobretudo AGENTS.md, BRAIN, status e handoffs, antes de continuar. Ao finalizar, atualize os arquivos e registre testes.”** O ChatGPT poderá usar as ações de leitura/escrita que sua conexão permitir. Não assumirá o conteúdo atualizado de outra conversa até consultá-lo.

## Como usar com Claude/Claude Code/Codex

- No diretório de trabalho, `git clone` do BRAIN ou incluir como diretório de documentação/submódulo, sem trocar código original de jogo.
- Arquivos `CLAUDE.md`/`AGENTS.md` instruem leitura/atualização; conferir configurações do seu agente para obedecer a esses arquivos.
- Ao terminar tarefa, abrir commit/PR com handoff. Se a IA não tem acesso ao GitHub, entregar `*.md` com mudanças para um humano publicar; **não afirmar sync automático**.

## Edição simultânea

- Uma task/issue por recurso, branch distinta por IA (`ai/claude-forest-art`, `ai/chatgpt-ui-fix`, etc.).
- Não modificar `brain/status.json` em paralelo sem rebase/merge; revisão humana quando duas evidências se contradizem.
- Resolver conflito por **arquivo do projeto atual + teste + decisão do usuário**, não pela IA que escreveu por último.

## No futuro: automação real de sincronização

Integração OPCIONAL via GitHub Actions pode validar Markdown/JSON/links e avisar sobre PRs. Ações **não** fazem a IA aprender automaticamente novas mudanças; para isso é necessário conectá-la ao repositório e disparar leitura em sessões/gatilhos. Não inventar “cérebro com memória instantânea” sem infraestrutura.
