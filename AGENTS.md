# AGENTS.md — Contrato para ChatGPT, Claude, Codex e outras IAs

## Você está no projeto Corte & Descubra

Jogo Roblox de **cortar vegetação para revelar um mundo esquecido**, com jardim pessoal, ferramentas e máquinas progressivas, árvore de habilidades, baús, exploração, restauração e segredos. Leia `README.md`, `brain/00_START_HERE.md`, `brain/02_ESTADO_REAL_E_VERSOES.md` e `handoffs/LOG.md` **antes de alterar qualquer coisa**.

### Fonte de verdade e confiança

- **1º** arquivo `.rbxl`/`.rbxlx` real selecionado como baseline pelo usuário, assets e código do projeto atual.
- **2º** testes dentro do Roblox Studio com logs, screenshots/vídeos e relato do usuário.
- **3º** decisões em `decisions/` e estado documentado neste repositório.
- **4º** propostas antigas, prompts e código experimental **não** aceito.
- Nunca converta **PLANEJADO** em **IMPLEMENTADO/TESTADO** por inferência.
- Sempre registre `data`, `arquivo/commit base`, `arquivos modificados`, `testes feitos`, `testes pendentes`, `risco` e `próxima ação`.

### Regras inegociáveis

1. **Não recriar o jogo do zero.** Preservar vila, quatro terrenos, grama, moeda, XP, PH, loja, equipamento, árvore, menus, dados e missões funcionais.
2. **Nunca misturar builds experimentais v1–v5** com a baseline escolhida; a V6–V9 também exige confirmação do usuário para servir de baseline.
3. Auditar hierarquia do Roblox Explorer, scripts ativos (versus backups), dependências, RemoteEvents e modelo real antes de editar.
4. **Servidor autoritativo** em compras, desbloqueio de habilidades, recompensas, corte, baús, posicionamento válido e estado de missões.
5. Não duplicar tool visual ou cortar grama pelos pés. Cortador empurrável usa posição da lâmina; foice/enxada/unha precisam de golpes próprios.
6. Não criar `AnimationId`, `SoundId`, `MeshId` fictício. Se faltar importação/publicação, documentar pendência real.
7. Sempre preservar/exigir plano de migração de save; `PersistenceEnabled=false` foi observado na V9 — não afirmar persistência ativa sem confirmação.
8. Otimizar mobile/controle. Evitar um script por tufo, partículas excessivas e colisão em folhas.
9. Respeitar o **design system** colorido, cartoon, de contornos escuros; não trazer overlay genérico escuro que conflite com a Loja.
10. Trabalhar em **etapas pequenas**, testáveis, com backup/branch. Não afirmar Play se apenas verificou integridade estática.
11. Propostas de lore/segredos devem preservar surpresa do jogador; não expor coordenadas escondidas ao cliente.
12. Não salvar tokens, senhas, URLs de webhooks privados ou informações pessoais neste repositório.

### Como iniciar uma sessão

- `git pull --ff-only` se trabalhando localmente; caso contrário, `fetch` dos arquivos atuais pelo conector GitHub.
- Ler `brain/status.json` e `handoffs/LOG.md` para mudanças recentes.
- Conferir versão base contra o projeto Roblox realmente aberto.
- Abrir tarefa/issue se não existir, anotar escopo e hipótese.
- Trabalhar somente no escopo autorizado; fazer commit/PR com evidências.

### Como encerrar a sessão

1. Atualizar `brain/status.json` **somente com fatos verificados**, sem inventar resultado.
2. Atualizar `tasks/BACKLOG.md` e documentos afetados.
3. Adicionar entrada com data/IA/artefato/testes no topo de `handoffs/LOG.md`.
4. Se mudou arquitetura/regra de design, criar novo ADR em `decisions/`.
5. Fazer commit ou PR. Outra IA deve poder reproduzir os passos sem conversar com quem fez.

### Convenção de estados

- `CONFIRMADO_EM_ARQUIVO`: existe no `.rbxl`/asset inspecionado.
- `RELATADO_PELO_USUARIO`: screenshot ou teste relatado.
- `IMPLEMENTADO_NAO_PLAYTESTADO`: código presente, comportamento não validado em Play.
- `VALIDADO_EM_PLAY`: execução real reproduzida em Studio com evidência.
- `PLANEJADO`: intenção/feature solicitada.
- `BLOQUEADO`: dependência ausente ou bug impeditivo.
- `DESCONTINUADO`: experimento explicitamente abandonado.

### Guia para ferramentas de IA

- **Claude:** `CLAUDE.md` redireciona para este arquivo. Não duplicar regras divergentes.
- **Codex:** seguir `AGENTS.md` e registrar alterações no BRAIN.
- **ChatGPT:** usar conexão GitHub para ler/atualizar os arquivos a cada sessão relevante; **não** assumir leitura em tempo real sem chamada ao GitHub.
- **IA do amigo:** acesso GitHub explícito, ler e atualizar no mesmo repositório. Em caso de edição simultânea, usar PRs e reconciliar conflitos.
