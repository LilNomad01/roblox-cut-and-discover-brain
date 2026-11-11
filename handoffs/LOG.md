# Handoffs — histórico compartilhado entre agentes

> Registrar **no topo** a cada tarefa concluída ou parcialmente entregue. Nunca dizer 'testado' sem evidência reproduzível.

## 2026-11-10 — Claude — corte das ferramentas manuais pela área do quadrado

- **Base:** `GameServer` com hash `70952/613054764` (depois da correção do prompt), place `106412085364108`.
- **Decisão do usuário:** aplicar o teste por área e manter os `maxTiles` atuais (foice 4, enxada 2, unha 1).
- **Mudança no jogo:** `CortarPorLamina` usa `distQuadrado` (traço da lâmina × área 4×4 do quadrado) em vez da distância ao centro. Backup em `ServerStorage.GameServerBeforeHitAreaFix_20261110`. Cópia em `game/forest-economy/integration/…GameServer.luau` com hash igual ao Studio (`71734/624928825`).
- **Testes reais (Play PC):** foice +4/+4/+4 na posição que antes dava 0; enxada +2; unha 1 quadrado em 3 golpes; carrinho inalterado (+7); XP 5 por quadrado; sem erros. Detalhes em `evidence/tool-hit-rate-2026-11-10/ANALISE.md`.
- **Risco:** o rendimento das ferramentas manuais subiu (foice ~1,6 → 4 por golpe). Observar o balanceamento em relação ao carrinho. Mobile e floresta não medidos.
- **Aviso ao Codex:** o `GameServer` do manifesto mudou de novo; parta da cópia atualizada.

## 2026-11-10 — Claude — investigação da taxa de acerto das ferramentas manuais

- **Base:** place `106412085364108`, Play solo PC. **Nenhuma mudança no jogo.**
- **Causa:** `CortarPorLamina` (GameServer) aceita o quadrado do lote só se o traço da lâmina passar a `largura/2` do **centro** (grade de 4 studs). O acerto depende do alinhamento do jogador com a grade.
- **Medição:** 2.888 golpes simulados por ferramenta com o código do servidor, mais golpes reais gravados. Acerto atual: unha 10%, enxada 53%, foice 86%. Com teste pela área do quadrado, as três chegam a 100%, limitadas por `maxTiles`.
- **Arquivos:** `evidence/tool-hit-rate-2026-11-10/ANALISE.md`, backlog (P0-04).
- **Próxima ação:** usuário decidir se aplica o teste por área mantendo ou reduzindo `maxTiles`.

## 2026-11-10 — Claude — prompt de baú coletado escondido por jogador

- **Base:** place `106412085364108`; `GameServer` igual a `game/forest-economy/integration/…GameServer.luau` em `bd17159`.
- **Mudanças no jogo:** `CorteEDescubra.GameServer` ganhou `forestMarkClaimed`, o atributo `ForestSecretId` nos prompts e o atributo `ForestClaimedSecrets` no jogador. Novo LocalScript `StarterPlayerScripts.ForestSecretPromptClient`. Regras de recompensa inalteradas. Backup em `ServerStorage.GameServerBeforeChestPromptFix_20261110`.
- **Arquivos do repo:** `game/chest-prompt/` (cliente + README com rollback), cópia do GameServer em `game/forest-economy/integration/` atualizada (hash igual ao do Studio), evidência, backlog e status.
- **Testes reais:** Play PC. 16/16 prompts marcados; depois da coleta o prompt fica `Enabled=false` no cliente e `true` no servidor; pagou 14 moedas uma vez; sem erros no console.
- **Pendências:** Team Test com 2 jogadores e mobile.
- **Aviso ao Codex:** editei o `GameServer` que está no seu manifesto `ai/forest-economy`. Ao reaplicar a integração, parta da cópia atualizada para não desfazer a correção.

## 2026-11-10 — Claude — playtest P0-02 a P0-05 (PC)

- **Base:** place `106412085364108` em Play solo no Studio do usuário; documentação na branch `claude/baseline-studio-2026-11-10` (mesclada com `bd17159`).
- **Mudanças no jogo:** nenhuma. Os dados do teste foram descartados ao parar o Play.
- **Testes reais (PC, teclado):** P0-02 inicialização OK (`SacoMax=50`, bug `0/1` não reproduzido, sem erros de script). P0-03 carrinho montado, corte com W/A/S (`Saco 0→7`, `XP 35`) e respawn com carrinho e saco preservados. P0-04 foice, enxada e unha equipam uma de cada vez e cortam pelo servidor. P0-05 baú da entrada da floresta pagou uma única vez em 3 tentativas. Detalhes e capturas em `evidence/p0-playtest-2026-11-10/`.
- **Achados:** `TextureID`s que não carregam no `Cortador_Basico` e no `GrassPack`; prompt "Abrir baú" continua visível depois da coleta; taxa de acerto da enxada e da foice parece baixa; a navegação automática não corta (exige `MoveDirection`), o que é esperado.
- **Pendências:** mobile, controle, multiplayer, avaliação de animação em vídeo, baú do lote e baús revelados por corte.
- **Observação:** o Codex instalou `Workspace.ForestEditorPreview` na mesma place em paralelo. As contagens estáticas do `18_MAPA_TECNICO_BASELINE.md` são anteriores a essa prévia.

## 2026-11-10 — Claude — baseline de trabalho confirmada e mapa técnico

- **Base:** place `106412085364108` / universe `10775723165` aberta no Studio do usuário; documentação sobre `8a6f71c` (`ai/forest-economy`), branch `claude/baseline-studio-2026-11-10`.
- **Decisão do usuário:** essa place é a versão em que estamos trabalhando, e o Studio salva automaticamente (relato do usuário). Ainda não confirmado: se é a versão publicada.
- **Arquivos:** novo `brain/18_MAPA_TECNICO_BASELINE.md`; `brain/02_ESTADO_REAL_E_VERSOES.md`, `brain/10_ARQUITETURA_E_DADOS.md`, `brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md`, `brain/00_START_HERE.md`, `README.md`, `brain/status.json`, `tasks/BACKLOG.md`.
- **Testes reais:** somente leitura do DataModel em **Edit** via MCP do Roblox Studio (contagens, hierarquia, fontes, busca textual). **Nenhum Play, nenhuma edição no jogo.** `status.json` validado como JSON e varredura de tokens feita via PowerShell. `scripts/validate_brain.py` (Python 3.12.10) passou: 27 arquivos obrigatórios; validação documental, não é Play.
- **Achados:** `DadosJogador` não é um segundo save (só a rota de compra); `Profiles` tem lease e migração, mas `PersistenceEnabled=false`; floresta construída em runtime dentro do `GameServer`; `MaxPlayers=60` com 4 lotes; duas cópias ativas de "Sprint on shift"; remotes legados aparentemente sem uso; restos de depuração.
- **Próximos passos:** usuário confirmar publicação/salvamento (P0-01) e decidir `MaxPlayers` (P0-08); depois, Play para P0-02 a P0-05. A tarefa de corrida/sprint (P0-09) segue com o Claude, pausada.

## 2026-11-10 — Codex — floresta visível no editor

- **Base:** `8a6f71c`, place `106412085364108`, branch `ai/forest-economy`.
- **Arquivos:** instalador `game/editor-preview/install.luau`, integrações `GameServer`/`ForestScenery`, README, ADR-0004 e validação específica.
- **Mudanças:** prévia estática `Workspace.ForestEditorPreview`, com cenário existente e cobertura de grama simplificada. Backup de TerrainRegion e pivôs originais antes da preparação do terreno. GameServer remove somente a prévia identificada antes dos builders reais.
- **Correção:** exploração usava caminho fixo `workspace.GameWorld.FlorestaEsquecida`; agora recebe as árvores do `root` informado. Primeira tentativa incompleta foi restaurada antes de reconstruir.
- **Testes:** Edit com 12.065 descendentes e 6.075 meshes de grama, zero prompts ativos e zero peças soltas; build idempotente. Play com prévia ausente, uma floresta, 25.197 registros de grama, 16 segredos e um stream. Stop restaurou a prévia. Fontes de GameServer e ForestScenery conferidas por tamanho/checksum. Console do Play sem erros do jogo. Compilação do instalador, módulo derivado e integrações.
- **Salvamento:** ferramenta de save disponível nesta sessão; place salvo no Roblox, versão 19, sem publicar. Substitui a limitação de ferramenta descrita nos handoffs anteriores para esta entrega.
- **Risco/pendências:** prévia para visualização; editar suas peças não altera o gerador. Desempenho do editor em outra máquina e retorno após reabrir o Studio ainda não executados. TerrainRegion preservado para rollback; sem mudança de dados de jogadores.
- **Próxima ação:** usuário avaliar floresta no editor; mudanças permanentes de layout continuam nos builders.

## 2026-11-10 — Codex — matagal mais denso e feedback de corte

- **Base:** `441fa2a`, place `106412085364108`, branch `ai/forest-economy`.
- **Arquivos:** `game/grass-feel/ForestGrassClient.client.luau`, evidência em `evidence/grass-feel/`, status e backlog.
- **Mudanças:** sobreposição e altura visual da vegetação normal, cores verdes, folhas maiores, transição Cubic Out e som de corte existente com limite. Sem novas instâncias de grama, alteração econômica ou mudanças na corrida.
- **Testes:** compilação Luau; Play e inspeção visual; rota de lâmina com `Cuts=1`, `SackGain=1`, `NoExtraReward=true`; 1.501 peças locais sem colisão/toque/consulta. Console consultado sem erro do jogo.
- **Risco/pendências:** desempenho em aparelho móvel e avaliação auditiva não comprovados; salvar place no Studio. Backup em `ServerStorage.GrassFeelBackup_20261110`.
- **Próxima ação:** usuário avaliar densidade e sensação de corte; detalhes e rollback em `evidence/grass-feel/VALIDACAO.md`.

## 2026-11-10 — Codex — comércio integrado e validado em Play

- **Base:** `997d839`, branch `ai/forest-economy`, place `106412085364108` / universe `10775723165`; sem carregar builds experimentais sobre o jogo aberto.
- **Arquivos modificados:** `game/forest-economy/` e integrações do manifesto, `brain/status.json`, `tasks/BACKLOG.md`, esta entrada e `evidence/forest-economy/`.
- **Resultado:** comerciantes, cinco mochilas aditivas, três vendas pela mesma economia, contrato de Teca, coleta por jogador e equipamentos reais. Nilo reutiliza o gnomo e a revelação pelo corte existentes. Área comercial protegida também nas árvores criadas pelo módulo de cenário; placas voltadas para a entrada das bancas.
- **Testes executados:** 15 fontes compiladas no Luau 0.746; 50 asserções de regras; 48 verificações de servidor/cliente em Play. Mochila e equipamentos após respawn, E/X/Esc e transições de modais verificadas separadamente. As 11 fontes aplicadas foram comparadas com os arquivos locais em Edit.
- **Correção encontrada em QA:** o fechamento assíncrono do comércio florestal limpava `LojaAberta` após abrir a Loja principal. O evento de fechamento agora preserva o estado quando a Loja principal assume o modal; regressão executada e aprovada.
- **Limitações/riscos:** save segue desativado; mobile, controle real, multiplayer e desempenho móvel não validados. O arquivo `.rbxl` precisa ser salvo pelo usuário, pois o MCP não oferece essa operação. Nenhuma publicação ou migração de banco executada.
- **Backup:** seis scripts originais em `ServerStorage.ForestCommerceBackup_20261110`; instruções de rollback no README do módulo.
- **Próxima ação:** usuário salvar o place; executar critérios pendentes em aparelhos e servidor de teste. A tarefa de corrida do Claude está pausada e não foi editada nesta atualização.

## 2026-11-10 — Codex — comércio da floresta preparado para integração

- **Base:** `0878755`, branch `ai/forest-economy`; scripts ativos do place `106412085364108` comparados com a auditoria anterior, sem alterações funcionais nesses seis pontos de integração.
- **Arquivos:** `game/forest-economy/`, catálogo, regras de perfil, serviço, cenário, cliente e seis integrações explícitas em `manifest.json`.
- **Escopo:** Guto/Lia/Teca, Nilo existente, mochilas com bônus aditivo, três vendas pela `Economia.Vender`, coleta individual, contrato e equipamentos reais. Acesso aos equipamentos por UI própria porque o jogo oculta o Backpack padrão.
- **Validação:** 11 arquivos compilados no Luau 0.746; 50 asserções das regras de compra, materiais, limites e isolamento passaram. Não é evidência de Play.
- **Estado:** código preparado em disco; ainda não aplicado ao Studio neste checkpoint. Persistência permanece desativada; sem gravação de DataStore ou publicação.
- **Risco:** integração visual, inicialização e entradas ainda precisam de execução real; compras/descobertas duram somente a sessão com a configuração atual.
- **Próxima ação:** aplicar com verificação de origem e backup, executar Play e documentar resultados. A tarefa de corrida do Claude é separada e está pausada.

## 2026-11-10 — ChatGPT — ideia futura e orientação multiplayer

- **Ideia anotada, NÃO implementada:** jardineiro mencionar Floresta Esquecida no nível 5.
- **Arquivos de documentação:** `ideas/IDEIAS_FUTURAS_NAO_IMPLEMENTAR.md`, capítulo da floresta, README.
- **Orientação técnica dada:** em Roblox Studio, Play solo não compartilha servidor entre colaboradores; utilizar Team Test. Em jogo publicado, usar Join Experience e conferir MaxPlayers/privacidade.
- **Código do jogo:** sem modificações; nenhum Play executado.

## 2026-11-10 — ChatGPT — expansão de comércio na Floresta Esquecida

- **Escopo:** documentar comerciantes Guto/Lia/Teca/Nilo, caçambas, mochilas, interação de NPCs e economia de exploração.
- **Fonte:** decisão de design do usuário em chat; **tudo PLANEJADO, nada editado no Roblox**.
- **Arquivos:** `brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md`, capítulos de floresta/economia, `tasks/BACKLOG.md`, `brain/status.json` e índice.
- **GitHub Issue:** [#6 — Comércio e mochilas](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6).
- **Validação:** consistência dos documentos; nenhum teste em Roblox Studio.
- **Próxima ação:** confirmar baseline real e implementar de modo incremental, começando pela venda reusada e capacidade de saco sem duplicação.

## 2026-11-09 — ChatGPT — organização do BRAIN no GitHub

- **Escopo:** estruturação da documentação preexistente em capítulos, regras para Claude/Codex/IA do amigo, backlog, status e GitHub Actions.
- **Fonte:** documento monolítico previamente enviado ao repositório pelo usuário. O conteúdo original permanece em `archive/`.
- **Mudanças no jogo Roblox:** nenhuma.
- **Validação:** auditoria documental / integridade de arquivos no repositório (não é Play).
- **Pendências:** confirmar baseline real e validar gameplay; exigir acesso ao mesmo GitHub para cada IA.
- **Issues de execução criadas:** [#1 baseline](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/1), [#2 equipamentos](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/2), [#3 baús e saves](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/3), [#4 UI](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/4), [#5 floresta 2.0](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/5).
- **Próxima ação:** selecionar uma tarefa P0 ou P1 e registrar o commit do jogo correspondente.

## 2026-11-09 — Snapshot inicial (conversa)

- Histórico de brainstorm, assets de grama/equipamentos/baús, interface, árvore de habilidades e várias versões experimentais `.rbxl`.
- V9 auditada estaticamente com 7.296 instâncias / 103 scripts e módulos incluindo backups; **sem playtest**.
- Usuário reprovou o visual repetitivo da última floresta e definiu reformulação artística como prioridade.
- **Versões v1–v5 explicitamente descartadas** como baseline.
