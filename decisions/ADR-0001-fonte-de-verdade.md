# ADR-0001 — Fonte de verdade e múltiplas IAs

**Status:** ACEITA como processo de colaboração — 2026-11-09.

**Contexto:** várias IAs trabalham no mesmo jogo; muitas cópias de `.rbxl` e prompts antigos geraram confusão de baseline.

**Decisão:** GitHub BRAIN guarda contexto, decisões, status e handoffs. Arquivo/projeto Roblox escolhido pelo usuário + teste em Studio prevalece sobre documentação. Cada IA lê o GitHub no início e registra mudanças no fim. Cada mudança tem evidência.

**Consequências:** menos trabalho duplicado; não existe sincronização automática da memória dos modelos. O commit do jogo precisa ser identificado em cada tarefa.

**Relação:** [AGENTS.md](../AGENTS.md), [Protocolo](../brain/15_SINCRONIZACAO_DAS_IAS.md).
