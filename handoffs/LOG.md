# Handoffs — histórico compartilhado entre agentes

> Registrar **no topo** a cada tarefa concluída ou parcialmente entregue. Nunca dizer 'testado' sem evidência reproduzível.

## 2026-11-10 — Claude — baseline de trabalho confirmada e mapa técnico

- **Base:** place `106412085364108` / universe `10775723165` aberta no Studio do usuário; documentação sobre `8a6f71c` (`ai/forest-economy`), branch `claude/baseline-studio-2026-11-10`.
- **Decisão do usuário:** essa place é a versão em que estamos trabalhando. Ainda não confirmado: se é a publicada e se o estado em Edit foi salvo.
- **Arquivos:** novo `brain/18_MAPA_TECNICO_BASELINE.md`; `brain/02_ESTADO_REAL_E_VERSOES.md`, `brain/10_ARQUITETURA_E_DADOS.md`, `brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md`, `brain/00_START_HERE.md`, `README.md`, `brain/status.json`, `tasks/BACKLOG.md`.
- **Testes reais:** somente leitura do DataModel em **Edit** via MCP do Roblox Studio (contagens, hierarquia, fontes, busca textual). **Nenhum Play, nenhuma edição no jogo.** `status.json` validado como JSON e varredura de tokens feita via PowerShell. `scripts/validate_brain.py` (Python 3.12.10) passou: 27 arquivos obrigatórios; validação documental, não é Play.
- **Achados:** `DadosJogador` não é um segundo save (só a rota de compra); `Profiles` tem lease e migração, mas `PersistenceEnabled=false`; floresta construída em runtime dentro do `GameServer`; `MaxPlayers=60` com 4 lotes; duas cópias ativas de "Sprint on shift"; remotes legados aparentemente sem uso; restos de depuração.
- **Próximos passos:** usuário confirmar publicação/salvamento (P0-01) e decidir `MaxPlayers` (P0-08); depois, Play para P0-02 a P0-05. A tarefa de corrida/sprint (P0-09) segue com o Claude, pausada.

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
