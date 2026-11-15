# Álbum de coleções

**Data:** 2026-11-12 · **IA:** Claude · **Place:** `106412085364108`

**Pedido do usuário:** "3. Vamos fazer isso agora" (frentes novas). Este é o item 5 do brain 19 ("coleções e álbum"). Os valores ficam em `AlbumConfig`.

**Backup:** `ServerStorage.AlbumBackup_20261112` (Economia, ProfileData e as listas de janelas dos clientes).

## O que o jogador vê

- **Botão "📖 ÁLBUM"** na coluna da esquerda, abaixo de CONFIG.
- **Painel com 4 páginas, uma por aba.** Cada aba mostra x/y e fica verde quando a página está completa. Os itens que o jogador já tem aparecem com ícone e nome; os que faltam aparecem como "❓ ???".

  | Página | Itens | De onde vem |
  |---|---|---|
  | 🌲 Segredos da Floresta | 17 | registro `ReplicatedStorage.SegredosDaFloresta` + `ForestClaimedSecrets` |
  | 🐾 Ajudantes do Jardim | 10 | espécies que o jogador já teve. Ficam no álbum mesmo se ele soltar o ajudante |
  | 🔨 Ferramentas | 15 | as raridades da Oficina; ter uma raridade conta as anteriores |
  | 🌦️ Climas e Eventos | 3 | estar online durante cada evento do servidor |

- **Página completa:** paga moedas uma vez só (2.000, 2.000, 3.000 e 1.000, × cortador) e dá **+5% de grama para sempre** (`BonusAlbum`, na `Economia.FatorGrama`, até +20%). Aparece o aviso "📖 Página completa".

## Arquivos

| Studio | Cópia aqui |
|---|---|
| `ReplicatedStorage.Shared.AlbumConfig` (novo: páginas, prêmios e validação) | `AlbumConfig.luau` |
| `CorteEDescubra.AlbumServidor` (novo, `RemoteFunction AlbumAcao`: estado) | `AlbumServidor.server.luau` |
| `StarterPlayerScripts.AlbumCliente` (novo) | `AlbumCliente.client.luau` |

**Salvo no perfil:** `profile.Album = { version=1, especies={}, eventos={}, paginas={} }`, validado no `ProfileData`.

**Quando o álbum confere:**
- ao entrar;
- quando um ninho é chocado ou um baú/segredo é aberto (`MissoesSinal`);
- quando muda `ForestClaimedSecrets`, `Raridade_*` ou `PetsEquipados`;
- quando começa um evento.

**Trechos em scripts existentes:**
- `Economia.FatorGrama`: `+ bonus("BonusAlbum", 1)`.
- `ProfileData`: `(profile.Album==nil or AlbumConfig.valid(profile.Album))`.
- `AlbumAberto` entrou na lista "uma janela por vez" dos outros painéis.
