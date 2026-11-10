# Mapa técnico da baseline de trabalho (Studio)

**Data:** 2026-11-10 · **IA:** Claude (Claude Code) · **Método:** leitura do DataModel em **Edit** via MCP do Roblox Studio (`execute_luau`, `script_read`, `script_grep`), **somente leitura**. **Nenhum Play executado nesta auditoria e nenhuma instância alterada.**

## Baseline

- **Confirmada pelo usuário em 2026-11-10:** o place aberto no Studio é a versão em que estamos trabalhando.
- Place `106412085364108`, universe `10775723165`, nome no Studio `corte e descubra (colaboração para programar)`, salvo na nuvem (`persistedToCloud=true`).
- É a mesma place onde o Codex aplicou comércio da floresta e ajuste da grama (branch `ai/forest-economy`, ver `evidence/forest-economy/` e `evidence/grass-feel/`).
- **Salvamento:** o usuário relatou em 2026-11-10 que o Studio salva automaticamente (place colaborativa na nuvem), então as mudanças aplicadas em Edit, inclusive as do Codex, ficam na place. Status: `RELATADO_PELO_USUARIO`.
- **Não confirmado:** se é a versão **publicada** para jogadores. Salvar na nuvem não é o mesmo que publicar.
- Relação com a V9: mesma linhagem (mesmos 5 baús, 5 cortadores 3D, `GameAssets`, `GrassPack`, scripts-chave e `PersistenceEnabled=false`), mas **não é idêntica** — contém comércio, `ForestTreeKit`, `ForestGrassClient` e backups de 2026-11-10 inexistentes na V9 auditada. **Tratar a V9 como histórico; a baseline é a place.**

## Contagens (Edit, serviços de jogo)

| Item | Valor |
|---|---|
| Instâncias (Workspace, RS, SSS, ServerStorage, StarterGui/Player/Pack, Lighting, RF, SoundService) | 7.250 |
| Scripts/módulos totais | 128 |
| — fora de `ServerStorage` (código potencialmente ativo) | 84 |
| — dentro de `ServerStorage` (backups/arquivo, não executam) | 44 |
| Scripts com `Disabled=true` | 20 |
| Parts / MeshParts / Models | 5.751 / 917 / 197 |

A floresta **não existe em Edit**: é construída em runtime pelo `GameServer` (ver abaixo), então as contagens acima não incluem a região.

## Scripts ativos por área

### Servidor — `ServerScriptService`

| Script | Papel |
|---|---|
| `CorteEDescubra.GameServer` (Script, ~1.308 linhas) | Orquestrador **monolítico**: cria `ReplicatedStorage.GameRemotes` (`CutIntent`, `UpgradeRequest`, `NewJobRequest`, `StateSync`, `FXEvent`, `Ready`), reserva 1 dos 4 lotes por jogador, sessões, job do lote 8×8 (64 quadrados), corte do cortador empurrável **pela posição da `Lamina`**, NPC "Novo Serviço", baú do lote, **toda a construção da Floresta Esquecida** (linhas ~384–1033), streaming de grama da floresta (`Remotes.ForestGrassStream`), autosave a cada 45 s e `BindToClose`. |
| `CorteEDescubra.Profiles` / `ProfileData` / `Rules` / `SkillRules` / `ForestCommerceData` | Perfil com `UpdateAsync`, **lease de sessão** (180 s), retry, `schemaVersion` 1→2 com validação de `Economy`, `SkillData` e `ForestEconomy`. Com `PersistenceEnabled=false`, `Profiles.load` cria perfil novo em memória e `save` não grava. |
| `Economia` (Module) | Moedas, XP/nível, `Saco`/`SacoMax`, venda (`PrecoGrama=2`), compra de cortadores (`ConfigJogo.Itens`). Estado espelhado em atributos do `Player`. |
| `DadosJogador` (Script) | **Não é um segundo sistema de save.** Só cria `ComprarItem`/`NotificarHUD` e atende compras da loja (rate limit 0,3 s, exige `ProfileReady` e perfil ativo). `MODO_TESTE=false`. |
| `CorteEDescubra.FerramentasServer` | Ferramentas manuais (unha/enxada/foice) e slot do carrinho; remotes próprios `Equipar`/`IniciarGolpe`; corte via `ServerStorage.GameServerGanchos.CortarPorLamina` (BindableFunction do GameServer). |
| `CorteEDescubra.SkillService` / `SkillMechanics` | Árvore de habilidades; cria remotes próprios. |
| `CorteEDescubra.CacambaVenda` | Venda nas caçambas dos lotes (prompt + zona), dispara `EfeitoVenda`. |
| `CorteEDescubra.ForestCommerce*`, `ForestScenery`, `ForestTreeKit`, `VendorAvatar`, `MowerMount`, `World` | Comércio da floresta (Codex), cenário/árvores modulares da floresta, avatares de vendedores, montagem do cortador, mundo da vila. |

### Compartilhado — `ReplicatedStorage`

- `ConfigJogo`: economia e **8 cortadores** na loja (Básico, Elétrico, Turbo, Mini Trator, Off-Road, Colheitadeira, Mega, Imperial GX).
- `Shared.GameConfig`: `PersistenceEnabled=false`, `DataStoreName="CorteEDescubra_v1"`, grade do lote, 3 níveis de corte (`Levels`).
- `Shared.FerramentasConfig`: slots 1 unha, 2 enxada, 3 foice, 4 carrinho; 5 raridades (só Comum usada); kit inicial Comum das 3 manuais.
- `Shared.SkillDefinitions`: 19 nós; **8 `Ready`** (CUT_CLOSE, CUT_SPIN, CUT_TURBO, EXP_VISION, EXP_DETECTOR, TECH_CLIPPINGS, TECH_QUICKSWAP, TECH_DRONE) e 11 `Planned`. `Ready` = existe código, **não** equivale a Play validado.
- Grama/corte: `GrassConfig`, `GrassMask`, `CutMath`, `CutPathSolver`, `ToolCutProfiles`, `BladeSweep`, `ArmIK`, `AnimFerramentas`.
- `Shared.ForestCommerceCatalog`: 5 mochilas, vendedores Guto/Lia/Teca/Nilo, produtos.

### Cliente — `StarterPlayerScripts`

`InterfaceHUD` (~1.518 linhas), `PlayerMenu` + 13 módulos (Perfil, Habilidades, Equipamentos, Exploração, Missões, Configurações), `SkillActionBar`, `FerramentasCliente` (+`Animador`, `Barra`), `CutPrototypeClient` (+`GrassRenderer`, `CutInputController`, `CutCameraController`, `CutFeedbackController`), `JuiceCliente` (+`Musica`, `VFXMundo`, `AnimCortador`, `Celebracoes`, `BotoesVivos`), `EfeitosJogo`, `GameClient`, `ForestGrassClient`, `ForestCommerceClient`, `VendorIdle`. `SkillTreeController` está **desativado** (substituído pelo `PlayerMenu`).

## Mundo

- `Workspace.GameWorld`: `Plots` com **4 lotes** (`Plot01`–`Plot04` em ±48, ±48), `Tufos`, `Decoracao` (árvores, flores, postes, bancos), `Lobby` (`LobbySpawn`).
- `Workspace.WorldGrassZones.CutPrototypeZone` em (0, 1.6, 118).
- `StarterGui.GameHUD` (moedas, progresso do job, objetivo, botões de upgrade e de novo serviço, notificação, sessão).
- `ServerStorage.GameAssets`: `Mowers`, `Ferramentas`, `Baus`, `Secrets`, `GrassTileTemplate`.
- **Floresta Esquecida (runtime):** modelo `GameWorld.FlorestaEsquecida`, área ≈ 600×648 studs (x −296…296, z −181…−821), 5 setores (Entrada, Trilha Oculta, Cabana, Riacho/Ponte, Clareira Secreta), riacho, ponte, cabana, bosques autorais, pedras/troncos, **9 segredos fixos** (7 baús Comum→Mitológico, 2 artefatos) mais os adicionados por `ForestScenery.enrich/exploration`. Grama: o servidor mantém o estado autoritativo; o cliente recebe por proximidade (`ForestGrassStream`, raio 100 studs, pacotes de 180). Codex registrou **25.197 tufos lógicos**.

## Achados e riscos (análise estática — confirmar antes de corrigir)

1. **`Players.MaxPlayers=60` × 4 lotes.** O `GameServer` expulsa o 5º jogador ("Os quatro lotes estão ocupados"). Se o valor publicado for 60, servidores cheios vão expulsar jogadores. Ajustar `MaxPlayers` para 4 em Game Settings ou permitir jogadores sem lote. **Decisão do usuário.**
2. **Dois scripts `Workspace."Sprint on shift"` idênticos e ativos** (script de terceiros "Fozetts"). Cada um clona um `SprintScript` para o personagem, ou seja, dois scripts de corrida por personagem. Está relacionado à tarefa de corrida do Claude, registrada como pausada pelo Codex. **Não mexi.**
3. `Workspace.Script` com `print("Hello world!")` e pasta `Workspace._VerFerramentas` (3 Handles + Parts) parecem restos de depuração.
4. `ReplicatedStorage.Remotes.CortarGrama`, `ComprarUpgrade` e `AtualizarDados` não aparecem em nenhum script ativo (busca textual). Provável legado; a pasta `Remotes` continua em uso porque recebe `ForestGrassStream`.
5. **Remotes criados em vários lugares** (`GameRemotes`, `DadosJogador`, `FerramentasServer`, `SkillService`, `MowerMount`, `ForestCommerce`, `ForestGrassStream`), sem um registro central. Documentar antes de adicionar novos.
6. **`GameServer` monolítico** (floresta + lote + NPC + baús). Uma extração futura da floresta para um `ForestService` reduziria risco, mas não é tarefa agora.
7. Segredos da floresta têm `claimed[UserId]` zerado ao sair do jogador. Com persistência desligada isso é coerente, mas **ao ativar save os segredos poderão ser re-coletados** se não forem migrados para o perfil.
8. Persistência: a infraestrutura (lease, migração, validação) existe, mas está **desligada**. Ativá-la exige o plano do P0-07 e testes de reconexão.
9. A instância `InterfaceHUD_backup_antes_juice` em `ServerStorage` não está `Disabled`. É inofensiva (não executa em ServerStorage), mas confunde auditorias.

## O que este documento **não** prova

- Nenhum comportamento em Play (cortador, ferramentas, baús, habilidades, UI, floresta).
- Se a place é a publicada.
