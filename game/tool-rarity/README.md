# Raridade das ferramentas — Oficina (MON-04, parte 2)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "3. Vamos fazer isso agora" (frentes novas). Este é o item 2 do brain 19 ("raridade das ferramentas, com materiais achados na floresta"). Os valores foram escolhidos pelo Claude e ficam em `OficinaConfig`.

**Backup:** `ServerStorage.OficinaBackup_20261112` (Economia, ProfileData, FerramentasServer, VendorIdle, PetsCliente, RecompensasCliente, MissoesCliente, FamaCliente).

## O que o jogador vê

- **Oficina no lobby:** uma bancada com telhado, bigorna, as 3 ferramentas penduradas e a placa "🔨 OFICINA", atrás do spawn e de frente para ele. Apertar **E** ("Evoluir ferramentas") abre o painel.
- **Materiais, ganhos jogando:**

  | Material | Como cai |
  |---|---|
  | 🌿 Fibra da Floresta | 4% de chance a cada tufo cortado na Floresta |
  | 💎 Cristal do Bosque | cada baú ou segredo aberto (lote ou Floresta), com aviso |
  | ✨ Pó Dourado | cada tufo dourado cortado |

  Quando um material cai, aparece um "+1 🌿" flutuando na tela.
- **Evolução:** cada ferramenta (Unha, Enxada, Foice) vai de Comum até Mitológico. O modelo 3D de cada raridade já existia (`ServerStorage.GameAssets.Ferramentas`).

  | Raridade | Custo | Na mão: grama | Quadrados extras por golpe |
  |---|---|---|---|
  | Comum | — | — | — |
  | Incomum | 500 💰 + 15 🌿 | +10% | — |
  | Raro | 5.000 💰 + 50 🌿 + 3 💎 | +25% | +1 |
  | Lendário | 40.000 💰 + 120 🌿 + 8 💎 + 10 ✨ | +50% | +1 |
  | Mitológico | 250.000 💰 + 300 🌿 + 15 💎 + 30 ✨ | +100% | +2 |

- **O bônus só vale com a ferramenta na mão:** com o carrinho, ele é 0.
- **Troca na hora:** se a ferramenta estiver na mão quando evolui, o modelo muda na hora. Ao equipar, o jogo usa sempre a melhor raridade possuída.

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.OficinaConfig` (novo: regras, custos e validação) | `OficinaConfig.luau` |
| `CorteEDescubra.OficinaServidor` (novo, `RemoteFunction OficinaAcao`: estado/evoluir) | `OficinaServidor.server.luau` |
| `StarterPlayerScripts.OficinaCliente` (novo) | `OficinaCliente.client.luau` |
| `Workspace.GameWorld.Lobby.OficinaFerramentas` (modelo, atômico no streaming) | receita em `OficinaFerramentas.build.luau` |

**Salvo no perfil:** `profile.Ferramentas = { version=1, nivel = { [tipo]=1..5 }, materiais = { fibra, cristal, po } }`, validado no `ProfileData`.

**Os materiais caem pelo `MissoesSinal`** (eventos floresta, descoberta e dourado), então não há gancho novo no `GameServer`.

**Atributos:**
- `FerramentasExtras`: ids possuídos, lidos pelo `possui` do `FerramentasServer`;
- `Raridade_<tipo>`;
- `BonusFerramenta`;
- `Mat_fibra`, `Mat_cristal` e `Mat_po`.

### Trechos em scripts existentes

- `FerramentasServer`:
  - equipa `Raridade_<tipo>` em vez de "Comum";
  - `maxTiles + tilesExtra(raridade)` no golpe;
  - quando a raridade muda com a ferramenta na mão, ela é reequipada.
- `Economia.FatorGrama`: `+ bonus("BonusFerramenta", 1)`.
- `ProfileData`: `(profile.Ferramentas==nil or OficinaConfig.valid(profile.Ferramentas))`.
- `OficinaAberta` entrou na lista "uma janela por vez" de `VendorIdle`, `PetsCliente`, `RecompensasCliente`, `MissoesCliente` e `FamaCliente`.

**Teste no Studio:** no servidor, `Player:SetAttribute("OficinaTeste", N)` dá N de cada material.
- Só funciona com `RunService:IsStudio()`.
- Um cliente não consegue mudar esse atributo no servidor.
