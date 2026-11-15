# Clima e eventos do servidor (PAD-06)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "continue essa e as próximas sem autorização". Este é o item 6 do [brain 20](../../brain/20_PADROES_JOGOS_SIMILARES.md). Os valores foram escolhidos pelo Claude e ficam em `EventosConfig`.

**Backup:** `ServerStorage.EventosBackup_20261112` (Economia, TufoDourado, GameServer).

## O que o jogador vê

- **O primeiro evento** começa 4 min depois de o servidor abrir. Depois disso vem um a cada **7 a 11 min**, sem repetir o anterior, e vale para todo mundo no servidor.
- **Faixa no alto da tela** com ícone, nome, o que o evento faz e um relógio com o tempo que falta. Também há aviso no começo e no fim, e quem entra no meio do evento recebe um aviso.

| Evento | Duração | Efeito | Visual |
|---|---|---|---|
| 🌧️ Chuva de Primavera | 3 min | a grama do jardim volta em **5 s** (normal 20 s) e **2× tufos dourados** (4 por jardim) | chuva em volta da câmera |
| ⏰ Hora do Dobro | 3 min | **toda grama vale 2×** | faixa laranja |
| ✨ Vento Dourado | 2,5 min | **3× tufos dourados** no jardim (6) e 3× a chance na floresta (3%) | brilhos dourados no ar |

A iluminação não muda, porque a transição Vila→Floresta controla a luz.

## Fator único da grama (também fecha uma pendência do PAD-05)

`Economia.FatorGrama(p)` = cortador × (1 + ajudantes + grupo + **rank de missões** + **amigos**) × **evento**

- É usado pela `Economia.EncherSaco` e pelo `TufoDourado`.
- O **tufo dourado agora soma o rank das missões**, que era pendência do PAD-05.
- A parte de amigos (`BonusAmigos`) já entra na conta para o PAD-08.
- Cada parte tem teto:
  - ajudantes: 10;
  - grupo, rank e amigos: 1 cada;
  - evento: 3.

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.EventosConfig` (novo; textos, cores e números, sem segredo) | `EventosConfig.luau` |
| `CorteEDescubra.EventosServidor` (novo) | `EventosServidor.server.luau` |
| `StarterPlayerScripts.EventosCliente` (novo; faixa e efeitos) | `EventosCliente.client.luau` |

**Atributos no Workspace:** `EventoAtual`, `EventoFim` (horário do servidor), `EventoGrama`, `EventoDouradoMult` e `EventoRebrota`.

**Para testar ou forçar um evento**, rode no servidor (barra de comando no Play ou MCP):

```lua
workspace:SetAttribute("EventoForcar", "chuva") -- "dobro", "vento" ou "parar"
```

Um cliente que mude esse atributo não afeta o servidor, então não é brecha.

### Trechos em scripts existentes

- `Economia`:
  - nova função `FatorGrama`;
  - `EncherSaco` passa a usar `local mult = Economia.FatorGrama(p)`.
- `TufoDourado`:
  - `premiar` usa `Economia.FatorGrama(player)`;
  - `sortearLote` e `aoCortarFloresta` multiplicam por `EventoDouradoMult`.
- `GameServer.agendarRebrota`: `task.wait(tonumber(workspace:GetAttribute("EventoRebrota")) or REBROTA_SEGUNDOS)`.
