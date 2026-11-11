# Backlog compartilhado — prioridades e status

**Snapshot:** 2026-11-09. Status sem evidência de Play permanece não validado. Cada issue técnica deve referenciar `.rbxl`/commit base.

## Painel rastreável no GitHub

| Issue | Prioridade | Escopo |
|---|---|---|
| [#1 — Baseline](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/1) | P0 | Confirmar build oficial e scripts ativos |
| [#2 — Equipamentos](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/2) | P0 | Carrinho, foice, enxada, corte pela lâmina |
| [#3 — Baús e saves](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/3) | P0 | Coleta, recompensa única, persistência |
| [#4 — Interface](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/4) | P0 | Menus sem sobreposição, mobile |
| [#5 — Floresta 2.0](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/5) | P1 | Level art, matagal, segredos e cabana |
| [#6 — Comércio e mochilas](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6) | P1 | Vendedores, caçambas, mochilas, gnomo secreto |

As listas abaixo são o backlog detalhado; a discussão de execução, responsáveis, commits e evidências devem aparecer nas Issues e nos Handoffs.

## P0 — Estabilização

- [ ] **P0-01** Confirmar baseline oficial atual (comparar cópia Claude/Studio com V9), backup e branch.
  - **2026-11-10 (Claude):** usuário confirmou a place `106412085364108` como **baseline de trabalho**. Mapa estático em [18 — Mapa técnico](../brain/18_MAPA_TECNICO_BASELINE.md). Salvamento: o usuário relatou que o Studio salva automaticamente. Falta confirmar: é a versão publicada?
- [ ] **P0-08** Decidir `MaxPlayers` (hoje 60) × 4 lotes: o 5º jogador é expulso. Ajustar Game Settings ou permitir jogador sem lote.
- [ ] **P0-09** Remover duplicata de `Workspace."Sprint on shift"` (dois scripts idênticos ativos), dentro da tarefa de corrida do Claude, que está pausada.
- [ ] **P0-10** Limpeza de restos de depuração após confirmação: `Workspace.Script` (Hello world), `Workspace._VerFerramentas`, remotes legados `Remotes.CortarGrama/ComprarUpgrade/AtualizarDados` (sem uso textual encontrado).
- [x] **P0-02** Testar inicialização e saco normal em Play; investigar `0/1` e regressão V8. **2026-11-10 (Claude):** Play PC OK, `SacoMax=50`, `0/1` não reproduzido, sem erros de script. [Evidência](../evidence/p0-playtest-2026-11-10/VALIDACAO.md).
- [ ] **P0-03** Testar slot 4/carrinho, rodas, guidão, corte físico e respawn em PC/mobile. **PC validado em Play** (montagem, corte por input real, respawn). Falta mobile.
- [ ] **P0-04** Testar foice/enxada/unha R15, ferramentas reais e hitbox; gravar vídeo. **PC:** as 3 equipam e cortam pelo servidor. Falta vídeo/avaliação da animação. **Taxa de acerto investigada** ([análise](../evidence/tool-hit-rate-2026-11-10/ANALISE.md)): no lote, o servidor só conta o quadrado se a lâmina passar perto do **centro** (raio 0,45–1,1 numa grade de 4 studs). Acerto hoje: unha 10%, enxada 53%, foice 86%. **Corrigido** (teste pela área do quadrado, `maxTiles` mantidos por decisão do usuário) e validado em Play no PC: foice 4/golpe, enxada 2, unha 1 a cada 3 golpes.
- [ ] **P0-05** Baús: prompt E/touch, orientação e idempotência de recompensa. **PC:** baú da entrada da floresta pagou uma única vez e está em pé. Faltam toque, baú do lote e baús revelados. Prompt visível depois da coleta **corrigido** (Claude, `game/chest-prompt/`), validado em Play no PC; falta Team Test com 2 jogadores.
- [ ] **P0-12** Corte fluido (pedido do usuário 2026-11-10). **Fase 1 — carrinho no lote: feita e validada em Play PC** (corte pelo trajeto da lâmina, orçamento, fechamento ao parar, previsão no cliente; 0 recusas no teste final). Ver `game/cut-feel/` e `evidence/cut-feel-2026-11-10/`. **Fase 2 — ferramentas manuais: feita e validada em Play PC** (corte previsto no contato, ~277 ms antes do servidor, 0 recusas). **Fase 3 — floresta: feita e validada em Play PC** (cadência corrigida, fechamento ao parar, previsão do carrinho e de foice/enxada; 0 recusas nas rodadas finais). Pendentes: avaliar o balanceamento do carrinho na floresta (~2× o ritmo efetivo anterior), som real de corte, mobile e ping real.
- [ ] **P0-11** Verificar posse/permissão dos `TextureID`s que não carregam: `73347833975287` (`Cortador_Basico`), `120034081281408`, `94694536609432`, `135566642687046` (`GrassPack`).
- [ ] **P0-06** UI: uma única aba/modal, hotbar oculta ao abrir Loja, responsividade.
  - **2026-11-10 (Claude):** polimento da UI validado em Play PC, layout compacto (menu abre na hora, indicador de aba, card da missão, árvore legível e sem sobreposições). Ver `game/ui-polish/` e `evidence/ui-polish-2026-11-10/`. Faltam layout largo, celular e controle.
- [ ] **P1-13** Pedidos do usuário de 2026-11-10, em sequência: ~~UI~~ (feito) → ~~transição do mapa~~ (feito: `game/map-transition/`) → ~~animações~~ (2026-11-11, rodada 2 a pedido do usuário: foice e enxada apoiadas no ombro, golpe sem atravessar o corpo, apertar o número de novo guarda o item, corrigido o personagem que parava de animar após respawn; ver `game/animations/`; aguarda avaliação do usuário) → ~~NPCs~~ (2026-11-11: comerciantes de frente para o balcão, visual próprio, animação, placa de nome, balão de fala com dicas reais; ver `game/npcs/`; multiplayer e celular pendentes) → cabana e segredos da floresta. O usuário autorizou o Claude a assumir também a área da floresta (Codex pausado).
- [ ] **P0-07** Auditar saves e `PersistenceEnabled=false`; planejar migração e testes de reconexão.

## P1 — Floresta Esquecida (principal foco de arte e gameplay)

- [ ] **P1-01** Redesenhar *blockout* por setores, caminho sinuoso + visão revelada gradualmente.
- [ ] **P1-02** Criar/importar kit de 8–12 árvores irregulares, samambaias, raízes, troncos e moitas.
- [ ] **P1-03** Substituir pinheiros clonados/arranjados em linhas; melhorar densidade e sombras.
- [ ] **P1-04** Espalhar **grama alta da Área de Teste** com três estados e corte server-authoritative.
- [ ] **P1-05** Integrar cabana abandonada/restaurada do Blender como hero asset.
- [ ] **P1-06** Riacho/ponte quebrada + clareira secreta + 3 segredos com recompensa testada.
- [ ] **P1-07** Transição orgânica Vila→Floresta com áudio/luz locais, sem escurecer outros jogadores.
- [ ] **P1-08** Teste visual com screenshot/vídeo e FPS mobile; colher aprovação do usuário.

## P2 — Profundidade do jogo

- [ ] **P2-01** NPC Zeca + missão Trilha Esquecida + 3 itens antigos.
- [ ] **P2-02** Restauração da cabana / ponte e recompensas consistentes por jogador.
- [ ] **P2-03** Mapa de Exploração por regiões e visão do jogador; vínculo com habilidades.
- [ ] **P2-04** Auditar cada um dos oito nós Ready, registrar teste e liberar somente os funcionais.
- [ ] **P2-05** Implementar Cartógrafo / Construtor de Pontes quando mapa/cenário e dados prontos.
- [ ] **P2-06** Inventário e evolução reais de raridades das três ferramentas manuais.
- [ ] **P2-07** Baús por raridade: loot tables, posicionamento intencional, drop controlado.

## P3 — Polimento e novas áreas

- [ ] Balanceamento XP/moedas/PH com métricas; áudio/vibração/feedback.
- [ ] Tratores como veículos e modelos exclusivos OffRoad/Colheitadeira/Imperial.
- [ ] Fazenda, Parque do Lago, Ruínas e segredos maiores.
- [ ] Otimização multiplayer/mobile com perfil de performance.

**Como atualizar:** marcar `[x]` só após terminar, com link de issue/PR + evidência; ao contrário, anotar `IMPLEMENTADO_NAO_PLAYTESTADO` em texto.

## P1 — Comércio e autonomia de exploração (adicionado 2026-11-10)

- [ ] **P1-09** Comerciantes: Guto na entrada, Lia no acampamento, Teca na cabana e Nilo secreto.
- [ ] **P1-10** Caçambas na entrada, acampamento e cabana (terceira reparável); reutilizar venda do lobby.
- [ ] **P1-11** Mochilas com upgrade de capacidade adicional, sem duplicar bônus; auditar `SacoMax` e saves.
- [ ] **P1-12** Gnomo colecionador com loja especial, contratos e pista da caverna; validar descobertas.

Ver [17 — Especificação](../brain/17_COMERCIANTES_CACAMBAS_MOCHILAS.md) e [Issue #6](https://github.com/LilNomad01/roblox-cut-and-discover-brain/issues/6). **Todos PLANEJADOS, sem Play.**

### Execução de comércio — 2026-11-10

Aplicado ao place `106412085364108`, branch `ai/forest-economy`, código em `game/forest-economy/`. As mecânicas de P1-09 a P1-12 passaram em 48 verificações de Play, mais 50 asserções das regras. O checklist geral permanece aberto até validar toque, controle real, multiplayer, desempenho móvel e persistência autorizada. Os testes de código não equivalem a navegação completa da região em cada plataforma.

Evidências: [validação e limitações](../evidence/forest-economy/VALIDACAO.md). Persistência continua desativada; o usuário precisa salvar o place no Studio. A corrida foi delegada ao Claude em conversa separada, atualmente pausada, e não faz parte desta atualização.

### Densidade e corte — 2026-11-10

Visual da floresta e feedback local atualizados. Play e idempotência de recompensa verificados; avaliação do usuário e desempenho móvel pendentes. Ver [evidência](../evidence/grass-feel/VALIDACAO.md).

- [x] **Editor — 2026-11-10:** prévia estática da floresta instalada; Edit/Play/Edit sem duplicação validado. Place salvo na versão 19. Ver `evidence/editor-preview/VALIDACAO.md`.
