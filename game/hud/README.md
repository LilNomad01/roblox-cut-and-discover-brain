# HUD alinhado e com um estilo só (HudKit)

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "Preciso fazer a UI do HUD deixar 100% alinhada e mais exclusiva". A pesquisa de referência está em [brain 21](../../brain/21_REFERENCIAS_HUD_E_ARTE.md).

**Backup:** `ServerStorage.HudBackup_20261112` (RecompensasCliente, MissoesCliente, FamaCliente, AmigosCliente, AlbumCliente, QuestPanel, ForestCommerceClient).

## O problema

- A HUD original (`InterfaceHUD`) desenha numa tela base de 1600×900, com margem 18, botões 80×80 e espaço 8, e encolhe tudo por `UIScale`.
- Os 5 botões que eu tinha criado (Prêmios, Missões, Fama, Amigos e Álbum) usavam tamanhos fixos, **não encolhiam junto** e tinham outro visual: retângulos largos.
- As margens da direita não batiam: moedas a 18, cartão de missão e Explorar a 12.
- O Explorar usava 45% da altura da tela e encostava no cartão de missão.

## O que mudou

- **`ReplicatedStorage.Shared.HudKit`** (novo) reproduz o botão da HUD original e controla as colunas:
  - **mesma receita do botão:**
    - 80×80, cantos 24;
    - degradê vertical, contorno escuro 4 + aro branco 1,5;
    - faixa de brilho no topo, ícone e rótulo FredokaOne com contorno;
    - hover +7% e clique −8%;
  - **mesma escala:** `clamp(min(L/1600, A/900), 0.5, 1.15)`;
  - **selo vermelho** com contador (canto superior direito) e **chip** de informação (canto superior esquerdo).
- **Coluna da esquerda:** o 📒 ÁLBUM entrou **dentro** do `HUDCortaGrama.Menu` original e herda a lista, o espaço e o alinhamento: MENU, LOJA, UPGRADES, PETS, CONFIG, ÁLBUM.
- **Coluna da direita:** uma grade 2×2 no mesmo estilo:

  | Botão | Cor | Indicador |
  |---|---|---|
  | 🎁 PRÊMIOS | vermelho | selo "!" quando há prêmio |
  | 📋 MISSÕES | azul | selo com o número de missões prontas |
  | ⭐ FAMA | ouro | chip "★N"; selo "!" com o Imperial GX |
  | 👥 AMIGOS | verde | chip "+N%" com amigos no servidor |

- **Pilha da direita alinhada pelo HudKit:** moedas → cartão de missão → Explorar → grade.
  - Todos terminam na **mesma margem de 18 px**.
  - O espaço entre eles é de **8 × escala**.
  - O Explorar passou a ser posicionado logo abaixo do cartão; a grade fica logo abaixo do Explorar ou do cartão, se o Explorar sumir.
  - O cálculo usa `GuiService:GetGuiInset()`, porque `AbsolutePosition` nunca conta a barra do topo.
- **Scripts de outros autores:** `QuestPanel` e `ForestCommerceClient` só tiveram a margem trocada de 12 para 18.

## Medido em Play (janela 1274×461, escala 0,51)

| Peça | x (borda direita) | y |
|---|---|---|
| Moedas | 1255 | 18–55 |
| Cartão de missão | 1256 | 67–183 |
| Explorar | 1256 | 187–229 |
| Grade (Prêmios/Missões, Fama/Amigos) | 1255 | 233–274, 278–319 |
| Coluna esquerda (6 botões de 41 px) | x 19 | 69 → 294, passo de 45 |

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.HudKit` | `HudKit.luau` |
| Botões nos clientes | `rewards/`, `missions/`, `fame/`, `friends/`, `album/` (trechos "HudKit") |
