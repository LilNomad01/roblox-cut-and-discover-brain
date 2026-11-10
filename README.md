# 🌱 Corte & Descubra — BRAIN compartilhado

**Central de conhecimento de desenvolvimento do jogo Roblox Corte & Descubra (Cut & Discover).**

> **Regra de ouro:** o arquivo real do jogo + testes no Roblox Studio são a fonte de verdade de implementação. Este repositório registra decisões, especificações, evidências e estado das tarefas. Nunca interpretar uma ideia documentada como feature pronta.

## ⚡ Comece aqui — para qualquer IA

1. Leia [AGENTS.md](AGENTS.md) (regras de colaboração e evidência).
2. Leia [Resumo de 90 segundos](brain/00_START_HERE.md).
3. Confira [Estado técnico e versões](brain/02_ESTADO_REAL_E_VERSOES.md) e [status.json](brain/status.json).
4. Veja [Backlog](tasks/BACKLOG.md), [Handoffs recentes](handoffs/LOG.md) e decisões em [decisions/](decisions/).
5. Abra **somente os capítulos relacionados à tarefa** para economizar contexto/tokens.
6. Ao concluir: atualize documentação afetada, status, backlog e handoff; envie commit ou PR.

**IA do amigo:** [Contexto de onboarding](CONTEXTO_PARA_IA_DO_AMIGO.md). **Claude:** [CLAUDE.md](CLAUDE.md). **Copilot:** [.github/copilot-instructions.md](.github/copilot-instructions.md).

## 🎯 Tarefas abertas (GitHub Issues)

As prioridades são rastreadas no [painel de Issues](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues). Comece pela [confirmação da baseline #1](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/1). [Animações #2](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/2), [baús e saves #3](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/3), [UI #4](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/4) , [floresta 2.0 #5](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/5) e [comércio da floresta #6](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6) possuem checklists de aceite.

## 🧭 Navegação por assunto

| Área | Documento | Quando abrir |
|---|---|---|
| Visão e loop | [01 — Visão](brain/01_VISAO_E_DECISOES.md) | Criar/revisar mecânicas |
| Estado real | [02 — Estado e builds](brain/02_ESTADO_REAL_E_VERSOES.md) | Antes de editar o Roblox |
| Economia | [03 — Progressão](brain/03_PROGRESSAO_E_ECONOMIA.md) | Moedas, XP, PH, preços |
| Ferramentas | [04 — Equipamentos](brain/04_EQUIPAMENTOS_E_ANIMACOES.md) | Foice, enxada, carrinho, animações |
| Grama | [05 — Vegetação](brain/05_GRAMA_E_CORTE.md) | Corte por lâmina, TALL/SHORT/STUBBLE |
| Mundo | [06 — Floresta Esquecida](brain/06_MUNDO_FLORESTA_ESQUECIDA.md) | Level design, mistério, cabana, árvores |
| Skill tree | [07 — Habilidades](brain/07_ARVORE_E_HABILIDADES.md) | PH, 19 nós, status real |
| UX | [08 — UI](brain/08_UI_UX.md) | Loja, menu, HUD e identidade |
| Comerciantes | [17 — Vendedores, caçambas e mochilas](brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md) | Comércio da floresta e upgrades de capacidade — planejado |
| Recompensas | [09 — Baús](brain/09_BAUS_ITENS_E_DESCOBERTAS.md) | Loot, raridade, segredos |
| Engenharia | [10 — Arquitetura](brain/10_ARQUITETURA_E_DADOS.md) | Luau, servidores, persistência |
| Arte 3D | [11 — Assets/Blender](brain/11_ASSETS_E_BLENDER.md) | Assets e pipeline modular |
| QA | [12 — Bugs/testes](brain/12_BUGS_RISCOS_TESTES.md) | Diagnóstico e regressões |
| Roadmap | [13 — Roadmap](brain/13_ROADMAP.md) | Ordem de produção |
| Histórico | [14 — Decisões passadas](brain/14_HISTORICO_DECISOES.md) | Não reabrir ideias descartadas |
| Multi-IA | [15 — Sincronização](brain/15_SINCRONIZACAO_DAS_IAS.md) | Ler/registrar mudanças entre IAs |
| Pendências | [16 — Perguntas abertas](brain/16_QUESTOES_ABERTAS.md) | Pontos ainda sem prova |
| Execução | [Backlog](tasks/BACKLOG.md) | O que fazer agora |
| Artefatos | [Manifesto](assets/MANIFESTO.md) | Origem e estado dos modelos |

## 📌 Estado atual que não pode ser confundido

- O último arquivo **auditado estaticamente** foi `CorteEDescubra_v9_Carrinho_Foice_HUD.rbxl`; **não** é automaticamente a versão principal atual.
- Foram observadas **7.296 instâncias**, **103 scripts/módulos incluindo backups**, **cinco modelos de cortadores**, **15 variantes manuais**, **cinco baús** e **19 nós de habilidade**.
- **Nenhum playtest do Studio foi comprovado nesta auditoria.** Foi observado `PersistenceEnabled=false` em uma configuração da V9.
- O usuário **não aprovou visualmente** a última floresta; o redesenho precisa de árvores orgânicas, sub-bosque, caminhos curvos e segredos reais.

## 🧠 Como manter a sincronização

GitHub é a fonte de verdade **documental**. Outra IA só vê mudanças novas quando consultar/puxar o repositório. **Não existe sincronização automática da memória dos modelos.** Use [protocolo multi-IA](brain/15_SINCRONIZACAO_DAS_IAS.md).

## 🔒 Privacidade

O repositório foi encontrado **público** na auditoria de 2026-11-09. Para colaboração privada entre duas IAs, recomendo **Settings → General → Danger Zone → Change visibility → Private**. Não coloque credenciais, chaves, webhooks privados ou dados sensíveis em commits. Leia [SECURITY.md](SECURITY.md).

## 📚 Backup documental

A versão integral recebida em 2026-11-09 está preservada em [archive/BRAIN_COMPLETO_Corte_e_Descubra_2026-11-09.md](archive/BRAIN_COMPLETO_Corte_e_Descubra_2026-11-09.md). Os capítulos `brain/` são a forma recomendada de leitura e atualização.

**Data do snapshot documental:** 2026-11-09. **Os testes de gameplay não são substituídos por esta documentação.**
