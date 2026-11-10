# Playtest P0-02 a P0-05 — 2026-11-10

**IA:** Claude (Claude Code) · **Place:** `106412085364108` (baseline de trabalho) · **Modo:** Play solo no Studio do usuário, via MCP do Roblox (`start_stop_play`, input de teclado real no cliente, leitura de estado no servidor). **Nenhum script ou instância do jogo foi alterado.** Os dados do teste (moedas, XP, cortes) foram descartados ao parar o Play; `PersistenceEnabled=false`.

**Plataforma testada:** somente PC (teclado). Mobile, controle e multiplayer **não testados**.

## P0-02 — Inicialização e saco

| Verificação | Resultado |
|---|---|
| Jogador recebe lote | `Plot01`, `OwnerUserId` definido |
| `ProfileReady` | `true` |
| Saco inicial | `Saco=0`, **`SacoMax=50`** (cortador Básico): **não reproduzido o bug `0/1`** |
| Ferramenta inicial | `MowerTool` equipada, `FerramentaAtiva=Cortador` |
| Floresta | `[Floresta] PRONTA: 25197 tufos, 16 segredos, área 600x648` |
| Erros de script no console | **Nenhum** |

Avisos no console (não são erros de script):
- `TextureID` que não carregam (`No asset content representation found`): `73347833975287` (peças do `Cortador_Basico`: Carcaca, Guidao, Lamina, Motor, Rodas), `120034081281408`, `94694536609432` e `135566642687046` (malhas do `GrassPack`). Visualmente, o cortador e a grama aparecem nas capturas. Verificar a posse/permissão dos assets.
- `Asset id 12946311200 should reference a Folder Instance named R15Anim` (pacote de animação do avatar).
- `print("Hello world!")` de `Workspace.Script`.

## P0-03 — Carrinho (slot 4)

| Verificação | Resultado |
|---|---|
| Montagem | 9 peças (carcaça, guidão, lâmina, motor, 4 rodas, saco coletor) visíveis, não ancoradas; lâmina a 4,9 studs do root, rente ao chão. Captura: `carrinho-montado-corte.jpg` |
| Corte com input real (W/A/S) | `Saco 0→7`, `XP 0→35` (5 XP/quadrado), HUD "7/64 cortes". Captura: `hud-corte-lote.jpg` |
| Corte só com navegação automática | **0 cortes**: o cliente exige `Humanoid.MoveDirection>0.05`, então o caminho via `MoveTo` não envia `CutIntent`. Comportamento esperado, não é bug para jogadores. |
| Respawn | Personagem novo em 6,5 s, `MowerTool` remontada (lâmina a 4,9 studs), `Saco` preservado (7), volta ao spawn do lote |

## P0-04 — Ferramentas manuais (R15, tecla F)

| Ferramenta | Equipou | Golpes | Resultado |
|---|---|---|---|
| Foice (3) | `Foice_Comum`, só ela no personagem | 4 | +2 quadrados, +10 XP |
| Enxada (2) | `Enxada_Comum` | 3 | +1 quadrado, +5 XP |
| Unha (1) | `CortadorUnha_Comum` | 4 | +1 quadrado, +5 XP (o config prevê cerca de 3 golpes por quadrado) |

- O corte passa pelo servidor (`FerramentasServer` e `CortarPorLamina`), pela lâmina, não pelos pés.
- Nunca há duas ferramentas visíveis ao mesmo tempo.
- A taxa de acerto da enxada e da foice parece baixa (parte dos golpes não corta). Pode ser alcance/ângulo ou quadrados já cortados; **investigar com vídeo**.
- **Animação:** só há captura estática (`foice-golpe.jpg`, foice erguida no meio do golpe). Naturalidade do movimento **não avaliada**; precisa de vídeo ou avaliação do usuário.

## P0-05 — Baús

Testado o baú visível da floresta (`entrada_bau`, Comum, em −19, −243). Os outros 15 segredos começam com o prompt desligado e só se revelam cortando o mato.

| Verificação | Resultado |
|---|---|
| Prompt | E, segurar 0,2 s, distância 10, sem linha de visão obrigatória |
| 1º E | `Moedas 0→64`, `Nível 1→2`, `ForestSecrets 0→1` (inclui o bônus de nível) |
| 2º e 3º E | **Sem nova recompensa** (`64→64`, `ForestSecrets 1→1`): recompensa única por jogador ✔ |
| Orientação | Baú em pé, apoiado na trilha. Captura: `bau-entrada-floresta.jpg` |
| **UX** | Depois de coletado, o prompt "Abrir baú / Tesouro escondido" **continua visível** para o jogador (o registro de coleta é por jogador no servidor). Sugestão: esconder no cliente ou trocar o texto para "Vazio". |

### Correção do prompt (mesmo dia, Claude)

Aplicada a mudança descrita em `game/chest-prompt/README.md`. Backup em `ServerStorage.GameServerBeforeChestPromptFix_20261110`. Fontes do Studio e do repositório conferidas por tamanho e hash (GameServer `70952/613054764`; cliente `1293/645770242`).

Novo Play (PC):

| Verificação | Resultado |
|---|---|
| Prompts marcados com `ForestSecretId` | 16 de 16 segredos |
| Antes de coletar (cliente) | `Enabled=true`, id `entrada_bau` |
| Depois do E | `Moedas 0→14`, `ForestSecrets 0→1`, `ForestClaimedSecrets="entrada_bau"` |
| Prompt no **cliente** de quem coletou | `Enabled=false` (escondido) |
| Prompt no **servidor** | `Enabled=true`: outros jogadores ainda podem abrir |
| Console | sem erros de script |

A captura de tela do Studio não mostra o balão do prompt nem antes da correção, por isso a evidência é o estado `Enabled` lido no cliente e no servidor. **Não testado:** dois jogadores simultâneos (Team Test) e mobile.

**Não testado:** baú do lote (aparece no meio do job, `revealAt`), baús revelados por corte na floresta, toque no mobile, botão do controle.

## Resumo

- **P0-02:** inicialização OK no PC; bug `0/1` não reproduzido.
- **P0-03:** carrinho OK no PC, incluindo respawn; mobile pendente.
- **P0-04:** as 3 ferramentas funcionam no PC; animação e taxa de acerto pendentes de avaliação.
- **P0-05:** baú da entrada OK e idempotente no PC; UX do prompt pós-coleta, baú do lote e mobile pendentes.
