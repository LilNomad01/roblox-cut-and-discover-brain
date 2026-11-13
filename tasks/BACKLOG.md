# Backlog compartilhado — prioridades e status

**Snapshot:** 2026-11-09. Status sem evidência de Play permanece não validado. Cada issue técnica deve referenciar `.rbxl`/commit base.



## Mapa e radar — checkpoint 2026-11-13

- [x] Base aérea real do cenário, zoom, centralização, atalhos e arraste.
- [x] Radar dentro da tela, sem sobrepor os controles desktop observados.
- [ ] Polir nitidez, indicação do modo do atlas e marcadores até meta8/10. Última7,3; iteração encerrou por tempo.
- [ ] Validar touch e desempenho em aparelho móvel.

Versão138 salva; evidência em evidence/map-ui-v2/VALIDACAO.md.

## Checkpoint 2026-11-13 — lobby e radar

- [x] Corrigir grounding das árvores e acumulação de altura da gruta antiga; validar Edit/Play.
- [x] Adicionar pátios, canteiros, recanto, ateliê, carroça, fonte e pomares sem novos serviços.
- [x] Radar topográfico e atlas com posição/direção; preservar menus aprovados.
- [ ] Capturar arte final e concluir revisão independente até meta 8/10. Primeira nota 6/10 antecede os últimos ajustes.
- [ ] Teste físico de N/clique/toque, multiplayer pelo usuário, celular e persistência entre sessões.

Evidências: evidence/world-navigation/VALIDACAO.md; salvamento confirmado versão 126, sem publicação.

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
- [ ] **P0-02** Testar inicialização e saco normal em Play; investigar `0/1` e regressão V8.
- [ ] **P0-03** Testar slot 4/carrinho, rodas, guidão, corte físico e respawn em PC/mobile.
- [ ] **P0-04** Testar foice/enxada/unha R15, ferramentas reais e hitbox; gravar vídeo.
- [ ] **P0-05** Baús: prompt E/touch, orientação e idempotência de recompensa.
- [ ] **P0-06** UI: uma única aba/modal, hotbar oculta ao abrir Loja, responsividade.
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

- [x] **2026-11-12 — Terreno (editor):** eliminar cortes retangulares, corrigir cota do lobby e frestas de LOD; evidência em `evidence/world-reform/CHECKPOINT_TERRAIN.md`.
- [ ] **2026-11-12 — Lobby:** praça temática, horta/estufa, marcos, props e integração dos quatro lotes. Multiplayer será testado pelo usuário.

### Checkpoint do lobby — 2026-11-12

Praça, horta/moinho/estufa, props e caminhos aplicados. Play confirmou inicialização sem duplicação e coordenadas preservadas. Studio desconectou antes da revisão final e do save; tarefa permanece aberta. Ver [checkpoint](../evidence/lobby-garden/CHECKPOINT.md).

### Retomada do lobby — versão 112

Arte ampliada e salva; inicialização, posições dos lotes/spawns, letreiros e dez pontos de circulação verificados. Tarefa visual permanece aberta até capturar e avaliar a última revisão paisagística. Não confundir a nota 6,8/10 das imagens v4 com avaliação das sebes/painéis atuais. Multiplayer a cargo do usuário; mobile e persistência pendentes.
